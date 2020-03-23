<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:include href="bibl.xsl#1"/>
  
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/kgk.rnc"</xsl:processing-instruction>
    <xsl:apply-templates select="node()" />
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:analyze-string select="." regex="[&lt;\[]?(\.{{3}}|…)[&gt;\]]?">
      <xsl:matching-substring>
        <gap />
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <!-- aus ks-ptr.xsl -->
        <xsl:analyze-string select="." regex="EE(\d+[AB]?)_(text|intro)([^#]+)?#?#">
          <xsl:matching-substring>
            <xsl:variable name="file">
              <xsl:variable name="num" select="analyze-string(regex-group(1), '\d+')//*:match"/>
              <xsl:variable name="lit" select="analyze-string(regex-group(1), '[A-Z]')//*:match"/>
              <xsl:variable name="nr" select="format-number(xs:integer($num), '000')" />
              <xsl:variable name="part">
                <xsl:choose>
                  <xsl:when test="regex-group(2) = 'text'">transcript</xsl:when>
                  <xsl:otherwise>introduction</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="r3" select="regex-group(3)" />
              <xsl:variable name="tail">
                <xsl:analyze-string select="regex-group(3)" regex="_.nm\.? ?(\d+|[a-z]+)-?[a-z]?">
                  <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/> 
                  </xsl:matching-substring>
                </xsl:analyze-string>
              </xsl:variable>
              <xsl:variable name="type" select="if($tail!='') 
                then '#' || (if ($tail castable as xs:integer) then 'n' else 'c') || $tail
                else ''"/>
              <xsl:value-of select="'../' || $nr || $lit || '/' || $nr || $lit || '_' || $part || '.xml' || $type"/>
            </xsl:variable>
            <ptr type="wdb">
              <xsl:choose>
                <xsl:when test="string-length($file) &gt; 20">
                  <xsl:attribute name="target" select="$file" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$file"/>
                </xsl:otherwise>
              </xsl:choose>
            </ptr>
            <xsl:if test="string-length(regex-group(3)) > 10"><xsl:value-of select="'##' || regex-group(3) || '##'" /></xsl:if>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="." />
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="@* | * | comment() | processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>