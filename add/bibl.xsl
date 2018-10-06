<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  <xsl:template match="tei:bibl">
    <bibl>
      <xsl:variable name="bibliography" select="doc('http://dev2.hab.de/edoc/ed000240/register/bibliography.xml')" />
      <xsl:variable name="self" select="normalize-space()" />
      <xsl:variable name="entry" select="$bibliography//tei:bibl[starts-with($self, normalize-space(tei:abbr))]"/>
      <xsl:attribute name="ref">
        <xsl:value-of select="'#'||$entry[1]/@xml:id"/>
      </xsl:attribute>
      <xsl:variable name="start">
        <xsl:value-of select="substring-after(text()[1], normalize-space($entry[1]/tei:abbr))"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="starts-with($start, ' ')">
          <xsl:value-of select="' '||normalize-space($start)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($start)"/>
        </xsl:otherwise>
      </xsl:choose>
    	<xsl:choose>
    		<xsl:when test="string-length($start) = 0">
    			<xsl:sequence select="node()[not(position() = 1 or position()=last() or self::tei:hi[@rend = 'super'])]" />
    		</xsl:when>
    		<xsl:otherwise>
    			<xsl:sequence select="node()[not(position() = 1 or position()=last())]" />
    		</xsl:otherwise>
    	</xsl:choose>
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
</xsl:stylesheet>