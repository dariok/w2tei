<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wdb="https://github.com/dariok/wdbplus"
  xmlns:hab="http://diglib.hab.de"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:include href="styles-inc.xsl"/>
  <xsl:include href="bibl.xsl"/>
  
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
    <xsl:apply-templates select="node()" />
  </xsl:template>
  
  <xsl:template match="text()[not(preceding-sibling::*[1][self::hab:mark[@ref]])]">
    <xsl:analyze-string select="." regex="[„“&quot;»«]([^”^“^&quot;‟^»^«]*)[”“‟&quot;»«]">
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
  
  <xsl:template match="hab:bm" />
  <xsl:template match="hab:mark[not(@ref)]" />
  <xsl:template match="text()[preceding-sibling::*[1][self::hab:mark[@ref]]]" />
  <xsl:template match="hab:mark[@ref]">
    <xsl:variable name="ref" select="substring-before(substring-after(@ref, 'REF '), ' ')" />
    <xsl:variable name="target" select="//hab:bm[@name = $ref]/following-sibling::*[1]" />
    <xsl:choose>
      <xsl:when test="$target/@type='footnote'">
        <ptr type="wdb" target="#{$target/@xml:id}" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!--<xsl:template match="tei:rs">
    <!-\- TODO ref aus Register auslesen -\->
  	<xsl:choose>
  		<xsl:when test="preceding-sibling::node()[1][self::tei:rs]" />
  		<xsl:when test = "following-sibling::node()[1][self::tei:rs]">
  			<rs>
  				<xsl:sequence select="@type" />
  				<xsl:value-of select="."/>
  				<xsl:value-of select="following-sibling::tei:rs intersect
  					following-sibling::node()[not(self::tei:rs)][1]/preceding-sibling::node()"/>
  			</rs>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:sequence select="."/>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>-->
	<xsl:template match="tei:rs[not(preceding-sibling::node()[1][self::tei:rs])]">
		<rs type="{@type}">
			<xsl:choose>
				<xsl:when test="following-sibling::node()[not(self::tei:rs)]">
					<xsl:sequence select="node()[not(self::comment())]
						| (following-sibling::tei:rs intersect
						following-sibling::text()[1]/preceding-sibling::tei:rs)/text()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="node()[not(self::comment())]
						| following-sibling::tei:rs/node()" />
				</xsl:otherwise>
			</xsl:choose>
		</rs>
	</xsl:template>
	<xsl:template match="tei:rs[preceding-sibling::node()[1][self::tei:rs]]" />
  
  <xsl:template match="* | @* | comment()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>