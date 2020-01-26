<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:hab="http://diglib.hab.de"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all" version="3.0">
  
  <xsl:include href="../word-pack.xsl"/>
  
  <xsl:template match="/">
    <pkg:package>
      <xsl:sequence select="pkg:package/@*" />
      <xsl:apply-templates select="pkg:package/pkg:part" />
    </pkg:package>
  </xsl:template>
  
  <xsl:template match="pkg:part[contains(@pkg:name, 'word/document.xml')]">
<!--    <xsl:variable name="trenner" select="(descendant::w:p[wt:is(., 'berschrift1') or wt:is(., 'Heading1') or wt:is(., 'Titolo1')])[1]"/>-->
    <xsl:variable name="trenner" select="descendant::w:p[not(descendant::w:t)][1]" />
    <pkg:part pkg:name="titelei">
      <xsl:sequence select="$trenner/preceding-sibling::* | $trenner" />
    </pkg:part>
    <pkg:part pkg:name="/word/document.xml">
      <xsl:sequence select="$trenner/following-sibling::*" />
    </pkg:part>
  </xsl:template>
  
  <xsl:template match="pkg:part">
    <xsl:sequence select="." />
  </xsl:template>
</xsl:stylesheet>