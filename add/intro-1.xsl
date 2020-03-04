<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">

	<xsl:include href="../word-pack.xsl" />
	<xsl:include href="ref-qv.xsl" />
	
	<xsl:template match="tei:rs[not(preceding-sibling::node()[1][self::tei:rs])]">
		<rs type="{@type}">
			<xsl:choose>
				<xsl:when test="following-sibling::node()[not(self::tei:rs)]">
					<xsl:sequence select="node()[not(self::comment())]
						| (following-sibling::tei:rs intersect
						following-sibling::text()[1]/preceding-sibling::tei:rs)/text()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="node()[not(self::comment())]
						| following-sibling::tei:rs/node()" />
				</xsl:otherwise>
			</xsl:choose>
		</rs>
	</xsl:template>
	<xsl:template match="tei:rs[preceding-sibling::node()[1][self::tei:rs]]" />
	
	<xsl:template match="text()">
		<xsl:variable name="t" select="translate(., '║', '‖')" />
		<xsl:analyze-string select="$t" regex="([\d\sr])-([\d\sv])">
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
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>