<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  
  <xsl:include href="string-pack.xsl"/>
  <xsl:include href="word-pack.xsl"/>
  
  <xsl:variable name="titelei" select="string-join(//w:p[wt:is(., 'TBEE-Titel')])"/>
  <xsl:variable name="nr" select="normalize-space(xstring:substring-before(substring-after($titelei, 'ID'), ';'))" />
  
  <xsl:template match="/">
    <xsl:apply-templates select="//w:document" />
  </xsl:template>
  
  <xsl:template match="w:document">
    <TEI>
      <teiHeader>
        <fileDesc>
          <sourceDesc>
            <p>Created from a MS Word file by <ref target="https://github.com/dariok/w2tei">W2TEI</ref>:
              <date when="{current-dateTime()}" type="created" /></p>
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="//w:body"/>
        </body>
        <back>
          <xsl:apply-templates select="//w:endnotes" />
        </back>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="w:body">
    <xsl:for-each-group select="w:p"
      group-starting-with="w:p[not(descendant::w:t or descendant::w:sym)]">
      <xsl:text>
      </xsl:text>
      <div>
        <xsl:apply-templates select="current-group()" />
      </div>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="w:p[not(descendant::w:t or descendant::w:sym)]" />
  <xsl:template match="w:p">
    <p>
      <xsl:apply-templates select="w:pPr/w:pStyle | w:pPr/w:rPr" />
      <xsl:apply-templates select="w:r | w:hyperlink" />
    </p>
  </xsl:template>
  <xsl:template match="w:pStyle">
    <xsl:attribute name="style" select="@w:val" />
  </xsl:template>
  
  <xsl:template match="w:r[w:t or w:sym]">
    <ab>
      <xsl:apply-templates select="w:rPr" />
      <xsl:apply-templates select="w:t | w:sym" />
    </ab>
  </xsl:template>
  <xsl:template match="w:rPr">
    <xsl:attribute name="style">
      <xsl:apply-templates select="*" />
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="w:rPr/*">
    <xsl:value-of select="local-name()"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="(@w:val | @w:ascii)"/>
    <xsl:if test="following-sibling::*">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:sym">
    <xsl:value-of select="codepoints-to-string(wt:hexToDec(@w:char))" />
  </xsl:template>
  
  <xsl:template match="w:r[w:fldChar/@w:fldCharType = ('separate','end')]" />
  <xsl:template match="w:r[w:fldChar/@w:fldCharType = 'begin']">
    <field>
      <xsl:attribute name="function"
        select="string-join(following-sibling::w:r
        [not(preceding-sibling::w:r[w:fldChar[@w:fldCharType = 'separate']])]/w:instrText, '')"/>
      <xsl:apply-templates select="(following-sibling::w:r[w:fldChar][1]/following-sibling::*
        intersect following-sibling::w:r[w:fldChar][2]/preceding-sibling::*)/*" />
    </field>
  </xsl:template>
  <xsl:template match="w:r[(w:t or w:sym) and preceding-sibling::w:r[w:fldChar][1][w:fldChar/@w:fldCharType = 'separate']
    and following-sibling::w:r[w:fldChar][1][w:fldChar/@w:fldCharType = 'end']]" priority="0.75"/>
  <xsl:template match="w:r[w:instrText]" />
  
  <xsl:template match="w:hyperlink">
    <field>
      <xsl:attribute name="function">
        <xsl:text>HYPERLKINK</xsl:text>
        
      </xsl:attribute>
      <xsl:apply-templates select="w:r" />
    </field>
  </xsl:template>
  
  <xsl:template match="w:r[w:footnoteReference]">
    <xsl:variable name="id" select="w:footnoteReference/@w:id"/>
    <xsl:variable name="note" select="//w:footnote[@w:id = $id]"/>
    <note type="footnote" xml:id="n{$id}">
      <xsl:apply-templates select="$note//w:pStyle" />
      <xsl:apply-templates select="$note//w:r | $note//w:hyperlink" />
    </note>
  </xsl:template>
  <xsl:template match="w:r[w:footnoteRef]" />
  
  <xsl:template match="w:r[w:endnoteReference]">
    <xsl:variable name="id" select="w:endnoteReference/@w:id"/>
    <xsl:variable name="note" select="//w:endnote[@w:id = $id]"/>
    <ptr type="endnote" xml:id="n{$id}">
      <xsl:apply-templates select="$note//w:pStyle" />
    </ptr>
  </xsl:template>
  <xsl:template match="w:r[w:endnoteRef]" />
  <xsl:template match="w:endnotes">
    <xsl:apply-templates select="w:endnote[@w:id &gt; 0]" />
  </xsl:template>
  <xsl:template match="w:endnote">
    <note type="endnote">
      <xsl:apply-templates select="w:p//w:pStyle" />
      <xsl:apply-templates select="w:p/w:r | w:p/w:hyperlink" />
    </note>
  </xsl:template>
  
  <xsl:template match="w:r[w:tab]">
    <space width="tab">
      <xsl:attribute name="style">
        <xsl:apply-templates select="w:rPr" />
      </xsl:attribute>
    </space>
  </xsl:template>
  
  <xsl:template match="w:r">
    <T />
  </xsl:template>
</xsl:stylesheet>