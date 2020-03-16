<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:wt="https://github.com/dariok/w2tei"
    xmlns:xstring="https://github.com/dariok/XStringUtils"
    xmlns:hab="http://diglib.hab.de"
    xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:include href="../string-pack.xsl"/>
    <xsl:include href="../word-pack.xsl"/>
    
    <!-- Styles -->
    <!-- kursiv -->
    <xsl:template match="w:r[descendant::w:i[not(@w:val=0)]
        and not(descendant::w:vertAlign or wt:is(., 'KSbibliographischeAngabe', 'r') or wt:is(., 'KSKommentar', 'r'))]">
        <hi style="font-style: italic;"><xsl:apply-templates select="w:t" /></hi>
    </xsl:template>
    <xsl:template match="w:r[descendant::w:i[@w:val=0] and not(wt:is(., 'KSbibliographischeAngabe', 'r')
        or wt:is(., 'KSKommentar', 'r'))]">
        <xsl:apply-templates select="w:t" />
    </xsl:template>
    
    <!-- fett -->
    <xsl:template match="w:r[descendant::w:b[not(@w:val=0)]
        and not(descendant::w:vertAlign or wt:is(., 'KSbibliographischeAngabe', 'r') or wt:is(., 'KSKommentar', 'r'))]">
        <hi style="font-weight: bold;"><xsl:apply-templates select="w:t" /></hi>
    </xsl:template>
    <xsl:template match="w:r[descendant::w:b[@w:val=0] and not(wt:is(., 'KSbibliographischeAngabe', 'r')
        or wt:is(., 'KSKommentar', 'r'))]">
        <xsl:apply-templates select="w:t" />
    </xsl:template>
    
    <!-- hochgestellte -->
    <xsl:template match="w:r[descendant::w:vertAlign and not(descendant::w:i or w:endnoteReference
        or w:footnoteReference or hab:isSem(.))]">
        <xsl:apply-templates select="." mode="eval" />
    </xsl:template>
	<xsl:template match="w:r[descendant::w:vertAlign and not(w:endnoteReference or w:footnoteReference)]" mode="eval">
		<xsl:choose>
			<xsl:when test="w:rPr/w:vertAlign/@w:val = ('super', 'superscript', 'subscript')">
				<hi>
					<xsl:attribute name="rend">
						<xsl:choose>
							<xsl:when test="w:rPr/w:vertAlign/@w:val='superscript'">super</xsl:when>
							<xsl:otherwise>sub</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:apply-templates select="w:t" />
				</hi>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="w:t" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
    <xsl:template match="w:r[descendant::w:vertAlign and descendant::w:i[not(@w:val=0)]]">
        <hi style="font-style: italic;">
            <hi>
                <xsl:attribute name="rend">
                    <xsl:choose>
                        <xsl:when test="w:rPr/w:vertAlign/@w:val='superscript'">super</xsl:when>
                        <xsl:otherwise>sub</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates select="w:t" />
            </hi>
        </hi>
    </xsl:template>
    
    <xsl:template match="w:r[not(descendant::w:vertAlign or descendant::w:i or descendant::w:b
        or w:endnoteReference or w:footnoteReference or hab:isSem(.) or descendant::w:fldChar)]">
        <xsl:apply-templates select="w:t | w:br" />
    </xsl:template>
    <xsl:template match="w:r" mode="eval">
        <xsl:apply-templates select="w:t | w:br" />
    </xsl:template>
    
    <!-- Bibliographisches -->
    <xsl:template match="w:r[wt:is(., 'KSbibliographischeAngabe', 'r') and
        not(wt:isFirst(., 'KSbibliographischeAngabe', 'r'))]" />
    <xsl:template match="w:r[wt:isFirst(., 'KSbibliographischeAngabe', 'r')]">
        <xsl:variable name="me" select="." />
        <xsl:variable name="content">
            <xsl:apply-templates select="w:t" />
            <xsl:apply-templates select="following-sibling::w:r[wt:followMe(., $me, 'KSbibliographischeAngabe', 'r')]"
                mode="eval"/>
        </xsl:variable>
        <xsl:for-each select="tokenize($content, '; ')">
            <bibl>
                <xsl:sequence select="." />
            </bibl>
            <xsl:if test="position() != last()">
                <xsl:text>; </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="w:r[wt:is(., 'KSbibliographischeAngabe', 'r') and
        not(descendant::w:vertAlign or descendant::w:i)]" mode="eval">
        <xsl:apply-templates select="w:t" />
    </xsl:template>
    <!-- Ende Bibliographisches -->
    
    <!-- Fuß-/Endnoten -->
    <xsl:template match="w:r[w:endnoteReference]">
        <xsl:apply-templates select="w:endnoteReference"/>
    </xsl:template>
    
    <!-- neu 2017-08-07 DK -->
    <xsl:template match="w:endnoteReference">
        <xsl:variable name="wid" select="@w:id"/>
        <xsl:variable name="temp">
            <xsl:apply-templates select="//w:endnote[@w:id = $wid]//w:p"/>
        </xsl:variable>
        <note type="footnote">
        	<xsl:attribute name="xml:id" select="'n'||$wid" />
            <xsl:for-each select="$temp/node()">
                <xsl:choose>
                    <xsl:when test="position() = 1 and self::text() and starts-with(., ' ')">
                        <xsl:value-of select="substring(., 2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </note>
    </xsl:template>
    <xsl:template match="w:endnote/w:p">
        <xsl:apply-templates select="w:r | w:hyperlink" />
    </xsl:template>
    <!-- ENDE Fuß-/Endnoten -->
    
    <!-- RS -->
    <xsl:template match="w:r[wt:is(., 'KSOrt', 'r')]">
        <rs type="place">
            <xsl:apply-templates select="w:t"/>
        </rs>
        <xsl:apply-templates select="w:footnoteReference" />
    </xsl:template>
    
    <xsl:template match="w:r[wt:is(., 'KSPerson', 'r')]">
        <rs type="person">
            <xsl:apply-templates select="w:t"/>
        </rs>
        <xsl:apply-templates select="w:footnoteReference" />
    </xsl:template>
    <!-- Ende RS -->
    <!-- Ende Styles -->
    
    <!-- normalize -->
    <xsl:template match="node()" mode="normalize">
        <xsl:choose>
            <xsl:when test="self::text() and not(preceding-sibling::node())">
                <xsl:value-of select="normalize-space()"/>
            </xsl:when>
            <xsl:when test="self::text() and not(following-sibling::node())">
                <xsl:value-of select="normalize-space(xstring:substring-before-if-ends(., '.'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- FUNCTIONS -->
    <xsl:function name="hab:rmSquare" as="xs:string">
        <xsl:param name="input" />
        <xsl:choose>
            <xsl:when test="contains($input, '[')">
                <xsl:analyze-string select="normalize-space($input)" regex="\[([^\]]+)\]?">
                    <xsl:matching-substring>
                        <xsl:value-of select="normalize-space(regex-group(1))"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="contains($input, ']')">
                <xsl:value-of select="substring-before($input, ']')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
	
	<xsl:template match="w:r[wt:is(., 'KSAutorenstelle', 'r')]">
		<ref type="classical">
			<xsl:attribute name="cRef">
				<xsl:value-of select="replace(w:t, '(\w+),.+', '$1') || '!' || substring-after(w:t, ' ')" />
			</xsl:attribute>
			<xsl:apply-templates select="w:t" />
		</ref>
	</xsl:template>
	
	<!-- neu 2017-12-08 DK -->
	<xsl:template match="w:r[wt:is(., 'KSBibelstelle', 'r')]">
		<xsl:choose>
			<xsl:when test="ends-with(w:t, 'Vg')">
				<ref type="biblical"><xsl:value-of select="substring-before(w:t, ' Vg')"/></ref> Vg
			</xsl:when>
			<xsl:otherwise>
				<ref type="biblical"><xsl:apply-templates select="w:t" /></ref>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
    <xsl:function name="hab:isHead" as="xs:boolean">
        <xsl:param name="context" as="node()" />
        <xsl:param name="num"/>
        <xsl:sequence select="wt:is($context, 'KSberschrift'||$num)"/>
    </xsl:function>
    
    <xsl:function name="hab:isSem" as="xs:boolean">
        <xsl:param name="context" as="node()" />
        <xsl:sequence select="matches($context//w:rStyle/@w:val,
            'KSOrt|KSPerson|KSbibliographischeAngabe|KSBibelstelle|KSAutorenstelle|KSkorrigierteThesennummer|KSkritischeAnmerkungbermehrereWrter|KSKommentar|KSEE-Verweis')"/>
    </xsl:function>
    
    <xsl:template match="pkg:part" />
</xsl:stylesheet>