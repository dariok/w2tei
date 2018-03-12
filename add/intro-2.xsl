<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wdb="https://github.com/dariok/wdbplus"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs math"
  version="3.0">
  <xsl:include href="styles-inc.xsl"/>
  
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
    <xsl:apply-templates select="node()" />
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:analyze-string select="." regex="[„“]([^”^“^&quot;]*)[”“&quot;]">
      <xsl:matching-substring>
        <quote>
          <xsl:analyze-string select="substring(., 2, string-length()-2)" regex="\[\.\.\.\]">
            <xsl:matching-substring><gap/></xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:analyze-string select="." regex="\$">
                <xsl:matching-substring>
                  <lb />
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </quote>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:sequence select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="tei:bibl">
    <bibl>
      <xsl:variable name="bibliography" select="doc('http://dev2.hab.de/edoc/ed000240/register/bibliography.xml')" />
      <xsl:variable name="self" select="normalize-space()" />
      <xsl:variable name="entry" select="$bibliography//tei:bibl[starts-with($self, normalize-space(tei:abbr))]"/>
      <xsl:attribute name="ref">
        <xsl:value-of select="'#'||$entry[1]/@xml:id"/>
      </xsl:attribute>
      <xsl:value-of select="normalize-space(substring-after(text()[1], normalize-space($entry[1]/tei:abbr)))"/>
      <xsl:sequence select="node()[not(position() = 1 or position()=last())]" />
      <xsl:choose>
        <xsl:when test="count(node()) = 1" />
        <xsl:when test="node()[last()][self::text()]">
          <xsl:variable name="text" select="text()[last()]"/>
          <xsl:choose>
            <xsl:when test="starts-with($text, ' ')">
              <xsl:value-of select="' '||normalize-space($text)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($text)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="node()[last()]" />
        </xsl:otherwise>
      </xsl:choose>
    </bibl>
  </xsl:template>
  
  <xsl:template match="* | @* | comment()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>