<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:include href="string-pack.xsl"/>
  
  <xsl:template match="tei:note[@type = 'crit_app']">
    <xsl:variable name="text" select="xstring:substring-after-last(preceding-sibling::text()[1], ' ')"/>
    <xsl:call-template name="critapp">
      <xsl:with-param name="note" select="." />
      <xsl:with-param name="text" select="$text" />
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="text()[following-sibling::node()[1][self::tei:note[@type='crit_app']]]">
    <xsl:value-of select="xstring:substring-before-last(., ' ') || ' '" />
  </xsl:template>
  
  <xsl:template match="tei:anchor" />
  <xsl:template match="text()[preceding-sibling::tei:anchor and following-sibling::tei:anchor]">
    <xsl:variable name="pre" select="preceding-sibling::tei:anchor[1]/@xml:id"/>
    <xsl:choose>
      <xsl:when test="following-sibling::tei:anchor/@xml:id = $pre||'e'" />
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:span">
    <xsl:call-template name="critapp">
      <xsl:with-param name="text" select="id(substring-after(@from, '#'))/following-sibling::node()
        intersect id(substring-after(@to, '#'))/preceding-sibling::node()" />
      <xsl:with-param name="note" select="." />
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="wt:*" mode="text">
    <xsl:value-of select="@val"/>
  </xsl:template>
  <xsl:template match="text()" mode="text">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template name="critapp">
    <xsl:param name="text" />
    <xsl:param name="note" />
    
    <xsl:choose>
      <xsl:when test="$note/wt:action[@val = 'ergänzt']">
        <add>
          
        </add>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="text" />
      </xsl:otherwise>
      <!--<xsl:when test="matches($note, 'ergänzt')">
				<add>
					<xsl:attribute name="place">
						<xsl:choose>
							<xsl:when test="matches(., 'am Rand')">margin</xsl:when>
							<xsl:when test="matches(., 'über der Zeile')">above</xsl:when>
							<xsl:when test="matches(., 'unter der Zeile')">below</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test="contains(., 'von anderer Hand')">
							<xsl:attribute name="hand">#other</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(., 'von')">
							<xsl:attribute name="hand" select="'#' || substring-before(substring-after($note, 'von '), ' ')" />
						</xsl:when>
					</xsl:choose>
					<xsl:sequence select="$text" /></add>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$note[self::tei:note]">
						<xsl:sequence select="$text" />
						<xsl:sequence select="$note" />
					</xsl:when>
					<xsl:otherwise>
						<anchor type="crit_app">
							<xsl:attribute name="xml:id" select="substring-after($note/@from, '#')" />
						</anchor>
						<xsl:sequence select="$text" />
						<anchor type="crit_app">
							<xsl:attribute name="xml:id" select="substring-after($note/@to, '#')" />
						</anchor>
						<xsl:sequence select="$note" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>-->
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:*[wt:qs]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each-group select="node()" group-starting-with="wt:qs">
        <xsl:choose>
          <xsl:when test="current-group()[self::wt:qs]">
            <quote>
              <xsl:sequence select="current-group()[not(self::wt:*) and following-sibling::wt:qe]" />
            </quote>
            <xsl:sequence select="current-group()[preceding-sibling::wt:qe]" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="current-group()" />
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