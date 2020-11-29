<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="0" />
  
  <xsl:template match="tei:ab">
    <xsl:variable name="style" as="xs:string*">
      <xsl:apply-templates select="@style" />
    </xsl:variable>
    
    <hi>
      <xsl:apply-templates select="@style" />
      
      <xsl:apply-templates />
    </hi>
  </xsl:template>
  
  <xsl:template match="@style">
    <xsl:variable name="values" as="xs:string*">
      <xsl:for-each select="tokenize(., ';')">
        <xsl:variable name="key" select="normalize-space(substring-before(., ':'))" />
        <xsl:variable name="val" select="normalize-space(substring-after(., ':'))" />
        
        <xsl:choose>
          <xsl:when test="$key eq 'b' and $val eq '1'">font-weight: bold</xsl:when>
          <xsl:when test="$key eq 'i' and $val eq '1'">font-style: italic</xsl:when>
          <xsl:when test="$key eq 'u' and $val ne '0'">text-decoration: underline</xsl:when>
          
          <xsl:when test="$key eq 'rtl' and $val eq '1'">direction: rtl</xsl:when>
          
          <xsl:when test="$key eq 'rFonts'">
            <xsl:value-of select="'font-family: ' || $val" />
          </xsl:when>
          
          <xsl:when test="$key eq 'color'">
            <xsl:value-of select="'color: #' || $val"/>
          </xsl:when>
          
          <xsl:when test="$key eq 'sz'">
            <xsl:value-of select="'font-size: ' || number($val) div 2 || 'pt'" />
          </xsl:when>
          
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:attribute name="style" select="string-join($values, '; ') || ';'" />
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>