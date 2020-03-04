<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:hab="http://diglib.hab.de"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
<!--  <xsl:include href="../word-pack.xsl" />-->
  
  <!-- Verweise -->
  <xsl:template match="w:bookmarkStart">
    <xsl:if test="not(@w:name = '_GoBack')">
      <hab:bm name="{@w:name}"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="w:bookmarkStart[@name = '_GoBack']" />
  <xsl:template match="w:bookmarkStart[matches(@w:name, '[cnqs]\d\d\d')]">
    <anchor type="bookmarkStart" xml:id="{@w:name}" /> 
  </xsl:template>
  <xsl:template match="w:bookmarkEnd">
    <xsl:variable name="target" select="@w:id" />
    <xsl:variable name="peer" select="preceding::w:bookmarkStart[@w:id = $target]" />
    <xsl:if test="matches($peer/@w:name, '[cnqs]\d\d\d')">
      <anchor type="bookmarkEnd" xml:id="{$peer/@w:name}" />
    </xsl:if>
  </xsl:template>
  <xsl:template match="w:r[w:fldChar]">
    <xsl:if test="not(w:fldChar/@w:fldCharType='separate')">
      <hab:mark>
        <xsl:if test="w:fldChar/@w:fldCharType='begin'">
          <xsl:attribute name="ref" select="normalize-space(following-sibling::w:r[1]/w:instrText)"/>
        </xsl:if>
      </hab:mark>
    </xsl:if>
  </xsl:template>
  
  <!-- EE-Verweis -->
  <xsl:template match="w:r[wt:is(., 'KSEEVerweis', 'r')]">
    <ptr type="wdb">
      <xsl:choose>
        <xsl:when test="contains(., 'II')">
          <xsl:comment> TODO verlinken</xsl:comment>
          <xsl:apply-templates select="w:t" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment> TODO verlinken</xsl:comment>
          <xsl:apply-templates select="w:t" />
        </xsl:otherwise>
      </xsl:choose>
    </ptr>
  </xsl:template>
  
  <xsl:template match="tei:anchor[not(@type = 'crit_app') and @xml:id]">
    <anchor xml:id="{@xml:id}{if(@type = 'bookmarkEnd') then 'e' else ''}" />
  </xsl:template>
</xsl:stylesheet>