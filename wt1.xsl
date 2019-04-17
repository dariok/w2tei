<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xsl:template match="*[tei:ab]">
    <xsl:element name="{local-name()}">
      <xsl:sequence select="@*" />
      <xsl:for-each-group group-adjacent="local-name() || @style" select="*">
        <xsl:element name="{local-name()}">
          <xsl:if test="current-group()[@xml:space]">
            <xsl:attribute name="xml:space" select="'preserve'" />
          </xsl:if>
          <xsl:sequence select="@*" />
          <xsl:sequence select="current-group()/node()"/>
        </xsl:element>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>