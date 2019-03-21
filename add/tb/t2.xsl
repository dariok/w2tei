<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:template match="tei:text">
		<text>
			<xsl:apply-templates select="tei:front | tei:body" />
			<back>
				<xsl:for-each select="//tei:closer[tei:emph]">
					<index type="{normalize-space(tei:emph)}">
						<xsl:for-each select="tokenize(following-sibling::tei:closer[1], '\|')">
							<term><xsl:value-of select="normalize-space()"/></term>
						</xsl:for-each>
					</index>
				</xsl:for-each>
			</back>
		</text>
	</xsl:template>
	<xsl:template match="tei:closer[tei:emph]" />
	<xsl:template match="tei:closer[preceding-sibling::*[1][tei:emph]]" />
	
	<!-- Anmerkung über mehrere Wörter: anchor mit ID versehen und note zu span -->
	<xsl:template match="tei:anchor">
		<xsl:variable name="num" select="count(preceding::tei:anchor[@ref='se'])+1"/>
		<xsl:choose>
			<xsl:when test="@ref='se'">
				<anchor type="crit_app">
					<xsl:attribute name="xml:id" select="'s'||$num||'e'" />
				</anchor>
			</xsl:when>
			<xsl:otherwise>
				<anchor type="crit_app">
					<xsl:attribute name="xml:id" select="@ref||$num"/>
				</anchor>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:note[@type = 'crit_app']">
		<app>
			<xsl:if test="preceding-sibling::*[1][self::tei:anchor[@ref='se']]">
				<xsl:variable name="num" select="count(preceding::tei:anchor[@ref='se'])" />
				<xsl:attribute name="from" select="'#s'||$num" />
				<xsl:attribute name="to" select="'#s'||$num||'e'" />
			</xsl:if>
			<xsl:apply-templates />
		</app>
	</xsl:template>
	<xsl:template match="tei:note[@type = 'crit_app']/text()">
		<xsl:analyze-string select="." regex="; ">
			<xsl:matching-substring>
				<wt:notes />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="." regex=" – ">
					<xsl:matching-substring>
						<wt:comment />
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="."/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="tei:p">
		<xsl:text>
				</xsl:text>
		<p>
			<xsl:apply-templates select="node() | text()" />
		</p>
	</xsl:template>
	
	<!-- Seitenumbrüche umsetzen -->
	<xsl:template match="text()[ends-with(normalize-space(), '|')
		and following-sibling::node()[1][self::tei:hi]
		and (starts-with(normalize-space(following-sibling::node()[2]), '|')
		or starts-with(normalize-space(following-sibling::node()[3]), '|')
		or starts-with(normalize-space(following-sibling::node()[4]), '|'))]">
		<xsl:value-of select="substring-before(., '|')" />
		<pb>
			<xsl:attribute name="n" select="normalize-space(string-join(following-sibling::node()
				intersect following-sibling::node()[starts-with(normalize-space(), '|')]/preceding-sibling::node(), ''))" />
		</pb>
	</xsl:template>
	<xsl:template match="text()[starts-with(normalize-space(), '|')
		and preceding-sibling::node()[1][self::tei:hi]
		and (ends-with(normalize-space(preceding-sibling::node()[2]), '|')
		or ends-with(normalize-space(preceding-sibling::node()[3]), '|')
		or ends-with(normalize-space(preceding-sibling::node()[4]), '|'))]">
		<xsl:value-of select="substring-after(., '|')"/>
	</xsl:template>
	<xsl:template match="tei:hi[(ends-with(normalize-space(preceding-sibling::text()[1]), '|')
		or ends-with(normalize-space(preceding-sibling::text()[2]), '|')
		or ends-with(normalize-space(preceding-sibling::text()[3]), '|'))
		and (starts-with(normalize-space(following-sibling::text()[3]), '|')
		or starts-with(normalize-space(following-sibling::text()[2]), '|')
		or starts-with(normalize-space(following-sibling::text()[1]), '|')
		)]" />
	<!-- ENDE Seitenumbrüche -->
	
	<!-- postscript zusammenziehen -->
	<xsl:template match="tei:div[tei:postscript and (preceding-sibling::tei:div[tei:postscript])]" />
	<xsl:template match="tei:div[tei:postscript and not(preceding-sibling::tei:div[tei:postscript])]">
		<postscript>
			<xsl:apply-templates select="* | following-sibling::tei:div[tei:postscript]/*" />
		</postscript>
	</xsl:template>
	<xsl:template match="tei:postscript">
		<xsl:text>
				</xsl:text>
		<p><xsl:apply-templates /></p>
	</xsl:template>
	<!-- ENDE Postscript -->
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>