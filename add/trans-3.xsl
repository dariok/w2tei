<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:include href="../string-pack.xsl" />
	
	<xsl:template match="text()">
		<xsl:choose>
			<xsl:when test="following-sibling::node()[1][self::tei:note[@type = 'crit_app']]">
				<xsl:variable name="last" select="tokenize(., ' ')[last()]"/>
				<xsl:variable name="front" select="wdb:substring-before-last(., ' ')" />
				<xsl:variable name="note" select="following-sibling::tei:note[1]"/>
				
				<xsl:value-of select="string-join($front, ' ')"/>
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="$note/tei:hi[. = 'vom Editor verbessert für']">
						<choice>
							<sic><xsl:value-of select="normalize-space($note/tei:hi/following-sibling::text())"/></sic>
							<corr><xsl:value-of select="$last"/></corr>
						</choice>
					</xsl:when>
					<xsl:when test="$note/node()[1][self::text()]">
						<!-- TODO später für mehrere rdg anpassen -->
						<xsl:variable name="wit" select="normalize-space($note/tei:hi)"/>
						<app>
							<lem wit="#A"><xsl:value-of select="$last"/></lem>
							<rdg wit="#{$wit}"><xsl:value-of select="normalize-space($note/text()[1])"/></rdg>
						</app>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$last"/>
						<xsl:sequence select="$note"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>