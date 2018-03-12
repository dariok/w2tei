<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:wdb="https://github.com/dariok/wdbplus"
    xmlns:hab="http://diglib.hab.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:include href="../string-pack.xsl"/>
    <xsl:include href="../word-pack.xsl"/>
    
    <!-- Styles -->
    <!-- kursiv -->
    <xsl:template match="w:r[descendant::w:i[not(@w:val=0)]
        and not(descendant::w:vertAlign or wdb:is(., 'KSbibliographischeAngabe', 'r'))]">
        <hi style="font-style: italic;"><xsl:apply-templates select="w:t" /></hi>
    </xsl:template>
    <xsl:template match="w:r[descendant::w:i[@w:val=0] and not(wdb:is(., 'KSbibliographischeAngabe', 'r'))]">
        <xsl:apply-templates select="w:t" />
    </xsl:template>
    
    <!-- hochgestellte -->
    <xsl:template match="w:r[descendant::w:vertAlign and not(descendant::w:i or w:endnoteReference
        or w:footnoteReference or hab:isSem(.))]">
        <xsl:apply-templates select="." mode="eval" />
    </xsl:template>
    <xsl:template match="w:r[descendant::w:vertAlign and not(w:endnoteReference or w:footnoteReference)]" mode="eval">
        <hi>
            <xsl:attribute name="rend">
                <xsl:choose>
                    <xsl:when test="w:rPr/w:vertAlign/@w:val='superscript'">super</xsl:when>
                    <xsl:otherwise>sub</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="w:t" />
        </hi>
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
    
    <xsl:template match="w:r[not(descendant::w:vertAlign or descendant::w:i
        or w:endnoteReference or w:footnoteReference or hab:isSem(.) or descendant::w:fldChar)]">
        <xsl:apply-templates select="w:t | w:br" />
    </xsl:template>
    <xsl:template match="w:r[not(descendant::w:vertAlign or descendant::w:i
        or w:endnoteReference or w:footnoteReference or hab:isSem(.))]" mode="eval">
        <xsl:apply-templates select="w:t | w:br" />
    </xsl:template>
    <!-- Ende Styles -->
    
    <!-- normalize -->
    <xsl:template match="node()" mode="normalize">
        <xsl:choose>
            <xsl:when test="self::text() and not(preceding-sibling::node())">
                <xsl:value-of select="normalize-space()"/>
            </xsl:when>
            <xsl:when test="self::text() and not(following-sibling::node())">
                <xsl:value-of select="normalize-space(wdb:substring-before-if-ends(., '.'))"/>
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
                <xsl:analyze-string select="normalize-space($input)" regex="\[?([^\]]+)\]?\.?">
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
    
    <xsl:function name="hab:isHead" as="xs:boolean">
        <xsl:param name="context" as="node()" />
        <xsl:param name="num"/>
        <xsl:value-of select="wdb:is($context, 'KSberschrift'||$num)"/>
    </xsl:function>
    
    <xsl:function name="hab:isSem" as="xs:boolean">
        <xsl:param name="context" as="node()" />
        <xsl:value-of select="matches($context//w:rStyle/@w:val,
            'KSOrt|KSPerson|KSbibliographischeAngabe|KSBibelstelle|KSAutorenstelle|KSkorrigierteThesennummer|KSkritischeAnmerkungbermehrereWrter')"/>
    </xsl:function>
</xsl:stylesheet>