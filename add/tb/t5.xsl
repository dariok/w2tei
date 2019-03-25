<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:include href="string-pack.xsl"/>
  
  <xsl:template match="tei:anchor">
    <xsl:variable name="peer">
      <xsl:choose>
        <xsl:when test="ends-with(@xml:id, 'e')">
          <xsl:variable name="id" select="substring-before(@xml:id, 'e')" />
          <xsl:sequence select="preceding-sibling::tei:anchor[@xml:id = $id]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="id" select="@xml:id || 'e'"/>
          <xsl:sequence select="following-sibling::tei:anchor[@xml:id = $id]" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$peer/*[1][self::tei:anchor]" />
      <xsl:otherwise>
        <xsl:sequence select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="text()[preceding-sibling::tei:anchor[1][not(ends-with(@xml:id, 'e'))]
    and following-sibling::tei:anchor[1][ends-with(@xml:id, 'e')]]">
    <xsl:variable name="pre" select="preceding-sibling::tei:anchor[1]/@xml:id"/>
    <xsl:choose>
      <xsl:when test="following-sibling::tei:anchor/@xml:id = $pre||'e'" />
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="text()[following-sibling::node()[1][self::tei:app]]">
    <xsl:value-of select="xstring:substring-before-last(., ' ') || ' '"/>
  </xsl:template>
  
  <xsl:template match="tei:app">
    <app>
      <xsl:apply-templates select="@*" />
      
      <xsl:variable name="s" select="substring-after(@from, '#')" />
      <xsl:variable name="e" select="substring-after(@to, '#')" />
      <xsl:if test="preceding-sibling::tei:anchor[@xml:id = $s] or not(@from)">
        <lem>
          <xsl:choose>
            <xsl:when test="@from">
              <xsl:sequence select="id($s)/following-sibling::node()
                intersect id($e)/preceding-sibling::node()"></xsl:sequence>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="xstring:substring-after-last(preceding-sibling::node()[1], ' ')"/>
            </xsl:otherwise>
          </xsl:choose>
        </lem>
      </xsl:if>
      <xsl:apply-templates select="tei:rdg" />
      <xsl:apply-templates select="tei:rdg/tei:note" />
    </app>
  </xsl:template>
  
  <xsl:template match="tei:rdg">
    <xsl:choose>
      <xsl:when test="wt:action[@val = 'ergänzt']">
        <add>
          <xsl:apply-templates select="wt:place" />
          <xsl:apply-templates select="wt:source" />
        </add>
        <xsl:if test="wt:action[@val = 'gestr.']">
          <del>
            <xsl:sequence select="wt:orig/node()" />
          </del>
        </xsl:if>
      </xsl:when>
      <xsl:when test="wt:action[@val = 'gestr.']">
        <del>
          <xsl:attribute name="extent">
            <xsl:choose>
              <xsl:when test="matches(., 'ein Wort')">word</xsl:when>
              <xsl:when test="matches(., 'Wörter')">words</xsl:when>
              <xsl:when test="matches(., 'ein Buchstaben')">letter</xsl:when>
              <xsl:when test="matches(., 'Buchstaben')">letters</xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="wt:place" />
          <xsl:apply-templates select="wt:source" />
          <xsl:sequence select="wt:orig/node()" />
        </del>
      </xsl:when>
      <xsl:when test="wt:action[@val = 'korr.']">
        <subst>
          <xsl:apply-templates select="wt:place" />
          <xsl:apply-templates select="wt:source" />
          <xsl:sequence select="wt:orig/node()" />
        </subst>
      </xsl:when>
      <xsl:when test="wt:action[@val = 'konj.']">
        <corr>
          <xsl:apply-templates select="wt:source" />
          <xsl:sequence select="wt:orig/node()" />
        </corr>
      </xsl:when>
      <xsl:when test="not(wt:action) and wt:source">
        <seg>
          <xsl:apply-templates select="wt:source" />
        </seg>
      </xsl:when>
      <xsl:when test="wt:orig">
        <rdg>
          <xsl:variable name="cont" select="(text()[last()], '.')[1]" />
          <xsl:variable name="text" select="normalize-space(xstring:substring-before-if-ends($cont, '.'))"/>
          <xsl:attribute name="wit" select="'#' || replace($text, ', ', ' #')" />
          <xsl:sequence select="wt:orig/node()" />
        </rdg>
      </xsl:when>
      <xsl:otherwise>
        <wt:note>
          <xsl:sequence select="node()" />
        </wt:note>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="wt:source">
    <xsl:variable name="val" select="normalize-space(@val)" />
    <xsl:attribute name="resp">
      <xsl:choose>
        <xsl:when test="$val = 'anderer Hand'">other</xsl:when>
        <xsl:when test="ends-with($val, 's Hand')">
          <xsl:value-of select="substring-before($val, 's Hand')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$val"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="wt:place">
    <xsl:attribute name="place">
      <xsl:choose>
        <xsl:when test="@val = 'über der Zeile'">supralinear</xsl:when>
        <xsl:when test="@val = 'unter der Zeile'">sublinear</xsl:when>
        <xsl:when test="@val = 'in der Zeile'">inline</xsl:when>
        <xsl:when test="@val = 'am Rand'">margin</xsl:when>
        <xsl:when test="@val = 'am Seitenanfang'">top</xsl:when>
        <xsl:when test="@val = 'am Seitenende'">bottom</xsl:when>
        <xsl:when test="@val = 'davor'">before</xsl:when>
        <xsl:when test="@val = 'danach'">after</xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="wt:*" mode="text">
    <xsl:value-of select="@val"/>
  </xsl:template>
  <xsl:template match="text()" mode="text">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="tei:*[wt:qs]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each-group select="node()" group-starting-with="wt:qs">
        <xsl:choose>
          <xsl:when test="current-group()[self::wt:qs]">
            <quote>
              <xsl:apply-templates select="current-group()[not(self::wt:*) and following-sibling::wt:qe]" />
            </quote>
            <xsl:apply-templates select="current-group()[preceding-sibling::wt:qe]" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>