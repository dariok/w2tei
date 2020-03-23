<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wdb="https://github.com/dariok/wdbplus"
  xmlns:hab="http://diglib.hab.de"
  xmlns:xstring="https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
<!--  <xsl:output indent="yes"/>-->
  
  <xsl:include href="../string-pack.xsl" />
  <xsl:include href="../word-pack.xsl" />
  <xsl:include href="ref-qv.xsl" />
  
  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="tei:text">
    <text>
      <xsl:if test="//tei:titlePart">
        <front>
          <titlePage>
            <docTitle>
              <xsl:apply-templates select="descendant::tei:titlePart"/>
            </docTitle>
          </titlePage>
        </front>
      </xsl:if>
      <body>
        <xsl:apply-templates select="tei:body/*[not(tei:titlePart)]"/>
      </body>
    </text>
  </xsl:template>
  
  <xsl:template match="tei:teiHeader">
    <teiHeader>
      <xsl:apply-templates select="node()" />
    </teiHeader>
  </xsl:template>
  <!--<xsl:template match="tei:sourceDesc">
    <sourceDesc>
      <listWit>
        <witness xml:id="A">A</witness>
        <xsl:for-each select="//tei:listWit/*">
          <witness>
            <xsl:attribute name="xml:id" select="." />
            <xsl:value-of select="."/>
          </witness>
        </xsl:for-each>
      </listWit>
      <xsl:comment>TODO witness eintragen</xsl:comment>
    </sourceDesc>
  </xsl:template>-->
  
  <xsl:template match="tei:listWit"/>
  
  <xsl:template match="tei:author">
    <editor><xsl:apply-templates /></editor>
  </xsl:template>
  
  <xsl:template match="tei:salute">
    <salute>
      <xsl:apply-templates select="node()" />
    </salute>
  </xsl:template>
  
  <xsl:template match="tei:lb">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][self::tei:pb]
        and ends-with(normalize-space(preceding-sibling::tei:pb[1]/preceding-sibling::text()[1]), '-')
        and normalize-space(preceding-sibling::node()[1][self::text()]) = ''">
        <xsl:text> </xsl:text>
        <w>
          <xsl:value-of
            select="xstring:substring-before(xstring:substring-after-last(normalize-space(
              preceding-sibling::tei:pb[1]/preceding-sibling::text()[1]), ' '), '-')" />
          <pb n="{preceding-sibling::tei:pb[1]/@n}" />
          <lb break="no" />
          <xsl:value-of select="xstring:substring-before(following-sibling::text()[1], ' ')" />
        </w>
        <xsl:if test="contains(following-sibling::text()[1], ' ')">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="following-sibling::node()[1][self::tei:pb]
        and ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
        <xsl:text> </xsl:text>
        <w>
          <xsl:value-of select="xstring:substring-before(xstring:substring-after-last(normalize-space(
            preceding-sibling::text()[1]), ' '), '-')" />
          <xsl:sequence select="following-sibling::tei:pb[1]" />
          <lb break="no" />
          <xsl:value-of select="xstring:substring-before(following-sibling::text()[1], ' ')" />
        </w>
        <xsl:if test="contains(following-sibling::text()[1], ' ')">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="not(ends-with(normalize-space(following-sibling::text()[1]), '-'))">
          <xsl:value-of select="substring-after(following-sibling::text()[1], ' ')"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1][self::tei:note]
        and ends-with(preceding-sibling::tei:note[1]/preceding-sibling::text()[1], '-')">
        <xsl:text> </xsl:text>
        <w>
          <xsl:value-of
            select="xstring:substring-before(xstring:substring-after-last(preceding-sibling::tei:note[1]/preceding-sibling::text()[1], ' '), '-')" />
          <lb break="no" />
          <xsl:value-of select="xstring:substring-before(following-sibling::text()[1], ' ')" />
        </w>
        <xsl:sequence select="preceding-sibling::tei:note[1]/preceding-sibling::text()[1]/following-sibling::*
          intersect preceding-sibling::*" />
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
        <xsl:text> </xsl:text>
        <w>
          <xsl:value-of select="xstring:substring-before(xstring:substring-after-last(preceding-sibling::text()[1], ' '), '-')" />
          <lb break="no" />
          <xsl:value-of select="xstring:substring-before(following-sibling::text()[1], ' ')" />
        </w>
        <xsl:if test="contains(following-sibling::text()[1], ' ')">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1][self::tei:rs]  and ends-with(preceding-sibling::tei:rs[1], '-')
        and following-sibling::node()[1][self::tei:rs]">
        <xsl:variable name="pre" select="normalize-space(preceding-sibling::tei:rs[1])"/>
        <xsl:variable name="post" select="normalize-space(following-sibling::tei:rs[1])"/>
        <xsl:variable name="type" select="preceding-sibling::tei:rs[1]/@type"/>
        
        <rs type="{$type}">
          <xsl:sequence select="preceding-sibling::tei:rs[1]/comment()" />
          <xsl:if test="contains($pre, ' ')">
            <xsl:value-of select="xstring:substring-before-last($pre, ' ')"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <w>
            <xsl:value-of select="substring-before(xstring:substring-after-last($pre, ' '), '-')"/>
            <lb break="no"/>
            <xsl:value-of select="normalize-space(xstring:substring-before($post, ' '))"/>
          </w>
          <xsl:if test="contains($post, ' ')">
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space(xstring:substring-after($post, ' '))"/>
          </xsl:if>
        </rs>
        <xsl:if test="starts-with(following-sibling::node()[1][self::text()], ' ')
          or ends-with(following-sibling::tei:rs[1], ' ')">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1][self::tei:note[@place]]
        and preceding-sibling::*[2][self::tei:rs][ends-with(., '-')]
        and following-sibling::*[1][self::tei:rs]">
        <rs>
          <xsl:apply-templates select="preceding-sibling::tei:rs[1]/@type" />
          <xsl:value-of select="substring-before(preceding-sibling::tei:rs[1], '-')" />
          <xsl:sequence select="preceding-sibling::tei:note[1]" />
          <lb break="no" />
          <xsl:value-of select="following-sibling::tei:rs[1]" />
        </rs>
      </xsl:when>
      <xsl:otherwise>
        <lb/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:rs[ends-with(., '-')
    and following-sibling::*[1][self::tei:lb]
    and following-sibling::*[2][self::tei:rs]]"/>
  <xsl:template match="tei:rs[ends-with(., '-')
    and following-sibling::*[1][self::tei:note[@place]]
    and following-sibling::*[2][self::tei:lb]
    and following-sibling::*[3][self::tei:rs]]"/>
  <xsl:template match="tei:rs[preceding-sibling::node()[1][self::tei:lb]
    and preceding-sibling::*[2][self::tei:rs[ends-with(., '-')]]]" />
  <xsl:template match="tei:rs[preceding-sibling::node()[1][self::tei:lb]
    and preceding-sibling::*[2][self::tei:note[@place]]
    and preceding-sibling::*[3][self::tei:rs[ends-with(., '-')]]]" />
    
    <xsl:template match="tei:pb[ends-with(normalize-space(preceding-sibling::text()[1]), '-')]" />
  
  <xsl:template match="tei:note[@place]">
    <xsl:variable name="inter" select="following-sibling::text() intersect
      following-sibling::tei:lb[1]/preceding-sibling::node()"/>
    <xsl:choose>
      <xsl:when test="ends-with(preceding-sibling::text()[1], '-') and count($inter) = 0" />
      <xsl:when test="following-sibling::*[1][self::tei:lb] and ends-with(preceding-sibling::text()[1], '-')"/>
      <xsl:when test="following-sibling::*[1][self::tei:lb] and ends-with(preceding-sibling::node()[1][self::tei:rs], '-')" />
      <xsl:when test="ends-with(preceding-sibling::text()[1], '') and following-sibling::node()[1][self::tei:note[@place]]" />
      <xsl:when test="preceding-sibling::node()[1][self::tei:note[@place]]">
        <note place="{@place}">
          <xsl:apply-templates select="preceding-sibling::node()[1]/node()" />
          <xsl:apply-templates />
        </note>
      </xsl:when>
      <xsl:otherwise>
        <note place="{@place}">
          <xsl:apply-templates />
        </note>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:note[@type = 'footnote']/text()[not(preceding-sibling::*[1][self::hab:mark])]">
    <xsl:analyze-string select="." regex="[„“&quot;»«]([^„^”^“^&quot;^‟^»^«]*)[”“‟&quot;»«]">
      <xsl:matching-substring>
        <quote>
          <xsl:analyze-string select="substring(., 2, string-length()-2)" regex="\[(\.\.\.|…)\]">
            <xsl:matching-substring><gap/></xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </quote>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <!-- Anmerkung über mehrere Wörter -->
  <xsl:template match="tei:anchor[not(@xml:id)]">
    <xsl:variable name="num" select="count(preceding::tei:anchor[@ref='se'])+1"/>
    <xsl:choose>
      <xsl:when test="@ref='se'">
        <anchor type="crit_app">
          <xsl:attribute name="xml:id" select="'s'||$num||'e'" />
        </anchor>
      </xsl:when>
      <xsl:otherwise>
        <anchor type="crit_app">
          <xsl:attribute name="xml:id" select="@ref||$num"/>
        </anchor>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:note[@type = 'crit_app']">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][self::tei:anchor[@ref='se']]
        or (preceding-sibling::*[1][self::tei:note[@type = 'footnote']]
        and preceding-sibling::*[2][self::tei:anchor[@ref = 'se']])">
        <xsl:variable name="num" select="count(preceding::tei:anchor[@ref='se'])" />
        <span type="crit_app" from="{'#s'||$num}" to="{'#s'||$num||'e'}">
<!--          <xsl:comment>TODO ggf. bessere Kodierung</xsl:comment>-->
          <xsl:apply-templates />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <note type="crit_app">
          <xsl:apply-templates />
        </note>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Paraphrase -->
  <xsl:template match="hab:para[@place='start']">
    <xsl:variable name="myId" select="generate-id()"/>
    <xsl:variable name="endId" select="generate-id(following-sibling::hab:para[@place='end'][1])"/>
    <seg type="paraphrase">
      <xsl:apply-templates
        select="following-sibling::node()[generate-id(preceding-sibling::hab:para[1]) = $myId
        and generate-id(following-sibling::hab:para[1]) = $endId]"/>
    </seg>
  </xsl:template>
  <xsl:template match="hab:para[@place = 'end']" />
  
  <xsl:template match="text()[not(ancestor::tei:note)]">
    <xsl:choose>
      <xsl:when test="ends-with(normalize-space(), '-')
        and ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
        <xsl:variable name="mid" select="substring-after(., ' ')" />
        <xsl:value-of select="xstring:substring-before-last($mid, ' ')" />
      </xsl:when>
        <xsl:when test="preceding-sibling::tei:lb[1]/preceding-sibling::*[1][self::tei:pb]
            and ends-with(normalize-space(preceding-sibling::tei:pb[1]/preceding-sibling::text()[1]), '-')
            and ends-with(normalize-space(), '-')">
          <xsl:if test="preceding-sibling::node()[1][self::tei:note]">
            <xsl:text> </xsl:text>
          </xsl:if>
            <xsl:variable name="mid" select="substring-after(., ' ')" />
            <xsl:value-of select="xstring:substring-before-last($mid, ' ')" />
        </xsl:when>
      <xsl:when test="ends-with(normalize-space(), '-')
          and following-sibling::node()[1][self::tei:lb or self::tei:pb]">
        <xsl:value-of select="xstring:substring-before-last(., ' ')" />
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1][self::tei:pb]
        and ends-with(normalize-space(preceding-sibling::text()[1]), '-')
        and ends-with(normalize-space(), '-')">
        <xsl:variable name="mid" select="substring-after(., ' ')" />
        <xsl:value-of select="xstring:substring-before-last($mid, ' ')" />
      </xsl:when>
      <xsl:when test="preceding-sibling::*[1][self::tei:pb]
        and ends-with(normalize-space(preceding-sibling::text()[1]), '-')"/>
      <xsl:when test="preceding-sibling::*[1][self::tei:lb] and preceding-sibling::*[2][self::tei:pb]
        and ends-with(normalize-space(preceding-sibling::tei:pb[1]/preceding-sibling::text()[1]), '-')
        and normalize-space(preceding-sibling::text()[1]) = ''">
        <!--<xsl:variable name="mid" select="substring-after(., ' ')" />
        <xsl:value-of select="xstring:substring-before-last($mid, ' ')" />-->
        <xsl:value-of select="substring-after(., ' ')" />
      </xsl:when>
      <xsl:when test="ends-with(normalize-space(), '-') and following-sibling::*[1][self::tei:note]">
        <xsl:choose>
          <xsl:when test="preceding-sibling::*[1][self::tei:lb]
            and preceding-sibling::*[2][self::tei:note[@place]]
            and ends-with(preceding-sibling::tei:note[1]/preceding-sibling::text()[1], '-')">
            <xsl:value-of select="xstring:substring-before-last(substring-after(., ' '), ' ')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="xstring:substring-before-last(., ' ')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="preceding-sibling::node()[1][self::tei:lb] and
        ends-with(normalize-space(preceding-sibling::text()[1]), '-')">
        <xsl:value-of select="substring-after(., ' ')" />
      </xsl:when>
      <xsl:when test="preceding-sibling::node()[1][self::tei:lb]
        and preceding-sibling::*[2][self::tei:note[@place]]
        and ends-with(preceding-sibling::tei:note[1]/preceding-sibling::text()[1], '-')">
        <xsl:value-of select="substring-after(., ' ')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- note type comment zusammenziehen – entsteht, wenn z.B. eine Hoch-/Tiefstellung enthalten ist -->
  <!-- note comment kommt an dieser Stelle nur innerhalb einer note type crit_app vor -->
  <xsl:template match="tei:note[@type='comment' and preceding-sibling::node()[1][self::tei:note]]" />
  <xsl:template match="tei:note[@type='comment' and not(preceding-sibling::node()[1][self::tei:note])]">
    <note type="comment">
      <xsl:choose>
        <xsl:when test="following-sibling::node()[not(self::tei:note)]">
          <xsl:sequence select="node()
            | (following-sibling::tei:note intersect following-sibling::node()[not(self::tei:note)][1]/preceding-sibling::*)/node()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="node() | following-sibling::*/node()" />
        </xsl:otherwise>
      </xsl:choose>
    </note>
  </xsl:template>
  
  <xsl:template match="tei:ptr[text() or *]">
    <ref type="digitalisat">
      <xsl:sequence select="@* | node()" />
    </ref>
  </xsl:template>
  
  <xsl:template match="@*|*|comment()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>