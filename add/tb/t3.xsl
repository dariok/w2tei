<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns:xstring = "https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="string-pack.xsl"/>
	
	<!-- zusammenziehen von Absätzen mit Marginalie; Vereinbarung: Marginalie steht nicht am Anfang oder Ende -->
	<xsl:template match="tei:*[tei:p and tei:note]">
		<xsl:element name="{local-name()}">
			<xsl:for-each-group select="*" group-starting-with="tei:p[not(preceding-sibling::*[1][self::tei:note])]">
				<xsl:choose>
					<xsl:when test="current-group()[self::tei:note[@place='margin']]">
						<xsl:text>
				</xsl:text>
						<p>
							<xsl:apply-templates select="current-group()[self::tei:p]/node() | current-group()[self::tei:note]" />
						</p>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="current-group()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="tei:note[@type = 'crit_app']/text() | tei:span/text()">
		<xsl:analyze-string select="."
			regex="über der Zeile|unter der Zeile|in der Zeile|am Rand|am Seitenanfang|am Seitenende|davor|danach">
			<xsl:matching-substring>
				<wt:place val="{.}" />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="."
				  regex="ergänzt|ergänzt für gestr.|gestr.|ein Wort gestr.|Wörter|ein Buchstabe|Buchstaben|korr. aus:|korr. von anderer Hand aus:|korr. von ... aus|konj. für:|konj. in ... aus:|gestr.|gestr. von anderer Hand|gestr. von ...|von anderer Hand|von ... Hand">
				  <xsl:matching-substring>
				    <wt:action val="{.}" />
				  </xsl:matching-substring>
				  <xsl:non-matching-substring>
				    <xsl:sequence select="." />
				  </xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>