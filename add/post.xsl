<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:template match="text()[following-sibling::*[1][self::tei:ptr[@type = 'wdb'
		and (contains(@target, '#n') or contains(@target, '#c'))]]
		and ends-with(normalize-space(), 'Anm.')]">
		<xsl:value-of select="substring-before(., 'Anm.')" />
	</xsl:template>
	
	<xsl:template match="text()[. = '–' and following-sibling::tei:hi and preceding-sibling::tei:hi]"/>
	<xsl:template match="tei:hi[preceding-sibling::node()[1][self::text()][. = '–']
		and preceding-sibling::*[1][self::tei:hi]]" />
	<xsl:template match="tei:hi[following-sibling::node()[1][self::text()][. = '–']
		and following-sibling::*[1][self::tei:hi]]">
		<hi>
			<xsl:apply-templates select="@*" />
			<xsl:value-of select="."/>
			<xsl:text>–</xsl:text>
			<xsl:value-of select="following-sibling::*[1]"/>
		</hi>
	</xsl:template>
	
	<xsl:template match="tei:ref[preceding-sibling::node()[1][self::tei:ref]]" />
	<xsl:template match="tei:ref[not(preceding-sibling::node()[1][self::tei:ref])]">
		<xsl:variable name="me" select="generate-id()"/>
		<xsl:variable name="cont">
			<xsl:value-of select="."/>
			<xsl:value-of select="string-join(following-sibling::tei:ref[preceding-sibling::node()[1][self::tei:ref]
				and preceding-sibling::tei:ref[not(preceding-sibling::*[1][self::tei:ref])][1][generate-id() = $me]], '')" />
		</xsl:variable>
		<ref>
			<xsl:apply-templates select="@type" />
			<xsl:if test="@type = 'medieval'">
				<xsl:attribute name="cRef">
					<xsl:variable name="val" select="analyze-string($cont, '\d')"/>
					<xsl:choose>
						<xsl:when test="contains($val//*:non-match[1], ',')">
							<xsl:value-of select="substring-before($val//*:non-match[1], ',')" />
							<xsl:text>!</xsl:text>
							<xsl:value-of select="normalize-space(substring-after($val//*:non-match[1], ','))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-before($val//*:non-match[1], ' ')" />
							<xsl:variable name="c" select="substring-after($val//*:non-match[1], ' ')" />
							<xsl:if test="string-length($c) &gt; 0">
								<xsl:text>!</xsl:text>
								<xsl:value-of select="normalize-space($c)" />
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:sequence select="$cont" />
		</ref>
	</xsl:template>
	
	<xsl:template match="tei:listBibl/tei:rs">
		<bibl corresp="{@ref}">
			<xsl:sequence select="node()" />
		</bibl>
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>