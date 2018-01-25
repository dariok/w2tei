<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	exclude-result-prefixes="xs math"
	version="3.0">
	
	<xsl:template match="tei:note[@type='crit_app']">
		<xsl:when test="following-sibling::node()[1][self::tei:note[@type = 'crit_app'] or self::tei:span]">
			<xsl:variable name="last" select="tokenize(., ' ')[last()]"/>
			<xsl:variable name="front" select="wdb:substring-before-last(., ' ')" />
			<xsl:variable name="note" select="(following-sibling::tei:note | following-sibling::tei:span)[1]"/>
			
			<xsl:if test="starts-with(., ' ')">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="string-length($front) &gt; 0">
				<xsl:value-of select="string-join($front, ' ')"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="starts-with($note/tei:hi[1], 'folgt')">
					<xsl:variable name="wit" select="normalize-space($note/tei:hi[2])"/>
					<xsl:variable name="val" select="normalize-space($note/tei:hi[1]/following-sibling::text()[1])"/>
					<xsl:value-of select="$last"/>
					<add wit="{'#'||$wit}"><xsl:value-of select="$val"/></add>
				</xsl:when>
				<xsl:when test="count($note/tei:hi) &gt; 1">
					<xsl:sequence select="$last" />
					<note type="crit_app">
						<xsl:for-each select="$note/node()">
							<xsl:choose>
								<xsl:when test="self::tei:hi">
									<xsl:value-of select="current()"/>
								</xsl:when>
								<xsl:when test="self::text()">
									<orig><xsl:value-of select="current()"/></orig>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="current()" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</note>
				</xsl:when>
				<!-- Phrasen in 128 -->
				<xsl:when test="$note/tei:hi[normalize-space() = ('vom Editor verbessert für', 'vom Editor verbessert aus',
					'von Editor verbessert aus')]">
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
						<xsl:choose>
							<xsl:when test="contains($wit, ',')">
								<rdg wit="#{substring-before($wit, ',')}">
									<xsl:value-of select="normalize-space($note/text()[1])"/>
									<note type="comment"><xsl:value-of select="normalize-space(substring-after($wit, ','))"/></note>
								</rdg>
							</xsl:when>
							<xsl:otherwise>
								<rdg wit="#{$wit}"><xsl:value-of select="normalize-space($note/text()[1])"/></rdg>
							</xsl:otherwise>
						</xsl:choose>
					</app>
				</xsl:when>
				<xsl:when test="$note/tei:hi[normalize-space() = 'Danach gestrichen']">
					<xsl:value-of select="$last" />
					<del>
						<xsl:text> </xsl:text>
						<xsl:value-of select="normalize-space($note/tei:hi/following-sibling::text())"/>
					</del>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$last"/>
					<xsl:sequence select="$note"/>
				</xsl:otherwise>
			</xsl:choose>
			<!--				<xsl:text> </xsl:text>-->
		</xsl:when>
	</xsl:template>
</xsl:stylesheet>