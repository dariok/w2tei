<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:template match="text()[. = '–' and following-sibling::tei:hi and preceding-sibling::tei:hi]"/>
  <xsl:template match="tei:hi[preceding-sibling::node()[1][self::text()][. = '–']
    and preceding-sibling::*[1][self::tei:hi]]" />
  <xsl:template match="tei:hi[following-sibling::node()[1][self::text()][. = '–']
    and following-sibling::*[1][self::tei:hi]]">
    <hi>
      <xsl:apply-templates select="@*" />
      <xsl:value-of select="."/>
      <xsl:text>–</xsl:text>
      <xsl:value-of select="following-sibling::*[1]"/>
    </hi>
  </xsl:template>
  
  <xsl:template match="text()[not(. = '–')]">
    <xsl:choose>
      <xsl:when test="following-sibling::node()[1][self::tei:ptr] and ends-with(normalize-space(), 'Anm.')">
        <xsl:value-of select="substring-before(., 'Anm.')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:analyze-string select="." regex="[„“&quot;»«]([^„^”^“^&quot;^‟^»^«]*)[”“‟&quot;»«]">
          <xsl:matching-substring>
            <quote>
              <xsl:analyze-string select="substring(., 2, string-length()-2)" regex="\[(\.\.\.|…)\]">
                <xsl:matching-substring><gap/></xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:sequence select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </quote>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:sequence select="." />
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- verschoben aus trans-4 -->
  <xsl:template match="tei:ref[@type='biblical']">
    <xsl:variable name="self" select="normalize-space(analyze-string(., '^.+[a-z] ')//*:match)"/>
    <xsl:variable name="trenn" select="." />
    <xsl:choose>
      <xsl:when test="contains(., ';') or contains(., 'u.') or contains(., 'und')">
        <xsl:variable name="parts" as="xs:string*">
          <xsl:choose>
            <xsl:when test="contains(., ';')">
              <xsl:sequence select="tokenize(., ';')"/>
            </xsl:when>
            <xsl:when test="contains(., 'u.')">
              <xsl:sequence select="tokenize(., 'u.')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="tokenize(., 'und')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="$parts">
          <ref type="biblical">
            <xsl:choose>
              <xsl:when test="matches(normalize-space(), '^\d') and contains(., ',')">
                <xsl:attribute name="cRef" select="$self || ' ' || normalize-space()" />
                <xsl:value-of select="normalize-space()"/>
              </xsl:when>
              <xsl:when test="matches(normalize-space(), '^\d')">
                <xsl:variable name="chap"
                  select="normalize-space(substring-before(substring-after($trenn, $self), ','))" />
                <xsl:attribute name="cRef" select="$self || ' ' || $chap || ',' || normalize-space()" />
                <xsl:value-of select="normalize-space()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="cRef" select="normalize-space(replace(., 'ö', ''))" />
                <xsl:value-of select="normalize-space()" />
              </xsl:otherwise>
            </xsl:choose>
          </ref>
          <xsl:if test="position() != last()">
            <xsl:choose>
              <xsl:when test="contains($trenn, ';')">
                <xsl:text>; </xsl:text>
              </xsl:when>
              <xsl:when test="contains($trenn, 'u.')">
                <xsl:text> u. </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> und </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <ref type="biblical" cRef="{normalize-space(replace(., 'ö', ''))}">
          <xsl:value-of select="."/>
        </ref>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:ref[@type = 'medieval']">
    <ref type="medieval">
      <xsl:variable name="cont">
        <xsl:value-of select="normalize-space()"/>
      </xsl:variable>
      <xsl:attribute name="cRef">
        <xsl:variable name="val" select="analyze-string($cont, '\d')"/>
        <xsl:choose>
          <xsl:when test="contains($val//*:non-match[1], ',')">
            <xsl:value-of select="substring-before($val//*:non-match[1], ',')" />
            <xsl:text>!</xsl:text>
            <xsl:value-of select="normalize-space(substring-after($val//*:non-match[1], ','))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="substring-before($val//*:non-match[1], ' ')" />
            <xsl:variable name="c" select="substring-after($val//*:non-match[1], ' ')" />
            <xsl:if test="string-length($c) &gt; 0">
              <xsl:text>!</xsl:text>
              <xsl:value-of select="normalize-space($c)" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </ref>
  </xsl:template>
  
  <xsl:template match="tei:listBibl/tei:rs">
    <bibl corresp="{@ref}">
      <xsl:sequence select="node()" />
    </bibl>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>