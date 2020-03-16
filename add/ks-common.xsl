<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:hab="http://diglib.hab.de"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
  xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:include href="styles-inc.xsl"/>
  
  <xsl:variable name="fline" as="xs:string">
    <xsl:value-of select="wt:string(//pkg:part[@pkg:name='titelei']//w:p[1])"/>
  </xsl:variable>
  <xsl:variable name="nr">
    <xsl:value-of select="normalize-space(hab:rmSquare(substring-after($fline, 'Nr.')))"/>
  </xsl:variable>
  <xsl:variable name="ee">
    <xsl:variable name="nro" select="substring-before(substring-after($fline, 'EE '), ' ')"/>
    <xsl:choose>
      <xsl:when test="$nro castable as xs:integer">
        <xsl:value-of select="format-number(number($nro), '000')"/>
      </xsl:when>
      <xsl:when test="string-length($nro) &lt; 4">
        <xsl:value-of select="concat('0', $nro)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$nro"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/">
    <TEI xmlns="http://www.tei-c.org/ns/1.0"
      n="{$nr}">
      <xsl:attribute name="xml:id">
        <xsl:choose>
          <xsl:when test="//w:footnote[descendant::w:t] or //w:p[wt:is(., 'berschrift1', 'p') and wt:contains(., 'Text')]">
            <xsl:value-of select="concat('edoc_ed000240_', $ee, '_transcript')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('edoc_ed000240_', $ee, '_introduction')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="titel" select="//pkg:part[@pkg:name = 'titelei']//w:p[wt:is(., 'KSEE-Titel', 'p')]" />
      <xsl:variable name="title">
        <xsl:apply-templates select="$titel[2]//w:t" mode="mTitle" />
      </xsl:variable>
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>
              <xsl:sequence select="$title" />
              <xsl:apply-templates select="$titel[3]" mode="date" />
            </title>
            <!-- Kurztitel erzeugen; 2017-08-07 DK -->
            <title type="short">
              <xsl:if test="//w:p[hab:isHead(., 1)][1]//w:t = 'Referenz'">
                <xsl:text>Verschollen: </xsl:text>
              </xsl:if>
              <!--<xsl:choose>
                <xsl:when test="$title/*:lb">
                  <xsl:value-of select="$title/text()[following-sibling::*:lb]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$title"/>
                </xsl:otherwise>
              </xsl:choose>-->
              <xsl:for-each select="$title/node()">
                <xsl:choose>
                  <xsl:when test="self::*:lb">
                    <xsl:text>.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:choose>
                <xsl:when
                  test="//w:p[hab:isHead(., 1)][1]//w:t = 'Referenz' or ends-with(wt:string(//w:p[wt:is(., 'KSEE-Titel')][3]), ']')">
                  <xsl:text> [</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text> (</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:variable name="dpline">
                <xsl:apply-templates select="$titel[3]" mode="date"/>
              </xsl:variable>
              <xsl:apply-templates select="$dpline/*:date" mode="header"/>
              <xsl:choose>
                <xsl:when
                  test="//w:p[hab:isHead(., 1)][1]//w:t = 'Referenz' or ends-with(wt:string(//w:p[wt:is(., 'KSEE-Titel')][3]), ']')">
                  <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>)</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </title>
            <xsl:apply-templates select="$titel[wt:starts(., 'Bearb')]"
              mode="head"/>
          </titleStmt>
          <publicationStmt>
            <publisher>Herzog August Bibliothek Wolfenbüttel (<ptr target="http://www.hab.de"/>)</publisher>
            <date when="2017" type="created"/>
            <distributor>Herzog August Bibliothek Wolfenbüttel</distributor>
            <availability status="restricted">
              <p>Herzog August Bibliothek Wolfenbüttel (<ref target="http://diglib.hab.de/?link=012"
                  >copyright information</ref>)</p>
            </availability>
          </publicationStmt>
          <sourceDesc>
            <p>born digital</p>
            <xsl:if test="//w:p[hab:isHead(., 1) and wt:contains(., 'Referenz')]">
              <msDesc>
                <physDesc>
                  <objectDesc form="codex_lost"/>
                </physDesc>
              </msDesc>
            </xsl:if>
          </sourceDesc>
        </fileDesc>
        <encodingDesc>
          <p>Zeichen aus der Private Use Area entsprechen MUFI 3.0 (http://mufi.info)</p>
          <projectDesc>
            <p xml:id="kgk">
              <ref target="http://diglib.hab.de/edoc/ed000240/start.htm">Kritische Gesamtausgabe der
						Schriften und Briefe Andreas Bodensteins von Karlstadt</ref>
            </p>
          </projectDesc>
          <tagsDecl>
            <rendition xml:id="f">Full width text</rendition>
            <rendition xml:id="c">Text within a full width region that is centered</rendition>
            <rendition xml:id="l">Text aligned left in a full width region</rendition>
            <rendition xml:id="r">Text aligned right in a full width region</rendition>
            <rendition xml:id="ll">Text aligned left (or justified) in a left column</rendition>
            <rendition xml:id="lc">Text centered in a left column</rendition>
            <rendition xml:id="lr">Text aligned right in a left column</rendition>
            <rendition xml:id="lh">Text aligned left (or justified) in a left column with the first line hanging</rendition>
            <rendition xml:id="rl">Text aligned left (or justified) in a right column</rendition>
            <rendition xml:id="rc">Text centered in a right column</rendition>
            <rendition xml:id="rr">Text aligned right in a right column</rendition>
            <rendition xml:id="rh">Text aligned left (or justified) in a right column with the first line hanging</rendition>
            <rendition xml:id="cl">Text aligned left (or justified) in a middle or centered column</rendition>
            <rendition xml:id="cc">Text centered in a middle or centered column</rendition>
            <rendition xml:id="cr">Text aligned right in a middle or centered column</rendition>
            <rendition xml:id="ch">Text aligned left (or justified) in a middle or centered column with the first line hanging</rendition>
          </tagsDecl>
        </encodingDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="//pkg:part[contains(@pkg:name, 'word/document.xml')]"/>
        </body>
      </text>
      <xsl:sequence select="//pkg:part[not(contains(@pkg:name, 'word/document.xml') or @pkg:name='titelei')]"/>
    </TEI>
  </xsl:template>
  <!-- Ende root -->
  
  <!-- Kopf-Zeug -->
  <!-- Bearbeiter/Autor; 2017-05-03 DK -->
  <xsl:template match="w:p[wt:is(., 'KSEE-Titel') and wt:starts(., 'Bearb')]" mode="head">
    <xsl:variable name="aut" select="substring-after(wt:string(.), 'von')"/>
    <xsl:analyze-string select="$aut" regex="(,|und)">
      <xsl:non-matching-substring>
        <author>
          <xsl:value-of select="normalize-space()"/>
        </author>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  <xsl:template match="w:p[wt:is(., 'KSEE-Titel')]" mode="date">
    <xsl:variable name="pdline" select="wt:string(.)"/>
    <!-- RegEx aktualisiert; hoffentlich geht das auf eXist...; 2017-08-07 DK -->
    <xsl:analyze-string select="normalize-space($pdline)" regex="(?:([\[\]A-Za-z ]+), )?([\[\]\w\sä\?,\./]+)">
      <xsl:matching-substring>
        <xsl:if test="string-length(regex-group(1)) &gt; 1">
          <placeName>
            <xsl:if test="starts-with(regex-group(1), '[')">
              <xsl:attribute name="cert">unknown</xsl:attribute>
            </xsl:if>
            <xsl:analyze-string select="regex-group(1)" regex="\[?([\w\?]+)\]?">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </placeName>
        </xsl:if>
        <date>
          <xsl:variable name="year" select="substring-before(regex-group(2), ', ')"/>
          <xsl:variable name="date" select="substring-after(regex-group(2), ',')"/>
          <xsl:variable name="month">
            <xsl:analyze-string select="$date" regex=".?\[?(.*)? \[?(\w+)\]?">
              <xsl:matching-substring>
                <xsl:choose>
                  <xsl:when test="starts-with(regex-group(2), 'Januar')">01</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'Februar')">02</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'März')">03</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'April')">04</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'Mai')">05</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'Juni')">06</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'Juli')">07</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'August')">08</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'September')">09</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'Oktober')">10</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'November')">11</xsl:when>
                  <xsl:when test="starts-with(regex-group(2), 'Dezember')">12</xsl:when>
                </xsl:choose>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:variable>
          <xsl:variable name="day">
            <xsl:analyze-string select="$date" regex=".?(\[?.*)? \[?(\w+)\]?">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:variable>
          <xsl:variable name="att">
            <xsl:choose>
              <xsl:when test="contains($date, 'vor')">notAfter</xsl:when>
              <xsl:when test="contains($date, 'nach')">notBefore</xsl:when>
              <xsl:otherwise>when</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="{$att}">
            <xsl:variable name="numYear">
              <xsl:analyze-string select="$year" regex="\[?(\d+)\]?">
                <xsl:matching-substring>
                  <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="substring-before($day, '.') castable as xs:integer">
                <xsl:variable name="num" select="number(substring-before($day, '.'))"/>
                <xsl:value-of select="concat($numYear, '-', $month, '-', format-number($num, '00'))"/>
              </xsl:when>
              <xsl:when test="substring-after(substring-before($day, '.'), ' ') castable as xs:integer">
                <xsl:variable name="num"
                  select="number(substring-after(substring-before($day, '.'), ' '))"/>
                <xsl:value-of select="concat($numYear, '-', $month, '-', format-number($num, '00'))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($numYear, '-', $month)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="starts-with(regex-group(2), '[') and ends-with(regex-group(2), ']')">
            <xsl:attribute name="cert">unknown</xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="starts-with($year, '[') and ends-with($year, ']')">
              <supplied>
                <xsl:value-of select="substring-after(substring-before($year, ']'), '[')"/>
              </supplied>
            </xsl:when>
            <xsl:when test="ends-with($year, ']')">
              <supplied>
                <xsl:value-of select="substring-before($year, ']')"/>
              </supplied>
            </xsl:when>
            <xsl:when test="starts-with($year, '[')">
              <xsl:value-of select="substring-after($year, '[')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$year"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>, </xsl:text>
          <xsl:choose>
            <xsl:when test="starts-with(normalize-space($date), '[') and ends-with($date, ']')">
              <supplied>
                <xsl:value-of select="substring-after(substring-before($date, ']'), '[')"/>
              </supplied>
            </xsl:when>
            <xsl:when test="starts-with($year, '[') and ends-with($date, ']')">
              <xsl:value-of select="normalize-space(substring-before($date, ']'))"/>
            </xsl:when>
            <xsl:when test="starts-with(normalize-space($day), '[') and ends-with($day, ']')">
              <supplied>
                <xsl:value-of select="substring-after($day, '[')"/>
              </supplied>
              <xsl:value-of select="$month"/>
            </xsl:when>
            <xsl:when test="ends-with($date, ']')">
              <xsl:value-of select="normalize-space(substring-before($date, ']'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space($date)"/>
            </xsl:otherwise>
          </xsl:choose>
        </date>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  <!-- Texte aus dem Header nicht ausgeben; 2017-05-151 DK -->
  <xsl:template match="w:p[wt:is(., 'KSEE-Titel')]"/>
  <!-- ENDE Kopf-Zeug -->
  
  <!-- neu 2017-10-15 DK -->
  <xsl:template match="w:p[wt:is(., 'KSZitatblock')]">
    <cit>
      <xsl:apply-templates
        select="w:r[not(wt:is(., 'KSbibliographischeAngabe', 'r') or wt:is(., 'EndnoteReference', 'r'))]"/>
      <xsl:apply-templates
        select="w:r[wt:is(., 'KSbibliographischeAngabe', 'r') or wt:is(., 'EndnoteReference', 'r')]"/>
    </cit>
  </xsl:template>
  <xsl:template match="w:br[ancestor::w:p[wt:is(., 'KSZitatblock')]]">
    <xsl:text>$</xsl:text>
  </xsl:template>
</xsl:stylesheet>
