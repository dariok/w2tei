<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:include href="string-pack.xsl"/>
  
  <!-- zusammenziehen von Absätzen mit Marginalie; Vereinbarung: Marginalie steht nicht am Anfang oder Ende -->
  <xsl:template match="tei:*[tei:p and tei:note]">
    <xsl:element name="{local-name()}">
      <xsl:for-each-group select="*" group-starting-with="tei:p[not(preceding-sibling::*[1][self::tei:note])]">
        <xsl:choose>
          <xsl:when test="current-group()[self::tei:note[@place='margin']]">
            <xsl:text>
        </xsl:text>
            <p>
              <xsl:apply-templates select="current-group()[self::tei:p]/node() | current-group()[self::tei:note]" />
            </p>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text()[not(ancestor::tei:note or ancestor::tei:app)]">
    <xsl:analyze-string select="." regex="\|">
      <xsl:matching-substring>
        <wt:pb />
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="." />
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="tei:app">
    <app>
      <xsl:apply-templates select="@*" />
      <xsl:for-each-group group-ending-with="wt:notes" select="node()">
        <rdg>
          <xsl:sequence select="current-group()[not(self::wt:notes)
            and not(preceding-sibling::wt:comment
            or self::wt:comment)]" />
          <xsl:if test="current-group()[self::wt:comment]">
            <note type="comment">
              <xsl:sequence select="current-group()[preceding-sibling::wt:comment]" />
            </note>
          </xsl:if>
        </rdg>
      </xsl:for-each-group>
    </app>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>