<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" omit-xml-declaration="1" />
  
  <xsl:include href="string-pack.xsl"/>
  <xsl:include href="word-pack.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//w:document"/>
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
        <encodingDesc>
          <tagsDecl>
            <xsl:for-each-group select="w:body//w:pStyle | //w:endnotes//w:pStyle | //w:footnotes//w:pstyle" group-by="@w:val">
              <rendition scheme="css" xml:id="{current-grouping-key()}">
                <xsl:apply-templates select="//w:style[@w:styleId eq current-grouping-key()]/w:rPr" />
              </rendition>
            </xsl:for-each-group>
          </tagsDecl>
        </encodingDesc>
      </teiHeader>
      <text>
        <body>
          <xsl:apply-templates select="w:body"/>
        </body>
        <back>
          <xsl:apply-templates select="//w:endnotes" />
        </back>
      </text>
    </TEI>
  </xsl:template>
  
  <!-- normal paragraphs -->
<!--  <xsl:template match="w:p[not(descendant::w:t or descendant::w:sym or ancestor::w:tbl)]" />-->
  <xsl:template match="w:p">
    <p>
      <xsl:apply-templates select="*" />
    </p>
  </xsl:template>
  
  <xsl:template match="w:comment/w:p">
    <note>
      <xsl:apply-templates select="*"/>
    </note>
  </xsl:template>
  
   <!-- numberings usually are part of lists, except when applied to a heading. Recognize headings by looking for an
       explicit style name or the presence of w:outlineLvl -->
   <xsl:template match="w:p[descendant::w:numPr and not(ancestor::w:tc or wt:is(., 'Heading')or w:pPr/w:outlineLvl)]">
      <xsl:variable name="level" select="descendant::w:ilvl/@w:val" />
      <xsl:variable name="numId" select="descendant::w:numId/@w:val" />
      <xsl:variable name="abstractNumId" select="//w:num[@w:numId = $numId]/w:abstractNumId/@w:val" />
      <xsl:variable name="abstractNum" select="//w:abstractNum[@w:abstractNumId = $abstractNumId]" />
      
      <xsl:variable name="context" select="." />
      
      <!-- distinguish between numbered and unordered (bulleted etc.) lists -->
      <xsl:if test="$abstractNum/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val = 'decimal'">
         <label>
            <xsl:apply-templates select="." mode="numbering" />
         </label>
      </xsl:if>
      
      <item level="{$level}">
         <xsl:apply-templates select="*" />
      </item>
   </xsl:template>
   
   <!-- headings either have a w:outlineLvl descendant or a style with element – check using a function -->
   <xsl:template match="w:p[wt:isHeading(.)]">
      <head>
         <xsl:attribute name="level">
            <xsl:choose>
               <xsl:when test="w:pPr/w:outlineLvl">
                  <xsl:value-of select="w:pPr/w:outlineLvl/@w:val" />
               </xsl:when>
               <xsl:when test="starts-with(w:pPr/w:pStyle/@w:val, 'Heading')">
                  <xsl:value-of select="substring-after(w:pPr/w:pStyle/@w:val, 'Heading')" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:variable name="pStyle" select="w:pPr/w:pStyle/@w:val" />
                  <xsl:variable name="style" select="//w:style[@w:styleId = $pStyle]" />
                  <xsl:value-of select="$style//w:outlineLvl/@w:val" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
         <xsl:if test="descendant::w:numPr">
            <xsl:attribute name="n">
               <xsl:apply-templates select="." mode="numbering" />
            </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates select="*" />
      </head>
   </xsl:template>
  
  <xsl:template match="w:pPr">
    <xsl:apply-templates select="w:pStyle" />
    
    <xsl:variable name="style" as="xs:string*">
      <xsl:apply-templates select="*[not(self::w:rPr or self::w:pStyle)]" />
    </xsl:variable>
    <xsl:if test="count($style) gt 0">
      <xsl:attribute name="style" select="normalize-space(string-join($style[normalize-space() ne ''], '; ')) || ';'" />
    </xsl:if>
  </xsl:template>
   
   <xsl:template match="w:p" mode="numbering">
      <xsl:param name="picture" />
      
      <xsl:variable name="level" select="descendant::w:ilvl/@w:val" />
      <xsl:variable name="numId" select="descendant::w:numId/@w:val" />
      <xsl:variable name="abstractNumId" select="//w:num[@w:numId = $numId]/w:abstractNumId/@w:val" />
      <xsl:variable name="abstractNum" select="//w:abstractNum[@w:abstractNumId = $abstractNumId]" />
      <xsl:variable name="pic" select="if ( $picture = '' )
            then $abstractNum/w:lvl[@w:ilvl = $level]/w:lvlText/@w:val => string()
            else $picture" />
      
      <!-- distinguish between numbered and unordered (bulleted etc.) lists -->
      <xsl:if test="$abstractNum/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val = 'decimal'">
         <xsl:variable name="start" select="$abstractNum/w:lvl[@w:ilvl eq $level]/w:start/@w:val"/>
         <xsl:variable name="from" select="preceding-sibling::w:p[descendant::w:numId/@w:val = $numId and number(descendant::w:ilvl/@w:val) lt number($level)][1]"/>
         <xsl:variable name="count">
            <xsl:choose>
               <xsl:when test="$from">
                  <xsl:value-of select="count($from/following-sibling::w:p[descendant::w:numId/@w:val = $numId and descendant::w:ilvl/@w:val = $level]
                     intersect preceding-sibling::w:p[descendant::w:numId/@w:val = $numId and descendant::w:ilvl/@w:val = $level]) + $start" />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="count(preceding-sibling::w:p[descendant::w:numId/@w:val = $numId and descendant::w:ilvl/@w:val = $level]) + $start" />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         
         
         <xsl:choose>
            <xsl:when test="$level = 0">
               <xsl:value-of select="replace($pic, '%' || $level + 1, string($count)) => normalize-space()" />
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="$from" mode="numbering">
                  <xsl:with-param name="picture">
                     <xsl:choose>
                        <xsl:when test="$from//w:ilvl/@w:val != $level - 1">
                           <xsl:value-of select="$pic
                              => replace('%' || $level + 1, string($count))
                              => replace('%' || $level, '0')" />
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="replace($pic, '%' || $level + 1, string($count))" />
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:with-param>
               </xsl:apply-templates>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
  
   <xsl:template match="w:r[
            not(*)
         or (w:rPr and not(w:rPr/following-sibling::*))
         or w:t = ''
      ]" />
  
  <xsl:template match="w:r" mode="#all">
    <ab>
      <xsl:attribute name="xml:space">preserve</xsl:attribute>
      <xsl:apply-templates select="w:rPr" />
      <xsl:apply-templates select="w:t | w:sym | w:tab | w:br" />
    </ab>
  </xsl:template>
  
  <xsl:template match="w:pStyle | w:rStyle">
    <xsl:attribute name="rendition" select="@w:val" />
  </xsl:template>
  
  <xsl:template match="w:rPr[*]" as="attribute()*">
    <xsl:apply-templates select="w:rStyle" />
    <xsl:if test="*[not(self::w:rStyle)]">
      <xsl:variable name="styles" as="xs:string*">
        <xsl:apply-templates select="*[not(self::w:rStyle)] | preceding-sibling::*[not(self::w:pStyle or self::w:pPr)]
            | preceding-sibling::w:pPr/*" />
      </xsl:variable>
      <xsl:attribute name="style">
        <xsl:value-of select="string-join($styles, '; ') || ';'"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:rPr/*[not(self::w:rStyle)]" as="xs:string">
    <xsl:variable name="val">
      <xsl:value-of select="local-name()"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="translate((@w:val | @w:ascii | @w:cs)[1], ';', ',')" />
    </xsl:variable>
    <xsl:value-of select="string($val)"/>
  </xsl:template>
  
  <xsl:template match="w:sym">
    <xsl:value-of select="codepoints-to-string(wt:hexToDec(@w:char))" />
  </xsl:template>
  
   <xsl:template match="w:r[w:fldChar/@w:fldCharType = ('separate','end')]" />
   <xsl:template match="w:r[w:fldChar/@w:fldCharType = 'begin']">
      <xsl:choose>
         <xsl:when test="contains(following-sibling::w:r[1]/w:instrText, 'HYPERLINK')">
           <ref>
             <xsl:attribute name="target">
               <xsl:variable name="target" select="substring(following-sibling::w:r[1]/w:instrText, 13)" />
               <xsl:value-of select="normalize-space(substring($target, 1, string-length($target) - 2))"/>
             </xsl:attribute>
             <xsl:apply-templates select="following-sibling::w:r[w:fldChar][1]/following-sibling::*
               intersect following-sibling::w:r[w:fldChar][2]/preceding-sibling::*" mode="link" />
           </ref>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="field" select="
                            following-sibling::*
                  intersect following-sibling::w:r[w:fldChar/@w:fldCharType = 'end'][1]/preceding-sibling::*
               " />
            <xsl:variable name="types" select="$field ! (w:fldChar/@w:fldCharType, '')[1] "/>
            <xsl:variable name="separator" select="index-of($types, 'separate')" />
            
            <field>
               <xsl:attribute name="function" select="string-join($field[position() lt $separator]/w:instrText)" />
               <xsl:apply-templates select="$field[position() gt $separator]" mode="inField" />
           </field>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
  <xsl:template match="w:r[(w:t or w:sym) and preceding-sibling::w:r[w:fldChar][1][w:fldChar/@w:fldCharType = 'separate']
    and following-sibling::w:r[w:fldChar][1][w:fldChar/@w:fldCharType = 'end']]" priority="0.75"/>
  <xsl:template match="w:r[w:instrText]" />
  
  <xsl:template match="w:hyperlink">
    <xsl:variable name="content">
      <xsl:apply-templates select="w:r" />
    </xsl:variable>
    <xsl:variable name="id" select="@r:id"/>
    <xsl:variable name="environment" select="substring-after(ancestor::pkg:part/@pkg:name, 'word')" />
    <xsl:variable name="targetRels" select="//pkg:part[@pkg:name = '/word/_rels' || $environment || '.rels']" />
    
    <ref>
      <xsl:attribute name="target">
        <xsl:variable name="rel" select="$targetRels//*:Relationship[@Id = $id and @TargetMode eq 'External']/@Target"/>
        
        <xsl:choose>
          <xsl:when test="$rel">
            <xsl:value-of select="$rel"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$content"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      
      <xsl:sequence select="$content/tei:ab/@*" />
      <xsl:sequence select="$content/tei:ab/node()" />
    </ref>
  </xsl:template>
  
  <!-- footnotes -->
  <xsl:template match="w:r[w:footnoteReference]">
    <xsl:variable name="id" select="w:footnoteReference/@w:id"/>
    <xsl:variable name="note" select="//w:footnote[@w:id = $id]"/>
    
    <!-- footnotes may have a starting value other than 1, which may be found in settings.xml -->
    <xsl:variable name="count">
      <xsl:variable name="start" as="xs:integer">
        <xsl:choose>
          <xsl:when test="//pkg:part[@pkg:name eq '/word/settings.xml']//w:footnotePr/w:numStart">
            <!-- the settings also include empty footnotes parallel to the empty ones in //w:footnotes;
                 Cf. ECMA-376, 5th ed., 17.11.9 -->
            <xsl:value-of select="//pkg:part[@pkg:name eq '/word/settings.xml']//w:footnotePr/w:numStart/@w:val
              - count(//pkg:part[@pkg:name eq '/word/settings.xml']//w:footnotePr/w:footnote) + $id"/>
          </xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:value-of select="$start"/>
    </xsl:variable>
    
    <note type="footnote" xml:id="n{$id}" n="{$count}">
      <xsl:apply-templates select="$note/w:p" />
    </note>
  </xsl:template>
  
  <xsl:template match="w:r[w:footnoteRef]" />
  <!-- END footnotes -->
  
  <!-- endnotes -->
  <xsl:template match="w:r[w:endnoteReference]">
    <xsl:variable name="id" select="w:endnoteReference/@w:id"/>
    <xsl:variable name="note" select="//w:endnote[@w:id = $id]"/>
    <ptr type="endnote" ref="#e{$id}">
      <xsl:apply-templates select="$note//w:pStyle" />
    </ptr>
  </xsl:template>
  
  <xsl:template match="w:r[w:endnoteRef]" />
  
  <xsl:template match="w:endnotes">
    <xsl:apply-templates select="w:endnote[@w:id &gt; 0]" />
  </xsl:template>
  
  <xsl:template match="w:endnote">
    <!-- TODO if this comes up, deal with startings values other than 1 like for footnotes -->
    <note type="endnote" xml:id="e{@w:id}">
      <xsl:apply-templates select="w:p" />
    </note>
  </xsl:template>
  <!-- END endnotes -->
  
  <xsl:template match="w:tabs" />
  
  <xsl:template match="w:tab[not(ancestor::w:pPr)]">
    <space unit="tab" />
  </xsl:template>
  
  <xsl:template match="w:commentRangeEnd"/>
  <xsl:template match="w:commentRangeStart">
    <ptr type="comment" xml:id="c{@w:id}" />
  </xsl:template>
  <xsl:template match="w:r[w:commentReference]">
    <xsl:variable name="cID" select="w:commentReference/@w:id"/>
    <xsl:variable name="comment" select="//w:comment[@w:id = $cID]" />
    <note type="comment" from="#c{$cID}">
      <xsl:apply-templates select="$comment/w:p" />
    </note>
  </xsl:template>
  <xsl:template match="w:r[w:annotationRef]" />
  
  <!-- Tables -->
  <xsl:template match="w:tbl">
    <table cols="{count(w:tblGrid/w:gridCol)}">
      <xsl:apply-templates select="w:tr" />
    </table>
  </xsl:template>
  <xsl:template match="w:tr">
    <row>
      <xsl:apply-templates select="w:tc" />
    </row>
  </xsl:template>
  <xsl:template match="w:tc">
    <cell>
      <xsl:variable name="styles" as="attribute()*">
        <xsl:apply-templates select="w:tcPr | w:p[1]/w:pPr" />
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="count($styles[name() eq 'style']) gt 1">
          <xsl:sequence select="$styles[name() eq 'rendition']"></xsl:sequence>
          <xsl:attribute name="style" select="string-join($styles[name() eq 'style'], '; ')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$styles" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="w:p" />
    </cell>
  </xsl:template>
  <xsl:template match="w:tc/w:p">
    <xsl:if test="preceding-sibling::w:p">
      <lb />
    </xsl:if>
    <xsl:apply-templates select="w:r" />
  </xsl:template>
  
  <xsl:template match="w:tcPr" as="attribute()*">
    <xsl:if test="w:gridSpan">
      <xsl:attribute name="cols" select="w:gridSpan/@w:val" />
    </xsl:if>
    
    <xsl:apply-templates select="w:tcBorders" />
  </xsl:template>
  <xsl:template match="w:tcBorders">
    <xsl:variable name="values" as="xs:string*">
      <xsl:apply-templates select="*[@w:val ne 'nil']" />
    </xsl:variable>
    
    <xsl:if test="count($values) gt 0">
      <xsl:attribute name="style" select="string-join($values, '; ') || ';'"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="w:tcBorders/*">
    <xsl:variable name="style" select="if (@w:val eq 'single') then 'solid' else @w:val" />
    <xsl:value-of
      select="'border-' || local-name() || ': ' || number(@w:sz) div 2 || 'px ' || $style || ' #' || @w:color"/>
  </xsl:template>
  <!-- END tables -->
  
  <xsl:template match="w:bookmarkStart[@w:name = '_GoBack']" />
  <xsl:template match="w:bookmarkStart">
    <anchor type="bookmarkStart" xml:id="{@w:name}" /> 
  </xsl:template>
  <xsl:template match="w:bookmarkEnd">
    <xsl:variable name="target" select="@w:id" />
    <xsl:variable name="ref" select="preceding-sibling::w:bookmarkStart[@w:id = $target]/@w:name" />
    
    <xsl:if test="$ref ne '_GoBack'">
      <anchor type="bookmarkEnd" ref="#{$ref}" />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="w:br">
    <lb />
  </xsl:template>
  
  <!-- some paragraph-level style settings -->
   <!-- justification -->
   <xsl:template match="w:jc" as="xs:string">
      <xsl:choose>
         <xsl:when test="@w:val = ('start', 'left')">text-align: left</xsl:when>
         <xsl:when test="@w:val = ('end', 'right')">text-align: right</xsl:when>
         <xsl:when test="@w:val eq 'center'">text-align: center</xsl:when>
         <xsl:when test="@w:val = ('both', 'distribute')">text-align: justify</xsl:when>
      </xsl:choose>
   </xsl:template>
   
   <!-- outline level: different levels of headings -->
   <xsl:template match="w:outlineLvl">
      <xsl:value-of select="'outlineLvl: ' || @w:val" />
   </xsl:template>
  
  <!-- indentation of first line -->
  <xsl:template match="w:ind" as="xs:string*">
    <xsl:if test="@w:firstLine">
      <xsl:variable name="val" select="round(@w:firstLine/number() div 20)" />
      <xsl:if test="$val gt 0">
        <xsl:value-of select="'text-indent: ' || $val || 'pt'"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@w:left">
      <xsl:variable name="val" select="round(@w:left/number() div 20)" />
      <xsl:if test="$val gt 0">
        <xsl:value-of select="'padding-left: ' || $val || 'pt'"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>
   
  <xsl:template match="pkg:part[not(@pkg:name='/word/document.xml')]" />
  
</xsl:stylesheet>