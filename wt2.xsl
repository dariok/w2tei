<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="0" />
  
  <xsl:template match="tei:ab">
    <xsl:choose>
      <xsl:when test="@style = 'rtl:0'">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="@style = ('b:1; rtl:0', 'b:1;')">
        <hi rend="bold">
          <xsl:apply-templates />
        </hi>
      </xsl:when>
      <xsl:when test="@style = ('i:1; rtl:0', 'i:1')">
        <hi rend="italics">
          <xsl:apply-templates />
        </hi>
      </xsl:when>
      <xsl:otherwise>
        <hi rend="{@style}">
          <xsl:apply-templates />
        </hi>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@style[. = '']" />
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>