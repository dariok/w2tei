<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:hab="http://diglib.hab.de"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="bibl.xsl#1"/>
	
	<xsl:template match="/">
		<xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
		<xsl:apply-templates select="node()" />
	</xsl:template>
	
	<xsl:template match="tei:hi[@style = 'font-style: italic;']">
		<term type="term">
			<xsl:apply-templates />
		</term>
	</xsl:template>
	
	<xsl:template match="hab:qe" />
	<xsl:template match="hab:qs">
		<quote>
			<xsl:choose>
				<xsl:when test="following-sibling::hab:*[1][self::hab:qe]">
					<xsl:apply-templates select="following-sibling::node()
						intersect following-sibling::hab:*[1]/preceding-sibling::node()" mode="quote"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="(following-sibling::node()
						intersect following-sibling::hab:*[3]/preceding-sibling::node())[not(
							preceding-sibling::hab:*[1][self::hab:qs]
							and preceding-sibling::hab:*[2][self::hab:qs])]" mode="quote"/>
				</xsl:otherwise>
			</xsl:choose>
		</quote>
	</xsl:template>
	<xsl:template match="node()[preceding-sibling::hab:*[1][self::hab:qs]
		and following-sibling::hab:*[1][self::hab:qe]]" />
	<xsl:template match="node()[preceding-sibling::hab:*[1][self::hab:qs]
		and following-sibling::hab:*[1][self::hab:qs]
		and following-sibling::hab:*[2][self::hab:qe]]" />
	<xsl:template match="node()[preceding-sibling::hab:*[1][self::hab:qe]
		and following-sibling::hab:*[1][self::hab:qe]
		and not(self::hab:qs)]" />
	
	<xsl:template match="tei:rs[@type = 'place']" mode="quote">
		<xsl:call-template name="rsPlace" />
	</xsl:template>
	<xsl:template match="tei:rs[@type = 'person']" mode="quote">
		<xsl:call-template name="rsPerson" />
	</xsl:template>
	
	<xsl:template match="@* | node()[not(self::hab:qs or self::hab:qe or self::tei:rs)]" mode="quote">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" mode="quote" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="hab:qe" mode="quote" />
	<xsl:template match="hab:qs" mode="quote">
		<quote>
			<xsl:apply-templates select="following-sibling::node()
				intersect following-sibling::hab:*[1]/preceding-sibling::node()" mode="quote"/>
		</quote>
	</xsl:template>
	
	<xsl:template match="tei:msIdentifier">
		<msIdentifier>
			<xsl:apply-templates select="*[not(self::tei:altIdentifier)]" />
			<xsl:apply-templates select="tei:altIdentifier" />
		</msIdentifier>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="\.\.\.">
			<xsl:matching-substring>
				<gap />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<!-- aus ks-r.xsl -->
				<xsl:analyze-string select="." regex="EE(\d+[AB]?)_(text|intro)_.nm\.? ?(\d|[a-z])+-?[a-z]?#">
					<xsl:matching-substring>
						<xsl:variable name="file">
							<xsl:variable name="num" select="analyze-string(regex-group(1), '\d+')//*:match"/>
							<xsl:variable name="lit" select="analyze-string(regex-group(1), '[A-Z]')//*:match"/>
							<xsl:variable name="nr" select="format-number(xs:integer($num), '000')" />
							<xsl:variable name="part">
								<xsl:choose>
									<xsl:when test="regex-group(2) = 'text'">transcript</xsl:when>
									<xsl:otherwise>introduction</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="type" select="if(regex-group(3) castable as xs:integer) then 'n' else 'c'"/>
							<xsl:value-of select="'../' || $nr || $lit || '/' || $nr || $lit || '_' || $part || '.xml#' || $type
								|| regex-group(3)"/>
						</xsl:variable>
						<ptr type="wdb">
							<xsl:choose>
								<xsl:when test="string-length($file) &gt; 20">
									<xsl:attribute name="target" select="$file" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</ptr>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="." />
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="@* | * | comment() | processing-instruction()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>