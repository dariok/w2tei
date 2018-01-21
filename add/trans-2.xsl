<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:hab="http://diglib.hab.de"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
<!--	<xsl:output indent="yes"/>-->
	
	<xsl:include href="../string-pack.xsl" />
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="tei:teiHeader">
		<teiHeader>
			<xsl:apply-templates select="node()" />
		</teiHeader>
	</xsl:template>
	<xsl:template match="tei:sourceDesc">
		<sourceDesc>
			<listWit>
				<witness xml:id="A" />
			</listWit>
			<xsl:comment>TODO witness eintragen</xsl:comment>
		</sourceDesc>
	</xsl:template>
	<xsl:template match="tei:author">
		<editor><xsl:apply-templates /></editor>
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
			<xsl:when test="preceding-sibling::*[1][self::tei:note]
				and ends-with(preceding-sibling::tei:note[1]/preceding-sibling::text()[1], '-')">
				<xsl:text> </xsl:text>
				<w>
					<xsl:value-of select="wdb:substring-before(wdb:substring-after-last(preceding-sibling::text()[1], ' '), '-')" />
					<xsl:sequence select="preceding-sibling::tei:note[1]" />
					<lb break="no" />
					<xsl:value-of select="wdb:substring-before(following-sibling::text()[1], ' ')" />
				</w>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
				<xsl:text> </xsl:text>
				<w>
					<xsl:value-of select="wdb:substring-before(wdb:substring-after-last(preceding-sibling::text()[1], ' '), '-')" />
					<lb break="no" />
					<xsl:value-of select="wdb:substring-before(following-sibling::text()[1], ' ')" />
				</w>
				<xsl:if test="contains(following-sibling::text()[1], ' ')">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<lb/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:note[@place]">
		<xsl:choose>
			<xsl:when test="following-sibling::*[1][self::tei:lb] and ends-with(preceding-sibling::text()[1], '-')"/>
			<xsl:otherwise>
				<xsl:sequence select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Verweise -->
	<xsl:template match="hab:bm" />
	<xsl:template match="tei:note[@type='footnote' and preceding-sibling::*[1][self::hab:bm]]">
		<note type="footnote" xml:id="n{count(preceding::hab:bm)}">
			<xsl:apply-templates select="node()" />
		</note>
	</xsl:template>
	
	<xsl:template match="hab:mark[not(@ref)]" />
	<xsl:template match="text()[preceding-sibling::*[1][self::hab:mark[@ref]]]" />
	<xsl:template match="hab:mark[@ref]">
		<xsl:variable name="ref" select="substring-before(substring-after(@ref, 'REF '), ' ')" />
		<xsl:variable name="target" select="//hab:bm[@name = $ref]/following-sibling::*[1]" />
		<xsl:choose>
			<xsl:when test="$target/@type='footnote'">
				<ptr type="wdb" target="#n{count($target/preceding::hab:bm)}" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:note[@type = 'footnote']/text()[not(preceding-sibling::*[1][self::hab:mark])]">
		<xsl:analyze-string select="." regex="„([^“^&quot;]*)[“&quot;]">
			<xsl:matching-substring>
				<quote>
					<xsl:analyze-string select="substring(., 2, string-length()-2)" regex="\[\.\.\.\]">
						<xsl:matching-substring><gap/></xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:sequence select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</quote>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- Zusammenziehen von zusammengehörigen Teilen -->
	<xsl:template match="tei:hi[@style='font-style: italic;' and not(preceding-sibling::node()[1][self::tei:hi])]">
		<xsl:variable name="myId" select="generate-id()" />
		<hi style="font-style: italic;"><xsl:sequence select="text()
				| following-sibling::tei:hi[preceding-sibling::node()[1][self::tei:hi]
					and generate-id(preceding-sibling::tei:hi[not(preceding-sibling::node()[1][self::tei:hi])][1]) = $myId]/text()" /></hi>
	</xsl:template>
	<xsl:template match="tei:hi[preceding-sibling::node()[1][self::tei:hi]]"/>
	
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
			<xsl:when test="ends-with(normalize-space(), '-') and following-sibling::*[1][self::tei:note]">
				<xsl:value-of select="wdb:substring-before-last(., ' ')" />
			</xsl:when>
			<xsl:when test="preceding-sibling::node()[1][self::tei:lb] and
				ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
				<xsl:value-of select="substring-after(., ' ')" />
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