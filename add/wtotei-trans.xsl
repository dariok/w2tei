<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:hab="http://diglib.hab.de"
    xmlns:wt="https://github.com/dariok/w2tei"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.0">
    
    <xsl:include href="ks-common.xsl#1"/>
    
    <xsl:template match="pkg:part[@pkg:name='/word/document.xml']">
        <xsl:apply-templates select="w:p[hab:isDiv(.)]"/>
    </xsl:template>
    
    <!-- Paragraphen -->
	<xsl:template match="w:proofErr" />
	<xsl:template match="w:p[hab:isDiv(.)]">
<!--		<xsl:variable name="myId" select="generate-id()"/>-->
		<xsl:variable name="next" select="(following-sibling::w:p[hab:isDiv(.)])[1]" />
		<xsl:text>
			</xsl:text>
		<div>
			<xsl:choose>
				<xsl:when test="$next">
					<xsl:apply-templates select="(following-sibling::w:p[hab:isP(.)] | following-sibling::w:tbl)
						intersect $next/preceding-sibling::*" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="following-sibling::w:p[hab:isP(.)] | following-sibling::w:tbl" />
				</xsl:otherwise>
			</xsl:choose>
			<!--<xsl:apply-templates select="following-sibling::w:p[(hab:isP(.))
				and generate-id(preceding-sibling::w:p[hab:isDiv(.)][1]) = $myId]
				| following-sibling::w:tbl[generate-id(preceding-sibling::w:p[hab:isDiv(.)][1]) = $myId]" />-->
		</div>
	</xsl:template>
    
	<xsl:template match="w:p[wt:is(., 'berschrift1') or wt:is(., 'Heading1') or wt:is(., 'Titolo1')]" />
    
	<xsl:template match="w:p[hab:isP(.)]">
		<xsl:variable name="myId" select="generate-id()"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="wt:is(., 'KSWidmung') or wt:is(., 'KSAnrede')">salute</xsl:when>
				<xsl:when test="wt:is(., 'KSAdresse')">opener</xsl:when>
				<xsl:when test="wt:is(., 'KSSchluformeln')">closer</xsl:when>
				<xsl:when test="wt:is(., 'KSBuchtitel')">titlePart</xsl:when>
				<xsl:when test="wt:is(., 'KSZwischenberschrift', 'p')">head</xsl:when>
				<xsl:when test="wt:is(., 'KSlistWit', 'p')">listWit</xsl:when>
				<xsl:otherwise>p</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>
				</xsl:text>
		<xsl:element name="{$name}">
			<!-- TODO später auch für Anreden und ggf. Buchtitle -->
			<xsl:if test="wt:is(., 'KSSchluformeln') or wt:is(., 'KSBuchtitel')">
				<xsl:attribute name="rendition">
					<xsl:choose>
						<xsl:when test="descendant::w:jc[@w:val='center']">
							<xsl:text>#c</xsl:text>
						</xsl:when>
						<xsl:when test="not(descendant::w:ind)">
							<xsl:text>#l</xsl:text>
						</xsl:when>
						<xsl:when test="descendant::w:ind/@w:left &lt; 2000">
							<xsl:text>#l</xsl:text>
						</xsl:when>
						<xsl:when test="descendant::w:ind/@w:left &lt; 4900">
							<xsl:text>#c</xsl:text>
						</xsl:when>
						<xsl:when test="descendant::w:ind/@w:left &lt; 6400">
							<xsl:text>#r</xsl:text>
						</xsl:when>
						<xsl:otherwise>#rc</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="wt:is(., 'KSZwischenberschrift2', 'p')">
				<xsl:attribute name="type">subheading</xsl:attribute>
			</xsl:if>
			<xsl:variable name="pre" select="preceding-sibling::w:p[hab:isP(.)][1]"/>
			<xsl:choose>
				<xsl:when test="$pre">
					<xsl:sequence select="$pre/following-sibling::w:p
						intersect preceding-sibling::w:p"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="preceding-sibling::w:p" />
				</xsl:otherwise>
			</xsl:choose>
			<!--<xsl:sequence select="preceding-sibling::w:p[not(hab:isP(.)
				or wt:is(., 'KSEE-Titel') or wt:is(., 'KSEETitel')
				or wt:is(., 'berschrift1') or wt:is(., 'Heading1') or wt:is(., 'Titolo1'))
				and generate-id(following-sibling::w:p[hab:isP(.)][1]) = $myId]"/>-->
			<xsl:sequence select="." />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="w:endnote">
		<w:endnote>
			<xsl:sequence select="@*" />
			<w:p>
				<xsl:sequence select="w:p/node()[not(self::w:proofErr)]" />
			</w:p>
		</w:endnote>
	</xsl:template>
	<xsl:template match="w:footnote">
		<xsl:text>
			</xsl:text>
		<w:footnote>
			<xsl:sequence select="@* | node()" />
		</w:footnote>
	</xsl:template>
	
	<xd:doc>
		<xd:desc>Tabellen</xd:desc>
	</xd:doc>
	<xsl:template match="w:tbl">
		<table>
			<xsl:apply-templates select="w:tr"/>
		</table>
	</xsl:template>
	<xsl:template match="w:tr">
		<row>
			<xsl:apply-templates select="w:tc	"/>
		</row>
	</xsl:template>
	<xsl:template match="w:tc">
		<cell>
			<xsl:if test="w:tcPr/w:vMerge[@w:val]">
				<xsl:variable name="pos" select="count(preceding-sibling::w:tc) + 1" />
				<xsl:variable name="next" select="(parent::*/following-sibling::w:tr[w:tc[$pos][not(descendant::w:vMerge)]])[1]" />
				<xsl:variable name="rows">
					<xsl:choose>
						<xsl:when test="$next">
							<xsl:value-of select="count(parent::w:tr/following-sibling::w:tr[descendant::w:vMerge and following-sibling::w:tr[not(descendant::w:vSpan)][1] = $next]) + 1"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="count(parent::w:tr/following-sibling::w:tr) + 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> 
				<xsl:attribute name="rows" select="$rows" />
			</xsl:if>
			<xsl:if test="w:tcPr/w:gridSpan">
				<xsl:attribute name="cols" select="w:tcPr/w:gridSpan/@w:val"/>
			</xsl:if>
			<xsl:sequence select="w:p" />
		</cell>
	</xsl:template>
	
    <!-- Funktionen -->
    <xd:doc>
        <xd:desc>Prüfen, ob es einen Absatz bildet</xd:desc>
    </xd:doc>
    <xsl:function name="hab:isP" as="xs:boolean">
        <xsl:param name="context"/>
        <xsl:sequence select="if($context//w:sym/@w:char='F05E' or $context//w:t[ends-with(normalize-space(), '')]
            or $context//w:t[ends-with(normalize-space(), '⏊')])
            then true() else false()"/>
    </xsl:function>
  
    <xd:doc>
        <xd:desc>Prüfen, ob es eine div begrenzt</xd:desc>
    </xd:doc>
    <xsl:function name="hab:isDiv" as="xs:boolean">
        <xsl:param name="context" />
        <xsl:sequence select="not($context//w:t or $context//w:sym)" />
    </xsl:function>
  
    <xsl:function name="hab:isStruct" as="xs:boolean">
        <xsl:param name="context" />
        <xsl:sequence select="hab:isP($context) or wt:is($context, 'KSEE-Titel')
            or wt:is($context, 'berschrift1') or wt:is($context, 'Heading1')
            or wt:is($context, 'Titolo1') or wt:is($context, 'KSZwischenberschrift')" />
    </xsl:function>
</xsl:stylesheet>
