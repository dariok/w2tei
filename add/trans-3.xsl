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
	
	<xsl:template match="tei:rs">
		<rs type="{@type}">
			<xsl:choose>
				<xsl:when test="following-sibling::node()[not(self::tei:rs)]">
					<xsl:sequence select="node()[not(self::comment())]
						| (following-sibling::tei:rs intersect
						following-sibling::text()[1]/preceding-sibling::tei:rs)/node()[not(self::comment())]" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="node()[not(self::comment())]
						| following-sibling::tei:rs/node()" />
				</xsl:otherwise>
			</xsl:choose>
		</rs>
	</xsl:template>
	<xsl:template match="tei:rs[preceding-sibling::node()[1][self::tei:rs]]" />
	
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
	
	<xsl:template match="tei:note[@type='comment' and preceding-sibling::node()[1][self::tei:note]]"/>
	<xsl:template match="tei:note[@type='comment' and not(preceding-sibling::tei:note)]">
		<note type="comment">
			<xsl:sequence select="node()" />
			<xsl:choose>
				<xsl:when test="following-sibling::*[not(self::tei:note)]">
					<xsl:sequence select="following-sibling::tei:note/node()
						intersect following-sibling::tei:*[not(self::tei:note)]/preceding-sibling::*" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="following-sibling::tei:note/node()" />
				</xsl:otherwise>
			</xsl:choose>
		</note>
	</xsl:template>
	
	<xsl:template match="text()[parent::tei:note[@type='crit_app'] or parent::tei:span]" >
		<xsl:choose>
			<xsl:when test="normalize-space() != ''">
				<xsl:text> </xsl:text>
				<orig><xsl:value-of select="normalize-space()"/></orig>
				<xsl:if test="ends-with(., ' ')">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="following-sibling::tei:hi and preceding-sibling::tei:hi">
				<xsl:text> </xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:hi[@style='font-style: italic;'][parent::tei:note[@type='crit_app']
		or parent::tei:span]" >
		<xsl:choose>
			<xsl:when test="normalize-space() = ''">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:div">
		<xsl:text>
			</xsl:text>
		<xsl:copy>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:p">
		<xsl:copy>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:p/tei:lb">
		<lb />
	</xsl:template>
	
	<xsl:template match="tei:note[@type = 'footnote']/tei:hi[preceding-sibling::node()[1][self::tei:hi]]"/>
		
	<xsl:template match="tei:note[@type = 'footnote']/tei:hi[not(preceding-sibling::node()[1][self::tei:hi])]">
		<hi>
			<xsl:apply-templates select="@style | @rend" />
			<xsl:value-of select="string-join(.
				| following-sibling::tei:hi intersect following-sibling::node()[not(self::tei:hi)][1]/preceding-sibling::*, '')"/>
		</hi>
	</xsl:template>
	
	<xsl:template match="text()[following-sibling::*[1][self::tei:note[@place = 'margin']]]">
		<xsl:choose>
			<xsl:when test="ends-with(., ' ')">
				<xsl:value-of select="substring(., 1, string-length() - 1)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>