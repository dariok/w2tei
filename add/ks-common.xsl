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
	
	<xsl:variable name="fline">
		<xsl:value-of select="wdb:string(//w:body/w:p[1])" />
	</xsl:variable>
	<xsl:variable name="nr">
		<xsl:value-of select="normalize-space(hab:rmSquare(substring-after($fline, 'Nr.')))" />
	</xsl:variable>
	<xsl:variable name="ee">
		<xsl:variable name="nro" select="substring-before(substring-after($fline, 'EE '), ' ')" />
		<xsl:choose>
			<xsl:when test="$nro castable as xs:integer">
				<xsl:value-of select="format-number(number($nro), '000')" />
			</xsl:when>
			<xsl:when test="string-length($nro) &lt; 4">
				<xsl:value-of select="concat('0', $nro)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$nro" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<TEI xmlns="http://www.tei-c.org/ns/1.0"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://diglib.hab.de/edoc/ed000240/rules/tei-p5-transcr.xsd"
			n="{$nr}">
			<xsl:attribute name="xml:id">
				<xsl:choose>
					<xsl:when test="wdb:string(//w:body/w:p[not(wdb:is(., 'KSEE-Titel'))][1]) = 'Text'">
						<xsl:value-of select="concat('edoc_ed000240_', $ee, '_transcript')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('edoc_ed000240_', $ee, '_introduction')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title>
							<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel')][2]//w:t" mode="mTitle" />
							<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel')][3]" mode="date"/>
						</title>
						<!-- Kurztitel erzeugen; 2017-08-07 DK -->
						<title type="short">
							<xsl:if test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'">
								<xsl:text>Verschollen: </xsl:text>
							</xsl:if>
							<xsl:variable name="title">
								<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel')][2]//w:t" mode="mTitle" />
							</xsl:variable>
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
								<xsl:when test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'
									or ends-with(wdb:string(//w:p[wdb:is(., 'KSEE-Titel')][3]), ']')">
									<xsl:text> [</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> (</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:variable name="dpline">
								<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel')][3]"
									mode="date"/>
							</xsl:variable>
							<xsl:apply-templates select="$dpline/*:date" mode="header"/>
							<xsl:choose>
								<xsl:when test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'
									or ends-with(wdb:string(//w:p[wdb:is(., 'KSEE-Titel')][3]), ']')">
									<xsl:text>]</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>)</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</title>
						<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel') and wdb:starts(., 'Bearb')]"
							mode="head"/>
					</titleStmt>
					<publicationStmt>
						<publisher>
							<name type="org">Herzog August Bibliothek Wolfenbüttel</name>
							<ptr target="http://www.hab.de"/>
						</publisher>
						<date when="2017" type="created"/>
						<distributor>Herzog August Bibliothek Wolfenbüttel</distributor>
						<availability status="restricted">
							<p>Herzog August Bibliothek Wolfenbüttel (<ref target="http://diglib.hab.de/?link=012">copyright
								information</ref>)</p>
						</availability>
					</publicationStmt>
					<sourceDesc>
						<p>born digital</p>
						<xsl:if test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'">
							<msDesc><physDesc><objectDesc form="codex_lost"/></physDesc></msDesc>
						</xsl:if>
					</sourceDesc>
				</fileDesc>
				<encodingDesc>
					<p>Zeichen aus der Private Use Area entsprechen MUFI 3.0 (http://mufi.info)</p>
					<projectDesc>
						<p xml:id="kgk">
							<ref target="http://diglib.hab.de/edoc/ed000240/start.htm">Kritische Gesamtausgabe der Schriften und Briefe
								Andreas Bodensteins von Karlstadt</ref>
						</p>
					</projectDesc>
				</encodingDesc>
			</teiHeader>
			<text>
				<body>
					<xsl:apply-templates select="//w:body" />
				</body>
			</text>
		</TEI>
	</xsl:template>
	<!-- Ende root -->
	
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
	<!-- kursiv -->
	<xsl:template match="w:r[descendant::w:i]">
		<xsl:apply-templates select="." mode="eval" />
	</xsl:template>
	<xsl:template match="w:r[descendant::w:i and preceding-sibling::w:r[1][descendant::w:i]]" mode="eval"/>
	<xsl:template match="w:r[descendant::w:i and not(preceding-sibling::w:r[1][descendant::w:i])]" mode="eval">
		<hi style="font-style:italic;"><xsl:apply-templates select="w:t | following-sibling::w:r[descendant::w:i
			and preceding-sibling::w:r[1][descendant::w:i]]/w:t" /></hi>
	</xsl:template>
	
	<!-- hochgestellte -->
	<xsl:template match="w:r[descendant::w:vertAlign and not(w:endnoteReference or w:footnoteReference
		or hab:isSem(.))]">
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
	
	<xsl:template match="w:r[not(descendant::w:vertAlign or descendant::w:i
		or w:endnoteReference or w:footnoteReference or hab:isSem(.))]">
		<xsl:apply-templates select="w:t | w:br" />
	</xsl:template>
	<xsl:template match="w:r[not(descendant::w:vertAlign or descendant::w:i
		or w:endnoteReference or w:footnoteReference or hab:isSem(.))]" mode="eval">
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
		<xsl:variable name="temp">
			<xsl:apply-templates select="//w:endnote[@w:id = $wid]/w:p/w:r" />
		</xsl:variable>
		<note type="footnote">
			<xsl:for-each select="$temp/node()">
				<xsl:choose>
					<xsl:when test="position() = 1 and self::text() and starts-with(., ' ')">
						<xsl:value-of select="substring(., 2)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</note>
	</xsl:template>
	<!-- ENDE Fuß-/Endnoten -->
	
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
			'KSOrt|KSPerson|KSbibliographischeAngabe|KSBibelstelle|KSAutorenstelle')"/>
	</xsl:function>
</xsl:stylesheet>