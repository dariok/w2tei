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
	
	<xsl:template match="@* | node()[not(self::hab:qs or self::hab:qe)]" mode="quote">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
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
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>