<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns:xstring = "https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:template match="wt:pb">
		<xsl:variable name="ct" select="count(preceding::wt:pb)" />
		<xsl:if test="$ct mod 2 = 0">
			<xsl:variable name="text" select="string-join(following-sibling::node()
				intersect following-sibling::wt:pb[1]/preceding-sibling::node(), '')"/>
			<pb n="{normalize-space($text)}"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tei:rdg/text()">
		<xsl:analyze-string select="."
			regex="über der Zeile|unter der Zeile|in der Zeile|am Rand|am Seitenanfang|am Seitenende|davor|danach">
			<xsl:matching-substring>
				<wt:place val="{.}" />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="."
					regex="ergänzt|gestr.|korr.|konj.">
					<xsl:matching-substring>
						<wt:action val="{.}" />
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:analyze-string select="." regex="\s*(aus|für|in)?:\s+(.+)[\.$]">
							<xsl:matching-substring>
								<wt:orig>
									<xsl:sequence select="regex-group(2)" />
								</wt:orig>
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
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:variable name="ct" select="count(preceding::wt:pb)" />
		<xsl:choose>
			<xsl:when test="$ct mod 2 = 1" />
			<xsl:when test="self::text()">
				<xsl:analyze-string select="." regex="„|»">
					<xsl:matching-substring>
						<wt:qs />
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:analyze-string select="." regex="«|“">
							<xsl:matching-substring>
								<wt:qe />
							</xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:value-of select="."/>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@* | node()" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>