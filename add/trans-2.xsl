<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="../string-pack.xsl" />
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tei:p">
		<p>
			<xsl:apply-templates select="node()" />
		</p>
	</xsl:template>
	
	<xsl:template match="tei:salute">
		<salute>
			<xsl:apply-templates select="node()" />
		</salute>
	</xsl:template>
	
	<xsl:template match="tei:lb">
		<xsl:choose>
			<xsl:when test="ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
				<xsl:text> </xsl:text>
				<w>
					<xsl:value-of select="substring-before(wdb:substring-after-last(preceding-sibling::text()[1], ' '), '-')" />
					<lb break="no" />
					<xsl:value-of select="substring-before(following-sibling::text()[1], ' ')" />
				</w>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<lb/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:note[@type = 'footnote']/text()">
		<xsl:analyze-string select="." regex="„(.*)“">
			<xsl:matching-substring>
				<quote><xsl:value-of select="substring(., 2, string-length()-2)"/></quote>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- Wird im Template für den text() ausgegeben -->
	<xsl:template match="tei:note[@type = 'crit_app']" />
	
	<xsl:template match="text()[not(ancestor::tei:note)]">
		<xsl:choose>
			<xsl:when test="ends-with(normalize-space(), '-')
				and ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
				<xsl:variable name="mid" select="substring-after(., ' ')" />
				<xsl:value-of select="wdb:substring-before-last($mid, ' ')" />
			</xsl:when>
			<xsl:when test="ends-with(normalize-space(), '-') and following-sibling::node()[1][self::tei:lb]">
				<xsl:value-of select="wdb:substring-before-last(., ' ')" />
			</xsl:when>
			<xsl:when test="preceding-sibling::node()[1][self::tei:lb] and
				ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
				<xsl:value-of select="substring-after(., ' ')" />
			</xsl:when>
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
							<lem><xsl:value-of select="$last"/></lem>
							<rdg wit="{$wit}"><xsl:value-of select="normalize-space($note/text()[1])"/></rdg>
						</app>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$last"/>
						<xsl:sequence select="$note"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="@*|*|comment()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>