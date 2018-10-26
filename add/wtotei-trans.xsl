<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:hab="http://diglib.hab.de"
    xmlns:wt="https://github.com/dariok/w2tei"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.0">
    
    <xsl:include href="ks-common.xsl"/>
    
<!--    <xsl:output indent="yes"/>-->
    
    <xsl:template match="w:body">
        <xsl:apply-templates
          select="w:p[wt:is(., 'berschrift1')]/following-sibling::w:p[hab:isDiv(.)]"/>
        <xsl:sequence select="parent::w:document/following-sibling::w:*"/>
    </xsl:template>
    
    <!-- Paragraphen -->
	<xsl:template match="w:p[hab:isDiv(.)]">
		<xsl:variable name="myId" select="generate-id()"/>
		<xsl:text>
			</xsl:text>
		<div>
			<xsl:apply-templates select="following-sibling::w:p[(hab:isP(.))
				and generate-id(preceding-sibling::w:p[hab:isDiv(.)][1]) = $myId]" />
		</div>
	</xsl:template>
    
    <xsl:template match="w:p[wt:is(., 'berschrift1')]" />
    
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
            <xsl:sequence select="preceding-sibling::w:p[not(hab:isP(.)or wt:is(., 'KSEE-Titel')or wt:is(., 'berschrift1'))
                and generate-id(following-sibling::w:p[hab:isP(.)][1]) = $myId]"/>
            <xsl:sequence select="." />
        </xsl:element>
    </xsl:template>
	
	<xsl:template match="w:endnote">
		<xsl:text>
			</xsl:text>
		<w:endnote>
			<xsl:sequence select="node()" />
		</w:endnote>
	</xsl:template>
	<xsl:template match="w:footnote">
		<xsl:text>
			</xsl:text>
		<w:footnote>
			<xsl:sequence select="node()" />
		</w:footnote>
	</xsl:template>
    
    <!-- Funktionen -->
    <xd:doc>
        <xd:desc>Prüfen, ob es einen Absatz bildet</xd:desc>
    </xd:doc>
    <xsl:function name="hab:isP" as="xs:boolean">
        <xsl:param name="context"/>
        <xsl:sequence select="if($context//w:sym/@w:char='F05E' or $context//w:t[contains(., '')]
            or $context//w:t[contains(., '⏊')])
            then true() else false()"/>
    </xsl:function>
  
    <xd:doc>
        <xd:desc>Prüfen, ob es eine div begrenzt</xd:desc>
    </xd:doc>
    <xsl:function name="hab:isDiv" as="xs:boolean">
        <xsl:param name="context" />
        <xsl:sequence select="if($context//w:t or $context//w:pStyle) then false() else true()" />
    </xsl:function>
  
    <xsl:function name="hab:isStruct" as="xs:boolean">
        <xsl:param name="context" />
        <xsl:sequence select="hab:isP($context) or wt:is($context, 'KSEE-Titel')
            or wt:is($context, 'berschrift1') or wt:is($context, 'KSZwischenberschrift')" />
    </xsl:function>
</xsl:stylesheet>
