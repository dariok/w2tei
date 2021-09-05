<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" omit-xml-declaration="1" />
  
  <xsl:template match="*[tei:ab]">
    <xsl:element name="{local-name()}">
      <xsl:sequence select="@*" />
      <xsl:for-each-group group-adjacent="local-name() || @style || @type || @rendition" select="*">
        <xsl:element name="{local-name()}">
          <xsl:sequence select="@*" />
          <xsl:apply-templates select="current-group()/node()"/>
        </xsl:element>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="tei:div">
    <div>
      <xsl:choose>
        <xsl:when test="tei:label">
          <xsl:for-each-group select="*"
            group-starting-with="tei:label[not(preceding-sibling::*[1][self::tei:item])]">
            <list>
              <xsl:apply-templates select="current-group()[self::tei:label or self::tei:item]" />
            </list>
            <xsl:apply-templates select="current-group()[not(self::tei:label or self::tei:item)]" />
          </xsl:for-each-group>
        </xsl:when>
         <xsl:when test="tei:item">
            <xsl:apply-templates select="tei:item[1]/preceding-sibling::*" />
            <list>
               <xsl:apply-templates select="tei:item" />
            </list>
            <xsl:apply-templates select="tei:item[last()]/following-sibling::*" />
         </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>