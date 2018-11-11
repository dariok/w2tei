<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
	
	<xsl:template match="/">
		<xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
		<xsl:apply-templates select="node()" />
	</xsl:template>
	
	<!-- pretty print -->
	<xsl:template match="tei:teiHeader | tei:text">
		<xsl:text>
	</xsl:text>
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:teiHeader/* | tei:text/*">
		<xsl:text>
		</xsl:text>
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:teiHeader/*/*[not(self::tei:sourceDesc)]">
		<xsl:text>
			</xsl:text>
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:teiHeader/*/*/*">
		<xsl:text>
				</xsl:text>
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
  
  <xsl:template match="tei:*">
    <xsl:variable name="num">
      <xsl:choose>
        <xsl:when test="self::tei:div">
          <xsl:value-of select="'d' || (count(preceding::tei:div | ancestor::tei:div) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:p">
          <xsl:value-of select="'p' || (count(preceding::tei:p) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:cell">
          <xsl:value-of select="'cell' || (count(preceding::tei:cell) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:item">
          <xsl:value-of select="'i' || (count(preceding::tei:item) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:titlePart or self::tei:imprimatur">
          <xsl:value-of select="'tit' || (count(preceding::tei:titlePart | preceding::tei:imprimatur) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:opener or self::tei:closer or self::tei:postscript">
          <xsl:value-of select="'opc' || (count(preceding::tei:opener | preceding::tei:closer | preceding::tei:postscript) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:epigraph or self::tei:salute">
          <xsl:value-of select="'eps' || (count(preceding::tei:epigraph | preceding::tei:salute) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:l">
          <xsl:value-of select="'l' || (count(preceding::tei:l) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:note[@type='footnote']">
          <xsl:value-of select="'nn' || (count(preceding::tei:note[@type='footnote']) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:pb">
          <xsl:value-of select="'pag' || (count(preceding::tei:pb) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:lb">
          <xsl:value-of select="'z' || (count(preceding::tei:lb) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:cit">
          <xsl:value-of select="'cit' || (count(preceding::tei:cit) + 1)"/>
        </xsl:when>
        <xsl:when test="self::tei:head or self::tei:label">
          <xsl:value-of select="'hl' || (count(preceding::tei:label | preceding::tei:head) + 1)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
  	<xsl:element name="{local-name()}">
      <xsl:if test="not(@xml:id) and string-length($num) &gt; 0">
        <xsl:attribute name="xml:id" select="$num" />
      </xsl:if>
      <xsl:apply-templates select="@* | node()" />
    </xsl:element>
  </xsl:template>
	
	<xsl:template match="tei:note[@type = 'footnote']/tei:hi[contains(@style, 'italic')]">
		<term type="term"><xsl:apply-templates /></term>
	</xsl:template>
  
  <xsl:template match="* | @* | comment() | processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
	
	<xsl:template match="tei:sourceDesc">
		<xsl:text>
			</xsl:text>
		<sourceDesc>
			<xsl:apply-templates select="*[not(self::tei:listWit)]" />
			<xsl:variable name="val" select="substring-after(substring-before(/tei:TEI/@xml:id, '_tr'), '240_')"/>
			<xsl:if test="//@wit">
				<xsl:text>
				</xsl:text>
				<listWit>
					<xsl:variable name="wits" as="xs:string+">
						<xsl:for-each select="//@wit">
							<xsl:sequence select="tokenize(., ' ')" />	
						</xsl:for-each>
					</xsl:variable>
					<xsl:for-each select="distinct-values($wits)[not(. = '#')]">
						<xsl:text>
					</xsl:text>
						<witness corresp="{$val || '_introduction.xml' || .}">
							<xsl:attribute name="xml:id" select="substring-after(., '#')" />
						</witness>
					</xsl:for-each>
				</listWit>
			</xsl:if>
		</sourceDesc>
	</xsl:template>
  
  <xsl:template match="text()">
    <xsl:analyze-string select="." regex="([\d\sr])-([\d\sv])">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1) || '–' || regex-group(2)"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
</xsl:stylesheet>