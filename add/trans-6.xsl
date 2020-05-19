<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
    <xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/kgk.rnc"</xsl:processing-instruction>
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
      <!--<xsl:apply-templates select="*[not(self::tei:listWit)]" />-->
      <xsl:variable name="val" select="substring-after(substring-before(/tei:TEI/@xml:id, '_tr'), '240_')"/>
      <xsl:if test="//@wit">
        <xsl:text>
        </xsl:text>
        <listWit type="other">
          <xsl:variable name="wits" as="xs:string+">
            <xsl:for-each select="//@wit">
              <xsl:sequence select="tokenize(., ' ')" />  
            </xsl:for-each>
          </xsl:variable>
          <xsl:for-each select="distinct-values($wits)[not(. = '#')]">
            <xsl:text>
          </xsl:text>
            <witness corresp="{$val || '_introduction.xml' || .}">
              <xsl:if test="substring-after(., '#') != ''">
                <xsl:attribute name="xml:id" select="substring-after(., '#')" />
              </xsl:if>
            </witness>
          </xsl:for-each>
        </listWit>
      </xsl:if>
    </sourceDesc>
  </xsl:template>
  
  <xsl:template match="tei:w">
    <xsl:text>
            </xsl:text>
    <xsl:copy>
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:analyze-string select="." regex="([\d\sr])-([\d\sv])">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1) || '–' || regex-group(2)"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:analyze-string select="." regex="\w+'.+?'\w?">
          <xsl:matching-substring>
            <expan>
              <xsl:analyze-string select="." regex="'.+'">
                <xsl:matching-substring><ex><xsl:value-of select="substring(substring(., 2), 1, string-length(.)-2)"/></ex></xsl:matching-substring>
                <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
              </xsl:analyze-string>
            </expan>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:analyze-string select="." regex="VD16 [A-Z] ?\d+">
              <xsl:matching-substring>
                <idno type="vd16">
                  <xsl:choose>
                    <xsl:when test="contains(substring-after(., ' '), ' ')">
                      <xsl:value-of select="substring-after(., ' ')"/>
                    </xsl:when>
                    <xsl:when test="contains(., 'ZV')">
                      <xsl:value-of select="'ZV ' || substring-after(., 'ZV')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="substring(., 6, 1) || ' ' || substring(., 7, string-length()-6)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </idno>
              </xsl:matching-substring>
              <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="\[?(\.\.\.|…)\]?">
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
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
</xsl:stylesheet>