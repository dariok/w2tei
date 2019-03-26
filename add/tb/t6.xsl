<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:template match="tei:app">
    <xsl:choose>
      <xsl:when test="tei:add and not(tei:del)">
        <add>
          <xsl:sequence select="tei:add/@*" />
          <xsl:apply-templates select="tei:lem/node()" />
          <xsl:apply-templates select="tei:note" />
        </add>
      </xsl:when>
      <xsl:when test="tei:add">
        <subst>
          <add>
            <xsl:sequence select="tei:add/@*" />
            <xsl:apply-templates select="tei:lem/node()" />
          </add>
          <xsl:apply-templates select="tei:del" />
        </subst>
      </xsl:when>
      <xsl:when test="tei:subst">
        <subst>
          <add>
            <xsl:sequence select="tei:subst/@*" />
            <xsl:apply-templates select="tei:lem/node()" />
          </add>
          <del>
            <xsl:apply-templates select="tei:subst/node()" />
          </del>
        </subst>
      </xsl:when>
      <xsl:when test="tei:corr">
        <choice>
          <sic>
            <xsl:apply-templates select="tei:corr/node()" />
          </sic>
          <corr>
            <xsl:sequence select="tei:corr/@*" />
            <xsl:apply-templates select="tei:lem/node()" />
          </corr>
        </choice>
      </xsl:when>
      <xsl:when test="tei:del">
        <xsl:apply-templates select="tei:lem/node()" />
        <xsl:apply-templates select="tei:del" />
      </xsl:when>
      <xsl:when test="tei:seg">
        <seg>
          <xsl:sequence select="tei:seg/@*" />
          <xsl:apply-templates select="tei:lem/node()" />
        </seg>
      </xsl:when>
      <xsl:when test="tei:lem and tei:rdg[@wit]">
        <app>
          <lem>
            <xsl:apply-templates select="wt:note" mode="wit" />
            <xsl:apply-templates select="tei:lem/node()" />
          </lem>
          <xsl:apply-templates select="tei:rdg" />
        </app>
      </xsl:when>
      <xsl:when test="wt:note">
        <xsl:apply-templates select="tei:lem/node()" />
        <note type="crit_app">
          <xsl:apply-templates select="wt:note" />
        </note>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="wt:note" mode="wit">
    <xsl:attribute name="wit" select="'#' || replace(normalize-space(), ', ', '#')" />
  </xsl:template>
  <xsl:template match="wt:note">
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="wt:note/wt:orig">
    <xsl:if test="normalize-space(preceding-sibling::text()) != ''">
      <xsl:text>: </xsl:text>
    </xsl:if>
    <orig>
      <xsl:apply-templates />
    </orig>
  </xsl:template>
  
  <xsl:template match="text()[ancestor::tei:body]">
    <xsl:variable name="r2" select="'\{\w+\}'"/>
    <xsl:variable name="r1" select="'\w+\{.+?\}\w*'"/>
    <xsl:analyze-string select="." regex="{$r1}">
      <xsl:matching-substring>
        <expan>
          <xsl:analyze-string select="." regex="{$r2}">
            <xsl:matching-substring>
              <ex><xsl:value-of select="substring(substring(., 2), 1, string-length()-2)"/></ex>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:value-of select="." />
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </expan>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:analyze-string select="." regex="\[\[[^\]]+\]\]">
          <xsl:matching-substring>
            <supplied>
              <xsl:value-of select="substring(., 3, string-length() - 4)"/>
            </supplied>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:analyze-string select="." regex="\[[^\]]+\]">
              <xsl:matching-substring>
                <unclear>
                  <xsl:value-of select="substring(., 2, string-length() - 2)" />
                </unclear>
              </xsl:matching-substring>
              <xsl:non-matching-substring>
                <xsl:value-of select="."/>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="tei:del/@place">
    <xsl:attribute name="rend">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="tei:del/@extent">
    <xsl:if test=". != ''">
      <xsl:attribute name="extent" select="." />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:cit">
    <cit>
      <quote>
        <xsl:apply-templates select="node()[not(self::tei:bibl)]" />
      </quote>
      <xsl:apply-templates select="tei:bibl" />
    </cit>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <pb n="{normalize-space(translate(@n, ' ', ' '))}" />
  </xsl:template>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>