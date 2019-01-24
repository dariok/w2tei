<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:template match="text()[following-sibling::*[1][self::tei:ptr[@type = 'wdb'
		and (contains(@target, '#n') or contains(@target, '#c'))]]
		and ends-with(normalize-space(), 'Anm.')]">
		<xsl:value-of select="substring-before(., 'Anm.')" />
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>