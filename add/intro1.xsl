<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs math"
	version="3.0">
	
	<xsl:template match="tei:listBibl[@type = 'sigla']//tei:title/text()">
		<xsl:value-of select="translate(., '║', '‖')"/>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="([\d\sr])-([\d\sv])">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1) || '–' || regex-group(2)"/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="." regex="\w+'.+?'\w?">
					<xsl:matching-substring>
						<expan>
							<xsl:analyze-string select="." regex="'.+'">
								<xsl:matching-substring><ex><xsl:value-of select="substring(substring(., 2), 1, string-length(.)-2)"/></ex></xsl:matching-substring>
								<xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
							</xsl:analyze-string>
						</expan>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="."/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:copy select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>