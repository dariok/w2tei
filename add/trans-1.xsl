<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:hab="http://diglib.hab.de"
    xmlns:wt="https://github.com/dariok/w2tei"
    xmlns:xstring="https://github.com/dariok/XStringUtils"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.0">
    
    <xsl:include href="styles-inc.xsl"/>
    <xsl:include href="ref-qv.xsl" />
    
<!--    <xsl:output indent="yes"/>-->

	<xsl:template match="tei:*">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
    
    <xsl:template match="w:endnotes | w:footnotes | w:numbering | w:comments" />
    
    <xsl:template match="w:p[not(w:r)]" />
    
    <!-- Marginalie -->
    <xsl:template match="w:p[wt:is(., 'KSMarginalie', 'p') and w:r]">
        <note place="margin"><xsl:apply-templates select="w:r" /></note>
    </xsl:template>
    
<!--    <xsl:template match="w:p[descendant::w:numPr][position() &gt; 1]"/>-->
    <xsl:template match="tei:p[descendant::w:numPr]">
        <list>
            <xsl:apply-templates select="w:p[descendant::w:numPr]"/>
        </list>
    </xsl:template>
    
    <xsl:template match="w:p[descendant::w:numPr]">
        <xsl:variable name="numId" select="descendant::w:numPr/w:numId/@w:val"/>
        <xsl:variable name="ilvl" select="descendant::w:numPr/w:ilvl/@w:val"/>
        <xsl:variable name="num" select="//w:numbering/w:num[@w:numId = $numId]/w:abstractNumId/@w:val"/>
        <xsl:variable name="style" select="//w:numbering/w:abstractNum[@w:abstractNumId = $num]/w:lvl[@w:ilvl = $ilvl]/w:numFmt/@w:val" />
        <xsl:variable name="myID" select="generate-id()" />
        
        <label>
            <xsl:choose>
                <xsl:when test="wt:is(w:r[1], 'KSkorrigierteThesennummer', 'r')">
                    <app>
                        <lem>
                            <xsl:choose>
                                <xsl:when test="$style = 'upperRoman'">
                                    <xsl:number count="w:p[descendant::w:numPr]" format="I" />
                                </xsl:when>
                                <xsl:when test="$style = 'lowerRoman'">
                                    <xsl:number count="w:p[descendant::w:numPr]" format="i" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:number count="w:p[descendant::w:numPr]" />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>.</xsl:text>
                        </lem>
                        <rdg>
                            <xsl:apply-templates select="w:r[1]/w:t"/>
                        </rdg>
                    </app>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$style = 'upperRoman'">
                            <xsl:number count="w:p[descendant::w:numPr]" format="I" />
                        </xsl:when>
                        <xsl:when test="$style = 'lowerRoman'">
                            <xsl:number count="w:p[descendant::w:numPr]" format="i" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:number count="w:p[descendant::w:numPr]" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        	<xsl:if test="w:r[1]/w:footnoteReference and wt:starts(., ' ')">
        		<xsl:apply-templates select="w:r[1]"/>
        	</xsl:if>
        </label>
        <item>
        	<xsl:choose>
        		<xsl:when test="w:r[1]/w:footnoteReference">
        			<xsl:apply-templates select="w:r[position() &gt; 1] | following-sibling::w:p[not(descendant::w:numPr)
        				and $myID = generate-id(preceding-sibling::w:p[descendant::w:numPr][1])]" />
        		</xsl:when>
        		<xsl:otherwise>
        			<xsl:apply-templates select="w:r | following-sibling::w:p[not(descendant::w:numPr)
        				and $myID = generate-id(preceding-sibling::w:p[descendant::w:numPr][1])]" />
        		</xsl:otherwise>
        	</xsl:choose>
        </item>
    </xsl:template>
    <xsl:template match="w:r[wt:is(., 'KSkorrigierteThesennummer', 'r')]" />
    
    <xsl:template match="w:p[w:r and not(wt:is(., 'KSMarginalie', 'p') or descendant::w:numPr
        or ancestor::w:endnote or ancestor::w:footnote)]">
        <!--<xsl:param name="parind" select="xs:integer(0)"/>-->
        <xsl:variable name="parind" select="descendant::w:ind/@w:left"/>
        <xsl:variable name="relind">
            <xsl:choose>
                <xsl:when test="$parind castable as xs:integer and $parind > 0 and descendant::w:ind">
                    <xsl:value-of select="xs:integer(descendant::w:ind/@w:left) - xs:integer($parind)"/>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="temp">
            <xsl:apply-templates select="w:r | w:bookmarkStart | w:bookmarkEnd"/>
        </xsl:variable>
        <xsl:variable name="content">
            <xsl:for-each select="$temp/node()">
                <xsl:choose>
                    <xsl:when test="self::text()">
                        <xsl:analyze-string select="." regex="(\[.+?\])">
                            <xsl:matching-substring>
                                <pb n="{regex-group(1)}" />
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:choose>
                                    <xsl:when test="ends-with(., '')">
                                        <xsl:value-of select="xstring:substring-before-if-ends(., '')"/>
                                    </xsl:when>
                                    <xsl:when test="ends-with(., '⏊')">
                                        <xsl:value-of select="xstring:substring-before-if-ends(., '⏊')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
    	<xsl:text>
					</xsl:text>
        <lb />
        <xsl:choose>
            <xsl:when test="$relind castable as xs:integer and  $relind > 0">
                <ab style="centre">
                    <xsl:sequence select="$content"/>
                </ab>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$content" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Ende Paragraphen -->
    
    <!-- Langes Zitat bzw. Paraphrase -->
    <xsl:template match="w:r[wt:isFirst(., 'KSQuote', 'r')]">
        <hab:para place="start"/>
    </xsl:template>
    <xsl:template match="w:r[wt:is(., 'KSQuote', 'r') and following::w:r[1][not(wt:is(., 'KSQuote', 'r'))]]">
        <hab:para place="end" />
    </xsl:template>
    
	<!-- kritische Anmerkungen -->
	<xsl:template match="w:r[descendant::w:footnoteReference
		and not(wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
		or wt:is(., 'KSOrt', 'r')
		or wt:is(., 'KSPerson', 'r'))]">
		<xsl:apply-templates select="w:footnoteReference" />
	</xsl:template>
	
    <xsl:template match="w:footnoteReference">
        <note type="crit_app">
            <xsl:variable name="wid" select="@w:id"/>
            <xsl:apply-templates select="//w:footnote[@w:id = $wid]/w:p/w:r" />
        </note>
    </xsl:template>
    
    <xsl:template match="w:r[wt:isFirst(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
        and following::w:r[1][wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]]">
        <anchor type="crit_app" ref="s"/>
        <xsl:apply-templates select="w:t" />
    </xsl:template>
	<xsl:template match="w:r[wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
		and not(following::w:r[1][wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')])
		and not(ancestor::w:footnote)]">
		<xsl:if test="not(preceding::w:r[1][wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')])">
			<anchor type="crit_app" ref="s" />
		</xsl:if>
		<xsl:apply-templates select="w:t" />
		<anchor type="crit_app" ref="se" />
	</xsl:template>
	
    <!-- es kommen krit. oder Sachanmerkungen innerhalb dieses Teils vor -->
	<xsl:template match="w:r[not(wt:isFirst(., 'KSkritischeAnmerkungbermehrereWrter', 'r'))
		and wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
		and following::w:r[1][wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]
		and preceding::w:r[1][wt:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]
		and not(w:endnoteReference)]">
		<xsl:apply-templates select="w:t | w:footnoteReference"/>
	</xsl:template>
    
    <xsl:template match="w:r[wt:is(., 'KSKommentar', 'r') and not(descendant::w:i/@w:val='0')
        and not(descendant::w:vertAlign)]">
        <note type="comment">
            <xsl:apply-templates select="w:t"/>
        </note>
    </xsl:template>
    <xsl:template match="w:r[wt:is(., 'KSKommentar', 'r') and not(descendant::w:i/@w:val='0')
        and descendant::w:vertAlign]">
    	<note type="comment">
        <hi>
            <xsl:attribute name="rend">
                <xsl:choose>
                    <xsl:when test="descendant::w:vertAlign/@w:val='subscript'">sub</xsl:when>
                    <xsl:otherwise>super</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="w:t"/>
        </hi>
    	</note>
    </xsl:template>
    <xsl:template match="w:r[wt:is(., 'KSKommentar', 'r') and descendant::w:i/@w:val='0']">
         <note type="comment"><orig><xsl:apply-templates select="w:t"/></orig></note>
    </xsl:template>
    <!-- ENDE kritische Anmerkungen -->
    
    <!--<xsl:template match="w:r[wt:is(., 'KSAutorenstelle', 'r')]">
        <ref type="medieval">
            <xsl:apply-templates select="w:t" />
        </ref>
    </xsl:template>-->
    
    <!--<xsl:template match="w:p[wt:is(., 'KSlistWit', 'p')]">
        <xsl:variable name="text"><xsl:apply-templates select="w:r"/></xsl:variable>
        <xsl:variable name="value" select="xstring:substring-before-if-ends($text, '')"/>
        <witness><xsl:value-of select="$value"/></witness>
    </xsl:template>-->
	<xsl:template match="w:p[wt:is(., 'KSlistWit', 'p')]" />
    
    <xsl:template match="*:part" />
    
    <xsl:template match="text() | @*">
        <xsl:copy>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
