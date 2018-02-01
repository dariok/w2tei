<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="../string-pack.xsl" />
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<!--<xsl:template match="tei:*">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@* | node()" />
		</xsl:element>
	</xsl:template>-->
	
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="&lt;.+&gt;">
			<xsl:matching-substring>
				<supplied><xsl:value-of select="substring(substring-before(., '&gt;'), 2)"/></supplied>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="." regex="'.+?'">
					<xsl:matching-substring>
						<ex><xsl:value-of select="substring(substring(., 2), 1, string-length(.)-2)"/></ex>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="."/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="tei:ref[@type='biblical' and not(preceding-sibling::node()[1][self::tei:ref[@type='biblical']])]">
		<xsl:variable name="myId" select="generate-id()" />
		<ref type="{@type}"><xsl:sequence select="text()
			| following-sibling::tei:ref[@type='biblical' and preceding-sibling::node()[1][self::tei:ref[@type='biblical' ]]
			and generate-id(preceding-sibling::tei:ref[@type='biblical'
			and not(preceding-sibling::node()[1][self::tei:ref[@type='biblical' ]])][1]) = $myId]/text()" /></ref>
	</xsl:template>
	<xsl:template match="tei:ref[@type='biblical' and preceding-sibling::node()[1][self::tei:ref[@type='biblical']]]"/>
	
	<xsl:template match="tei:ref[@type='medieval' and not(preceding-sibling::node()[1][self::tei:ref[@type='medieval']])]">
		<xsl:variable name="myId" select="generate-id()" />
		<ref type="{@type}"><xsl:sequence select="text()
			| following-sibling::tei:ref[@type='medieval' and preceding-sibling::node()[1][self::tei:ref[@type='medieval' ]]
			and generate-id(preceding-sibling::tei:ref[@type='medieval'
			and not(preceding-sibling::node()[1][self::tei:ref[@type='medieval' ]])][1]) = $myId]/text()" /></ref>
	</xsl:template>
	<xsl:template match="tei:ref[@type='medieval' and preceding-sibling::node()[1][self::tei:ref[@type='medieval']]]"/>
	
	<!-- Zusammenziehen von Marginalien -->
	<xsl:template match="tei:note[@place='margin' and not(preceding-sibling::node()[1][self::tei:note[@place='margin']])]">
		<note place="margin">
			<xsl:variable name="myId" select="generate-id()"/>
			<xsl:apply-templates />
			<xsl:apply-templates select="following-sibling::tei:note[@place='margin'
				and preceding-sibling::node()[1][self::tei:note[@place='margin']]
				and $myId = generate-id(preceding-sibling::tei:note[@place='margin'
				and not(preceding-sibling::node()[1][self::tei:note[@place='margin']])][1])
				]" mode="content" />
			<!-- and $myId = generate-id(preceding-sibling::tei:note[@place='margin'
					and not(preceding-sibling::tei:note[@place='margin'])][1])]] -->
		</note>
	</xsl:template>
	<xsl:template match="tei:note[@place='margin' and preceding-sibling::node()[1][self::tei:note[@place='margin']]]"/>
	<xsl:template match="tei:note[@place='margin' and preceding-sibling::node()[1][self::tei:note[@place='margin']]]"
		mode="content">
		<xsl:text> </xsl:text>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="text()[parent::tei:note[@type='crit_app'] or parent::tei:span]" >
		<orig><xsl:value-of select="."/></orig>
	</xsl:template>
	<xsl:template match="tei:hi[@style='font-style: italic;'][parent::tei:note[@type='crit_app']
		or parent::tei:span]" >
		<xsl:apply-templates />
	</xsl:template>
	
	<!--<xsl:template match="tei:anchor[not(ends-with(@xml:id, 'e'))]">
		<xsl:variable name="id" select="'#'||@xml:id" />
		<xsl:sequence select="//tei:span[@from=$id]"/>
		<xsl:sequence select="." />
	</xsl:template>
	<xsl:template match="tei:span" />-->
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>