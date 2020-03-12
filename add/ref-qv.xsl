<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
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
  
  <!-- Verweise -->
  <xsl:template match="hab:bm" />
  <xsl:template match="tei:note[@type='footnote' and preceding-sibling::*[1][self::hab:bm]]">
    <note type="footnote">
      <xsl:apply-templates select="@* | node()" />
    </note>
  </xsl:template>
  
  <xsl:template match="hab:mark[not(@ref)]" />
  <xsl:template match="text()[preceding-sibling::*[1][self::hab:mark[@ref]]]" />
  <xsl:template match="hab:mark[@ref]">
    <xsl:variable name="ref" select="substring-before(substring-after(@ref, 'REF '), ' ')" />
    <xsl:variable name="target" select="//hab:bm[@name = $ref]/following-sibling::*[1]" />
    <xsl:choose>
      <xsl:when test="$target/@type='footnote'">
        <ptr type="wdb" target="#{$target/@xml:id}" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- EE-Verweis -->
  <xsl:template match="w:r[wt:is(., 'KSEE-Verweis', 'r')]">
    <xsl:variable name="content">
      <xsl:apply-templates select="w:t" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="matches($content, 'EE\d+##?')">
        <ptr type="wdb" target="../{substring($content, 3, 3)}/{substring($content, 3, 3)}_transcript.xml"/>
      </xsl:when>
      <xsl:otherwise>
        <ref>
          <xsl:comment>TODO Verweis</xsl:comment>
          <xsl:value-of select="$content"/>
        </ref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Hyperlinks -->
  <xsl:template match="w:hyperlink">
    <xsl:variable name="targetID" select="@r:id"/>
    <xsl:variable name="target">
      <xsl:choose>
        <xsl:when test="ancestor::w:endnote">
          <xsl:value-of select="//pkg:part[contains(@pkg:name, 'endnote')]//rel:Relationship[@Id = $targetID]/@Target" />
        </xsl:when>
        <xsl:when test="ancestor::w:footnote">
          <xsl:value-of select="//pkg:part[contains(@pkg:name, 'footnote')]//rel:Relationship[@Id = $targetID]/@Target" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//pkg:part[contains(@pkg:name, 'document')]//rel:Relationship[@Id = $targetID]/@Target" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="matches(@w:anchor, '[cnqs]\d\d\d')">
        <xsl:variable name="s" select="analyze-string($target, '.*EE(\d+)_?([tTiI ]).*')"/>
        <xsl:variable name="num" select="$s//*:group[1]"/>
        <xsl:variable name="par" select="if($s//*:group[2] = ('t', 'T')) then 'transcript' else 'introduction'" />
        <xsl:variable name="id" select="replace(/tei:TEI/@xml:id, '.*_(\d\d\d)_.*', '$1')" />
        <xsl:variable name="loc" select="if($num = $id) then '' else '../' || $num || '/' "/>
        <ptr type="wdb" target="{$loc}{$num}_{$par}.xml#{@w:anchor}" />
      </xsl:when>
      <xsl:otherwise>
        <ptr type="digitalisat" target="{$target}">
          <xsl:apply-templates select="w:r" />
        </ptr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:anchor[not(@type = 'crit_app') and @xml:id]">
    <anchor xml:id="{@xml:id}{if(@type = 'bookmarkEnd') then 'e' else ''}" />
  </xsl:template>
</xsl:stylesheet>