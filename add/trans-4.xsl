<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:xstring="https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	
<!--	<xsl:output indent="true"/>-->
	
	<xsl:include href="../string-pack.xsl"/>
	<xsl:include href="bibl.xsl#6"/>
	
	<xsl:template match="tei:ref[@type='biblical']">
		<xsl:variable name="self" select="normalize-space(analyze-string(., '^.+[a-z] ')//*:match)"/>
		<xsl:variable name="trenn" select="." />
		<xsl:choose>
			<xsl:when test="contains(., ';') or contains(., 'u.') or contains(., 'und')">
				<xsl:variable name="parts" as="xs:string*">
					<xsl:choose>
						<xsl:when test="contains(., ';')">
							<xsl:sequence select="tokenize(., ';')"/>
						</xsl:when>
						<xsl:when test="contains(., 'u.')">
							<xsl:sequence select="tokenize(., 'u.')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="tokenize(., 'und')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:for-each select="$parts">
					<ref type="biblical">
						<xsl:choose>
							<xsl:when test="matches(normalize-space(), '^\d') and contains(., ',')">
								<xsl:attribute name="cRef" select="$self || ' ' || normalize-space()" />
								<xsl:value-of select="normalize-space()"/>
							</xsl:when>
							<xsl:when test="matches(normalize-space(), '^\d')">
								<xsl:variable name="chap"
									select="normalize-space(substring-before(substring-after($trenn, $self), ','))" />
								<xsl:attribute name="cRef" select="$self || ' ' || $chap || ',' || normalize-space()" />
								<xsl:value-of select="normalize-space()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="cRef" select="normalize-space(replace(., 'ö', ''))" />
								<xsl:value-of select="normalize-space()" />
							</xsl:otherwise>
						</xsl:choose>
					</ref>
					<xsl:if test="position() != last()">
						<xsl:choose>
							<xsl:when test="contains($trenn, ';')">
								<xsl:text>; </xsl:text>
							</xsl:when>
							<xsl:when test="contains($trenn, 'u.')">
								<xsl:text> u. </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> und </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<ref type="biblical" cRef="{normalize-space(replace(., 'ö', ''))}">
					<xsl:value-of select="."/>
				</ref>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="text()[not(parent::tei:note[@type='crit_app'] or parent::tei:span)
		and not(parent::tei:note[@type='footnote'] and position() = last())]">
		<xsl:analyze-string select="." regex="&lt;.+?&gt;">
			<xsl:matching-substring>
				<xsl:choose>
					<xsl:when test=". = '&lt;...&gt;'"><gap/></xsl:when>
					<xsl:otherwise><supplied><xsl:value-of select="substring(substring-before(., '&gt;'), 2)"/></supplied></xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- in krit. Anmerkungen aus dem ; ihnter Zeugen eine Markierung machen, um später zu gruppieren -->
	<xsl:template match="tei:note[@type = 'crit_app']/text() | tei:span/text()">
		<xsl:analyze-string select="." regex=";">
			<xsl:matching-substring>
				<wdb:marker />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="tei:orig[preceding-sibling::node()[1][self::tei:orig]]" />
	<xsl:template match="tei:orig[not(preceding-sibling::node()[1][self::tei:orig])]">
		<xsl:variable name="my" select="generate-id()"/>
		<orig>
			<xsl:apply-templates select="node()" />
			<xsl:apply-templates select="following-sibling::tei:orig[preceding-sibling::node()[1][self::tei:orig]
					and generate-id(preceding-sibling::tei:orig[not(preceding-sibling::node()[1][self::tei:orig])][1]) = $my]/node()"/>
		</orig>
	</xsl:template>
	
	<xsl:template match="tei:note[@type = 'footnote']/node()[last()]">
		<xsl:choose>
			<xsl:when test="self::tei:quote and matches(., '[^\.]\.\.\.$')">
				<quote>
					<xsl:sequence select="node()[position != last()]" />
					<xsl:variable name="te" select="substring(node()[last()], 1, string-length() - 3)"/>
					<xsl:value-of select="$te"/>
					<xsl:if test="not(ends-with($te, ' '))">
						<xsl:text> </xsl:text>
					</xsl:if>
					<gap />
					<xsl:text>.</xsl:text>
				</quote>
			</xsl:when>
			<xsl:when test="self::tei:* and not(matches(., '[\.!?] ?$'))">
				<xsl:sequence select="." />
				<xsl:text>.</xsl:text>
			</xsl:when>
			<xsl:when test="matches(., '[\.?!] $')">
				<xsl:value-of select="substring(., 1, string-length() - 1)" />
			</xsl:when>
			<xsl:when test="ends-with(., ' ')">
				<xsl:value-of select="substring(., 1, string-length() - 1) || '.'" />
			</xsl:when>
			<xsl:when test="matches(., '[^\.^!^?^ ]$')">
				<xsl:sequence select="." />
				<xsl:text>.</xsl:text>
			</xsl:when>
			<xsl:when test="matches(., '[^\.]\.\.\.$')">
				<xsl:value-of select="substring(., 1, string-length() - 3)"/>
				<gap />
				<xsl:text>.</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
