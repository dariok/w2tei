<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:hab="http://diglib.hab.de"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="../string-pack.xsl"/>
	<xsl:include href="../word-pack.xsl"/>
	
	<!-- Kopf-Zeug -->
	<!-- Bearbeiter/Autor; 2017-05-03 DK -->
	<xsl:template match="w:p[wdb:is(., 'KSEE-Titel') and wdb:starts(., 'Bearb')]" mode="head">
		<xsl:variable name="aut" select="substring-after(wdb:string(.), 'von')"/>
		<xsl:analyze-string select="$aut" regex="(,|und)">
			<xsl:non-matching-substring>
				<author><xsl:value-of select="normalize-space()"/></author>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="w:p[wdb:is(., 'KSEE-Titel')]" mode="date">
		<xsl:variable name="pdline" select="wdb:string(.)"/>
		<!-- RegEx aktualisiert; hoffentlich geht das auf eXist...; 2017-08-07 DK -->
		<xsl:analyze-string select="normalize-space($pdline)" regex="(?:([\[\]A-Za-z ]+), )?([\[\]\w\sä\?,\./]+)">
			<xsl:matching-substring>
				<xsl:if test="string-length(regex-group(1)) &gt; 1">
					<placeName><xsl:if test="starts-with(regex-group(1), '[')">
						<xsl:attribute name="cert">unknown</xsl:attribute>
					</xsl:if>
						<xsl:analyze-string select="regex-group(1)"
							regex="\[?([\w\?]+)\]?">
							<xsl:matching-substring>
								<xsl:value-of select="regex-group(1)"/>
							</xsl:matching-substring>
						</xsl:analyze-string></placeName>
					<!--					<xsl:text>, </xsl:text>-->
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
								<xsl:value-of select="concat($numYear, '-', $month, '-', 
									format-number($num, '00'))" />
							</xsl:when>
							<xsl:when test="substring-after(substring-before($day, '.'), ' ')
								castable as xs:integer">
								<xsl:variable name="num" select="number(substring-after(substring-before($day, '.'), ' '))"/>
								<xsl:value-of select="concat($numYear, '-', $month, '-', 
									format-number($num, '00'))" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($numYear, '-', $month)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="starts-with(regex-group(2), '[') and
						ends-with(regex-group(2), ']')">
						<xsl:attribute name="cert">unknown</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="starts-with($year, '[') and ends-with($year, ']')">
							<supplied><xsl:value-of
								select="substring-after(substring-before($year, ']'), '[')"/></supplied>
						</xsl:when>
						<xsl:when test="ends-with($year, ']')">
							<supplied><xsl:value-of
								select="substring-before($year, ']')"/></supplied>
						</xsl:when>
						<xsl:when test="starts-with($year, '[')">
							<xsl:value-of select="substring-after($year, '[')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$year" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>, </xsl:text>
					<xsl:choose>
						<xsl:when test="starts-with(normalize-space($date), '[') and ends-with($date, ']')">
							<supplied><xsl:value-of
								select="substring-after(substring-before($date, ']'), '[')"/></supplied>
						</xsl:when>
						<xsl:when test="starts-with($year, '[') and ends-with($date, ']')">
							<xsl:value-of select="normalize-space(substring-before($date, ']'))"/>
						</xsl:when>
						<xsl:when test="starts-with(normalize-space($day), '[') and ends-with($day, ']')">
							<supplied><xsl:value-of select="substring-after($day, '[')"/></supplied>
							<xsl:value-of select="$month"/>
						</xsl:when>
						<xsl:when test="ends-with($date, ']')">
							<xsl:value-of select="normalize-space(substring-before($date, ']'))" />
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
	<xsl:template match="w:p[wdb:is(., 'KSEE-Titel')]" />
	<!-- ENDE Kopf-Zeug -->
	
	<!-- Styles -->
	<xsl:template match="w:r[descendant::w:i and preceding-sibling::w:r[1][descendant::w:i]]"/>
	<xsl:template match="w:r[descendant::w:i and not(preceding-sibling::w:r[1][descendant::w:i])]">
		<hi style="font-style:italic;"><xsl:apply-templates select="w:t | following-sibling::w:r[descendant::w:i
			and preceding-sibling::w:r[1][descendant::w:i]]/w:t" /></hi>
	</xsl:template>
	
	<xsl:template match="w:r[not(descendant::w:vertAlign or descendant::w:i
		or w:endnoteReference or w:footnoteReference)]">
		<xsl:apply-templates select="w:t | w:br" />
	</xsl:template>
	<!-- Ende Styles -->
	
	<!-- neu 2017-10-15 DK -->
	<xsl:template match="w:p[wdb:is(., 'KSZitatblock')]">
		<cit>
			<quote>
				<xsl:apply-templates select="w:r[not(wdb:is(., 'KSbibliographischeAngabe', 'r')
					or wdb:is(., 'EndnoteReference', 'r'))]"/>
			</quote>
			<xsl:apply-templates select="w:r[wdb:is(., 'KSbibliographischeAngabe', 'r')
				or wdb:is(., 'EndnoteReference', 'r')]"/>
		</cit>
	</xsl:template>
	<xsl:template match="w:br[ancestor::w:p[wdb:is(., 'KSZitatblock')]]">
		<lb/>
	</xsl:template>
	
	<!-- Fuß-/Endnoten -->
	<xsl:template match="w:r[w:endnoteReference]">
		<xsl:apply-templates select="w:endnoteReference" />
	</xsl:template>
	<!-- (auch) zur einfacheren Verarbeitung im XSpec; 2017-10-31 DK -->
	<xsl:template match="w:endnotes" />
	<!-- neu 2017-08-07 DK -->
	<xsl:template match="w:endnoteReference">
		<xsl:variable name="wid" select="@w:id"/>
		<note type="footnote">
			<xsl:apply-templates select="//w:endnote[@w:id = $wid]/w:p/w:r" />
		</note>
	</xsl:template>
	<!-- ENDE Fuß-/Endnoten -->
	
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
</xsl:stylesheet>