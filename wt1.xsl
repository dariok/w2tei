<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
   
   <xsl:template match="tei:body">
      <body>
         <xsl:call-template name="divStructure">
            <xsl:with-param name="context" select="node()" />
            <xsl:with-param name="level" select="0" />
         </xsl:call-template>
      </body>
   </xsl:template>
   
   <xsl:template name="divStructure">
      <xsl:param name="level" as="xs:integer" />
      <xsl:param name="context" as="node()+" />
      
      <xsl:for-each-group select="$context" group-starting-with="tei:head[@level = $level
            and not(preceding-sibling::*[1][self::tei:head[@level = $level]])]">
         <xsl:choose>
            <xsl:when test="current-group()[1][@level = $level]">
               <div>
                  <xsl:apply-templates select="current-group()[self::tei:head and @level = $level]" />
                  
                  <xsl:call-template name="divStructure">
                     <xsl:with-param name="level" select="$level + 1" />
                     <xsl:with-param name="context" select="current-group()[not(self::tei:head and @level = $level)]" />
                  </xsl:call-template>
               </div>
            </xsl:when>
            <xsl:when test="current-group()[self::tei:head]">
               <xsl:call-template name="divStructure">
                  <xsl:with-param name="level" select="$level + 1" />
                  <xsl:with-param name="context" select="current-group()" />
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="current-group()" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each-group>
      
      <!--<xsl:for-each-group select="$context" group-starting-with="tei:head[@level = $level 
         and not(preceding-sibling::*[1][self::tei:head[@level = $level]])]">
         <div>
            <xsl:apply-templates select="current-group()[self:: tei:head and @level = $level]" />
            <xsl:choose>
               <xsl:when test="current-group()[self::tei:head and @level = $level + 1]">
                  <xsl:call-template name="divStructure">
                     <xsl:with-param name="context" select="current-group()[not(self::tei:head and @level = $level)]" />
                     <xsl:with-param name="level" select="$level + 1" />
                  </xsl:call-template>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="current-group()[not(self::tei:head and @level = $level)]" />
               </xsl:otherwise>
            </xsl:choose>
         </div>
      </xsl:for-each-group>-->
   </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>