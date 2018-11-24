<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:hab="http://diglib.hab.de"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs math"
	version="3.0">
	
	<xsl:template match="tei:hi[@style = 'font-style: italic;']">
		<term type="term">
			<xsl:apply-templates />
		</term>
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>