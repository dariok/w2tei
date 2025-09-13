<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
   <xsl:template match="tei:ab[not(@type)]">
      <hi>
         <xsl:apply-templates select="@* | node()" />
      </hi>
   </xsl:template>
  
  <xsl:template match="tei:note/tei:p">
    <xsl:if test="preceding-sibling::*">
      <lb/>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>
   
   <xsl:template match="tei:div">
      <div>
         <xsl:choose>
            <xsl:when test="tei:label">
               <xsl:apply-templates select="tei:label[1]/preceding-sibling::*" />
               <xsl:for-each-group select="tei:label[1] | tei:label[1]/following-sibling::*"
                  group-starting-with="tei:label[not(preceding-sibling::*[1][self::tei:item])]">
                  <list>
                     <xsl:apply-templates select="current-group()[self::tei:label or self::tei:item]" />
                  </list>
                  <xsl:apply-templates select="current-group()[not(self::tei:label or self::tei:item)]" />
               </xsl:for-each-group>
            </xsl:when>
            <xsl:when test="tei:item">
              <xsl:for-each-group select="*"
                group-starting-with="tei:item[preceding-sibling::*[1][not(self::tei:item)]] | tei:p[not(preceding-sibling::tei:p)]">
                <xsl:choose>
                  <xsl:when test="current-group()[1][self::tei:item]">
                    <xsl:variable name="end" select="current-group()[self::tei:item][last()]/generate-id()"/>
                    <list>
                      <xsl:apply-templates select="current-group()[following-sibling::tei:item[generate-id() = $end]
                        or generate-id() = $end]" />
                    </list>
                    <xsl:apply-templates select="current-group()[preceding-sibling::*[generate-id() = $end]]" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="current-group()" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates />
            </xsl:otherwise>
         </xsl:choose>
      </div>
   </xsl:template>
   
   <xsl:template match="@level" />
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>