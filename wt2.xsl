<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xsl:template match="tei:ab">
    
    <hi>
      <xsl:apply-templates select="@* | node()" />
    </hi>
  </xsl:template>
  
  <xsl:template match="@style">
    <xsl:variable name="values" as="xs:string*">
      <xsl:for-each select="tokenize(., ';')">
        <xsl:variable name="key" select="normalize-space(substring-before(., ':'))" />
        <xsl:variable name="val" select="normalize-space(substring-after(., ':'))" />
        
        <xsl:choose>
          <xsl:when test=". eq ' ' or . eq ''" />
          <xsl:when test="$key eq 'outlineLvl'" />
          
          <xsl:when test="$key eq 'b' and $val = ('', '1')">font-weight: bold</xsl:when>
          <xsl:when test="$key eq 'i' and $val = ('', '1')">font-style: italic</xsl:when>
          <xsl:when test="$key eq 'u'">
            <xsl:choose>
              <xsl:when test="$val eq '0' or $val eq ''" />
              <xsl:when test="$val eq 'single'">text-decoration: underline</xsl:when>
              <xsl:when test="$val eq 'dotted'">text-decoration: underline dotted</xsl:when>
              <xsl:when test="$val eq 'double'">text-decoration: underline double auto</xsl:when>
              <xsl:when test="$val eq 'wave'">text-decoration: underline wavy 1px</xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$key eq 'strike'">text-decoration: line-through</xsl:when>
          
          <xsl:when test="$key eq 'rtl' and $val eq '1'">direction: rtl</xsl:when>
          <xsl:when test="$key eq 'rtl'" />
          
          <xsl:when test="$key eq 'rFonts'">
            <xsl:value-of select="'font-family: ' || translate($val, ' ', '_')" />
          </xsl:when>
          
          <xsl:when test="$key eq 'color'">
            <xsl:value-of select="'color: #' || $val"/>
          </xsl:when>
          
          <xsl:when test="$key eq 'sz'">
            <xsl:value-of select="'font-size: ' || number($val) div 2 || 'pt'" />
          </xsl:when>
           
          <!-- settings for complex fonts – evaluation postponed until we have a use case and an expert for
              complex scripts and CSS -->
          <xsl:when test="$key eq 'szCs'" />
           <xsl:when test="$key eq 'iCs'" />
           <xsl:when test="$key eq 'bCs'" />
          
          <xsl:when test="$key eq 'vertAlign'">
            <xsl:variable name="align" select="if ($val eq 'superscript') then 'super' else 'sub'" as="xs:string"/>
            <xsl:value-of select="'vertical-align: ' || $align" />
          </xsl:when>
          
          <xsl:when test="$key eq 'smallCaps'">
            <xsl:text>font-variant: small-caps</xsl:text>
          </xsl:when>
          
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="styleValue" select="string-join($values, '; ')"/>
    <xsl:if test="string-length($styleValue) gt 0">
      <xsl:attribute name="style" select="$styleValue || ';'" />
    </xsl:if>
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