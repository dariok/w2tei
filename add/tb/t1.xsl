<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
	xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<!-- erstellt 2018-10-16 Bearbeiter:DK Dario Kampkaspar, dario.kampkaspar@oeaw.ac.at -->
	
	<xsl:include href="word-pack.xsl"/>
	
	<!-- Absätze erstellen -->
	<xsl:template match="tei:div/w:p[not(descendant::w:t)]" />
	<xsl:template match="tei:div/w:p[descendant::w:t and not(wt:is(., 'TBMarginalie'))]">
		<xsl:variable name="myId" select="generate-id()"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="wt:is(., 'TBText')">p</xsl:when>
				<xsl:when test="wt:is(., 'TBPostscriptum')">postscript</xsl:when>
				<xsl:when test="wt:is(., 'TBZitatblock')">cit</xsl:when>
				<xsl:when test="wt:is(., 'TBZwischenberschrift', 'p')">head</xsl:when>
				<xsl:when test="wt:is(., 'TBAdresse', 'p')">opener</xsl:when>
				<xsl:when test="wt:is(., 'TBUmschlag', 'p')">closer</xsl:when>
				<xsl:otherwise>p</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$name}">
			<xsl:if test="wt:is(., 'KSZwischenberschrift2', 'p')">
				<xsl:attribute name="type">subheading</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="w:r | w:hyperlink"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="tei:div/w:p[wt:is(., 'TBMarginalie')]">
		<note place="margin"><xsl:apply-templates select="w:r | w:hyperlink" /></note>
	</xsl:template>
	
	<!-- Templates für Word runs – z.B. Zeichenvorlagen -->
	<!-- normales run -->
	<xsl:template match="w:r[(
			not(w:rPr or w:sym or w:rPr/*)
			or (w:rPr and not(w:rPr/*))
			or (w:rPr/w:lang and count(w:rPr/*) = 1)
			or (w:rPr/w:rFonts and not(w:rPr/w:vertAlign or w:rPr/w:i[not(@w:val=0)])
				and not(wt:is(., 'Funotenzeichen', 'r') or wt:is(., 'Endnotenzeichen', 'r')))
			or descendant::w:i[@w:val=0])
		and not(descendant::w:vertAlign or wt:is(., 'bookref', 'r'))]">
		<xsl:value-of select="w:t"/>
	</xsl:template>
	
	<!-- Sonderzeichen -->
	<xsl:template match="w:r[w:sym]">
		<xsl:variable name="char" select="w:sym/@w:char"/>
		<xsl:choose>
			<xsl:when test="$char = 'F028'"><xsl:value-of select="'a' || codepoints-to-string(wt:hexToDec('0364'))"/></xsl:when>
			<xsl:when test="$char = 'F047'"><xsl:value-of select="'u' || codepoints-to-string(wt:hexToDec('0366'))"/></xsl:when>
			<xsl:when test="$char = 'F03D'"><xsl:value-of select="'o' || codepoints-to-string(wt:hexToDec('0364'))"/></xsl:when>
			<xsl:otherwise><!--<xsl:value-of select="codepoints-to-string(wt:hexToDec(w:sym/@w:char))"/>-->
			<g><xsl:value-of select="$char"/></g></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Kursivierungen, Hochstellungen -->
	<xsl:template match="w:r[descendant::w:i[not(@w:val=0)]
		and not(descendant::w:vertAlign or wt:is(., 'bookref', 'r'))]">
		<hi style="font-style: italic;"><xsl:value-of select="w:t" /></hi>
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
				<xsl:value-of select="w:t" />
			</hi>
		</hi>
	</xsl:template>
	<xsl:template match="w:r[(descendant::w:vertAlign or descendant::w:position)
		and w:t
		and not(descendant::w:i[not(@w:val=0)])]">
		<hi>
			<xsl:attribute name="rend">
				<xsl:choose>
					<xsl:when test="w:rPr/w:vertAlign/@w:val='superscript'
						or w:rPr/w:position/@w:val &gt; 0">super</xsl:when>
					<xsl:otherwise>sub</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="w:t" />
		</hi>
	</xsl:template>
	<xsl:template match="w:r[descendant::w:u[not(@w:val='0')]]">
		<emph>
			<xsl:apply-templates select="w:t" />
		</emph>
	</xsl:template>
	
	<!-- Links – Personen, Orte, Sachen – übernehmen -->
	<xsl:template match="w:hyperlink">
		<xsl:variable name="targetID" select="@r:id"/>
		<xsl:variable name="target" select="//rel:Relationship[@Id = $targetID]/@Target"/>
		<rs ref="{$target}">
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="starts-with($target, 'thi')">thing</xsl:when>
					<xsl:when test="starts-with($target, 'per')">person</xsl:when>
					<xsl:when test="starts-with($target, 'pla')">place</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates select="w:r" />
		</rs>
	</xsl:template>
	<!-- „InternetLink“ wird von LibreOffice verwendet -->
	<xsl:template match="w:r[(wt:is(., 'Hyperlink', 'r') or wt:is(., 'InternetLink', 'r')) and not(w:sym)]">
		<xsl:value-of select="w:t" />
	</xsl:template>
	<!-- ENDE Links -->
	
	<!-- Fuß-/Endnoten -->
	<xsl:template match="w:r[w:endnoteReference]">
		<xsl:apply-templates select="w:endnoteReference"/>
	</xsl:template>
	
	<xsl:template match="w:endnotes"/>
	<xsl:template match="w:r[wt:is(., 'Endnotenzeichen', 'r') and not(w:endnoteReference)]" />
	
	<xsl:template match="w:endnoteReference">
		<xsl:variable name="wid" select="@w:id"/>
		<note type="footnote">
			<xsl:apply-templates select="//w:endnote[@w:id = $wid]//w:p"/>
		</note>
	</xsl:template>
	<xsl:template match="w:endnote/w:p">
		<xsl:apply-templates select="w:r | w:hyperlink" />
	</xsl:template>
	<!-- ENDE Fuß-/Endnoten -->
	
	<!-- kritische Anmerkungen -->
	<xsl:template match="w:footnotes"/>
	<xsl:template match="w:r[wt:is(., 'Funotenzeichen', 'r') and not(w:footnoteReference)]" />
	<xsl:template match="w:r[wt:is(., 'Funotenzeichen', 'r') and w:footnoteReference]">
		<xsl:apply-templates select="w:footnoteReference" />
	</xsl:template>
	<xsl:template match="w:r">
		<xsl:apply-templates select="w:footnoteReference | w:endnoteReference | w:t" />
	</xsl:template>
	
	<xsl:template match="w:footnoteReference">
		<xsl:if test="not(wt:is(parent::w:r, 'TBkritischeAnmerkungbermehrereWrter', 'r'))
			and wt:is(parent::w:r/preceding-sibling::w:r[1], 'TBkritischeAnmerkungbermehrereWrter', 'r')">
			<anchor type="crit_app" ref="se" />
		</xsl:if>
		<note type="crit_app">
			<xsl:variable name="wid" select="@w:id"/>
			<xsl:apply-templates select="//w:footnote[@w:id = $wid]/w:p/w:r" />
		</note>
	</xsl:template>
	
	<!-- w:hyperlink steht auf gleicher Ebene wie w:r; da außerdem je AbsAatz transkribiert wird, passen hier Tests
		auf preceding/following sibling -->
	<!-- TODO Prüfen, wie dies mit Marginalinen zusammenspielt -->
	<xsl:template match="w:r[wt:isFirst(., 'TBkritischeAnmerkungbermehrereWrter', 'r')
		and following-sibling::w:r[1][wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r')]]">
		<anchor type="crit_app" ref="s"/>
		<xsl:apply-templates select="w:t" />
	</xsl:template>
	<xsl:template match="w:r[wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r') and
		not(following-sibling::w:r[1][wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r')])]">
		<xsl:if test="not(preceding-sibling::w:r[1][wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r')])">
			<anchor type="crit_app" ref="s" />
		</xsl:if>
		<xsl:apply-templates select="w:t" />
		<!--<anchor type="crit_app" ref="se" />-->
	</xsl:template>
	<!-- es kommen krit. oder Sachanmerkungen innerhalb dieses Teils vor -->
	<xsl:template match="w:r[not(wt:isFirst(., 'TBkritischeAnmerkungbermehrereWrter', 'r'))
		and wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r')
		and following-sibling::w:r[1][wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r')]
		and preceding-sibling::w:r[1][wt:is(., 'TBkritischeAnmerkungbermehrereWrter', 'r')]]">
		<xsl:apply-templates select="w:t | w:footnoteReference | w:endnoteReference"/>
	</xsl:template>
	<!-- ENDE kritische Anm. -->
	
	<xsl:template match="w:r[wt:is(., 'bookref', 'r')]">
		<ref type="bibl">
			<xsl:choose>
				<xsl:when test="w:rPr/w:i[not(@w:val=0)]">
					<hi style="font-style: italic;"><xsl:value-of select="w:t"/></hi>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="w:t"/>
				</xsl:otherwise>
			</xsl:choose>
		</ref>
	</xsl:template>
	
	<xsl:template match="rel:Relationships"/>
	
	<xsl:template match="w:t"><xsl:value-of select="."/></xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="wt:hexToDec">
		<xsl:param name="hex"/>
		<xsl:variable name="dec"
			select="string-length(substring-before('0123456789ABCDEF', substring($hex,1,1)))"/>
		<xsl:choose>
			<xsl:when test="matches($hex, '([0-9]*|[A-F]*)')">
				<xsl:value-of
					select="if ($hex = '') then 0
					else $dec * math:pow(16, string-length($hex) - 1) + wt:hexToDec(substring($hex,2))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Provided value is not hexadecimal...</xsl:message>
				<xsl:value-of select="$hex"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>