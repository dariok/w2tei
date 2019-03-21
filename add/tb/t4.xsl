<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns:xstring = "https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="string-pack.xsl"/>
	
	<xsl:template match="tei:note[@type = 'crit_app']/text() | tei:span/text()">
		<xsl:analyze-string select="."
			regex="über der Zeile|unter der Zeile|in der Zeile|am Rand|am Seitenanfang|am Seitenende|davor|danach">
			<xsl:matching-substring>
				<wt:place val="{.}" />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="."
					regex="ergänzt|ergänzt für gestr.|gestr.|ein Wort gestr.|Wörter|ein Buchstabe|Buchstaben|korr.|konj.">
					<xsl:matching-substring>
						<wt:action val="{.}" />
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:analyze-string select="."
							regex="von anderer Hand|von (.+)|in (.+)">
							<xsl:matching-substring>
								<wt:source val="{.}" />
							</xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:value-of select="."/>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
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