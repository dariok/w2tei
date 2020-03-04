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
  <xsl:include href="ref-qv.xsl" />
  
  <xsl:template match="text()[not(preceding-sibling::*[1][self::hab:mark[@ref]])]">
    <xsl:analyze-string select="." regex="[&quot;]([^&quot;]*)[&quot;]">
      <xsl:matching-substring>
        <quote>
          <xsl:sequence select="substring(., 2, string-length()-2)" />
        </quote>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
      	<xsl:analyze-string select="." regex="[‚„»]">
      		<xsl:matching-substring>
      			<hab:qs />
      		</xsl:matching-substring>
      		<xsl:non-matching-substring>
      			<xsl:analyze-string select="." regex="[‘”“‟«]">
      				<xsl:matching-substring>
      					<hab:qe />
      				</xsl:matching-substring>
      				<xsl:non-matching-substring>
      					<xsl:analyze-string select="." regex="\$">
      						<xsl:matching-substring>
      							<lb />
      						</xsl:matching-substring>
      						<xsl:non-matching-substring>
      							<xsl:sequence select="." />
      						</xsl:non-matching-substring>
      					</xsl:analyze-string>
      				</xsl:non-matching-substring>
      			</xsl:analyze-string>
      		</xsl:non-matching-substring>
      	</xsl:analyze-string>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="tei:hi[preceding-sibling::node()[1][self::tei:hi]]"/>
	<xsl:template match="tei:hi[not(preceding-sibling::node()[1][self::tei:hi])]">
		<hi>
			<xsl:apply-templates select="@rend | @style" />
			<xsl:value-of select="string-join(.
				| following-sibling::tei:hi intersect following-sibling::node()[not(self::tei:hi)][1]/preceding-sibling::*, '')"/>
		</hi>
	</xsl:template>
  
  <xsl:template match="* | @* | comment()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>