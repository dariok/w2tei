<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
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
  
  <xsl:template match="* | @* | comment()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>