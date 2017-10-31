<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
	xmlns:hab="http://diglib.hab.de"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	<!-- neu für Projekt Rist, 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	<!-- übernommen für Karlstadt Einleitungen; 2017-05-03 DK -->
	
	<xsl:output indent="yes"/>
	
	<xsl:variable name="fline">
		<xsl:value-of select="string-join(//w:body/w:p[1]//w:t, '')" />
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
			<xsl:attribute name="xml:id" select="concat('edoc_ed000240_', $ee, '_introduction')" />
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title>
							<xsl:apply-templates select="//w:p[hab:is(., 'KSEE-Titel')][2]//w:t" mode="mTitle" />
							<xsl:apply-templates select="//w:p[hab:is(., 'KSEE-Titel')][3]" mode="date"/>
						</title>
						<!-- Kurztitel erzeugen; 2017-08-07 DK -->
						<title type="short">
							<xsl:if test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'">
								<xsl:text>Verschollen: </xsl:text>
							</xsl:if>
							<xsl:variable name="title">
								<xsl:apply-templates select="//w:p[hab:is(., 'KSEE-Titel')][2]//w:t" mode="mTitle" />
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$title/*:lb">
									<xsl:value-of select="$title/text()[following-sibling::*:lb]"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$title"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'
									or ends-with(hab:string(//w:p[hab:is(., 'KSEE-Titel')][3]), ']')">
									<xsl:text> [</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> (</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:variable name="dpline">
								<xsl:apply-templates select="//w:p[hab:is(., 'KSEE-Titel')][3]"
									mode="date"/>
							</xsl:variable>
							<xsl:apply-templates select="$dpline/*:date" mode="header"/>
							<xsl:choose>
								<xsl:when test="//w:p[hab:isHead(., 1)][1]//w:t='Referenz'
									or ends-with(hab:string(//w:p[hab:is(., 'KSEE-Titel')][3]), ']')">
									<xsl:text>]</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>)</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</title>
						<xsl:apply-templates select="//w:p[hab:is(., 'KSEE-Titel') and hab:starts(., 'Bearb')]"
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
	
	<xsl:template match="w:body">
		<xsl:apply-templates select="descendant::w:p[hab:isHead(., 1)]"/>
	</xsl:template>
	
	<!-- Bearbeiter/Autor; 2017-05-03 DK -->
	<xsl:template match="w:p[hab:is(., 'KSEE-Titel') and hab:starts(., 'Bearb')]" mode="head">
		<xsl:variable name="aut" select="substring-after(hab:string(.), 'von')"/>
		<xsl:analyze-string select="$aut" regex="(,|und)">
			<xsl:non-matching-substring>
				<author><xsl:value-of select="normalize-space()"/></author>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- Titel mit Untertitel; 2017-10-26 DK -->
	<xsl:template match="w:t" mode="mTitle">
		<xsl:analyze-string select="." regex="\.">
			<xsl:matching-substring>
				<lb/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- Ort/Datum zusammensetzen; 2017-05-16 DK -->
	<!-- fertiggestellt 2017-06-05 DK -->
	<xsl:template match="w:p[hab:is(., 'KSEE-Titel')]" mode="date">
		<xsl:variable name="pdline" select="hab:string(.)"/>
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
	<xsl:template match="w:p[hab:is(., 'KSEE-Titel')]" />
	
	<!-- Grobgliederung; 2017-06-05 DK -->
	<xsl:template match="w:p[hab:isHead(., 1)]">
		<div>
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="hab:starts(., 'Überlieferung')">history_of_the_work</xsl:when>
					<xsl:when test="hab:starts(., 'Entstehung und Inhalt')">contents</xsl:when>
					<xsl:when test="hab:starts(., 'Referenz')">reference</xsl:when>
					<xsl:when test="hab:starts(., 'Inhaltliche Hinweise')">evidence</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:choose>
				<xsl:when test="not(following-sibling::w:p[hab:isHead(., 2)])
					and not(following-sibling::w:p[hab:isHead(., 1)])">
					<xsl:apply-templates select="following-sibling::w:p" />
				</xsl:when>
				<xsl:when test="not(following-sibling::w:p[hab:isHead(., 2)])
					and following-sibling::w:p[hab:isHead(., 1)]">
					<xsl:apply-templates select="following-sibling::w:p[not(hab:isHead(., 1))
						and not(preceding-sibling::w:p[hab:isHead(., 1)][2])]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="following-sibling::w:p[hab:isHead(., 2)]"/>
					<xsl:apply-templates select="following-sibling::w:p[not(following-sibling::w:p[hab:isSigle(.)])
						and (hab:starts(., 'Edition') or hab:starts(., 'Literatur')) and not(hab:starts(., 'Editionsvorlage'))]"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- Untergliederung im 1. div; 2017-06-05 DK -->
	<xsl:template match="w:p[hab:isHead(., 2) and descendant::w:t]">
		<xsl:variable name="myId" select="generate-id()" />
		<listBibl type="sigla">
			<xsl:apply-templates select="following-sibling::w:p[hab:isSigle(.)
				and generate-id(preceding-sibling::w:p[hab:isHead(., 2)][1]) = $myId]"/>
		</listBibl>
	</xsl:template>
	
	<xsl:template match="w:p[hab:isSigle(.) and hab:starts(preceding-sibling::w:p[hab:isHead(., 2)][1], 'Früh')]">
		<xsl:variable name="end"
			select="following-sibling::w:p[hab:starts(., 'Bibliographische')][1]" />
		<xsl:variable name="struct" select="current() | 
			current()/following::w:p intersect $end/preceding::w:p | $end" />
		<xsl:variable name="idNo">
			<xsl:analyze-string select="hab:string(w:r[hab:isSigle(.)])"
				regex="\[(\w+).?\]">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<biblStruct type="imprint">
			<xsl:attribute name="xml:id" select="$idNo" />
			<xsl:variable name="elem">
				<xsl:choose>
					<xsl:when test="following-sibling::w:p[2][hab:starts(., 'in')]">
						<xsl:text>analytic</xsl:text>
					</xsl:when>
					<xsl:otherwise>monogr</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="{$elem}">
				<xsl:variable name="au">
					<xsl:apply-templates select="descendant::w:t" />
				</xsl:variable>
				<author>
					<xsl:value-of select="normalize-space(substring-after($au, ']'))"/></author>
				<title><xsl:apply-templates select="following-sibling::w:p[1]//w:t" mode="titleContent"/></title>
				<xsl:if test="not($struct[3]//w:t[starts-with(normalize-space(), 'in')])">
					<xsl:call-template name="imprint">
						<xsl:with-param name="context" select="$struct[3]" />
					</xsl:call-template>
				</xsl:if>
			</xsl:element>
			<xsl:if test="$struct//w:t[starts-with(., 'Editions')]">
				<xsl:variable name="pos"
					select="index-of($struct, ($struct//w:t[starts-with(., 'Editions')]/ancestor::w:p)[1])" />
				<xsl:if test="$struct[3]//w:t[starts-with(normalize-space(), 'in')]">
					<monogr>
						<xsl:choose>
							<xsl:when test="$pos > 7">
								<author><xsl:apply-templates select="$struct[4]//w:t" /></author>
								<title><xsl:apply-templates select="$struct[position() > 4 and position() &lt; ($pos - 2)]//w:t" /></title>
							</xsl:when>
							<xsl:otherwise>
								<title><xsl:apply-templates select="$struct[4]//w:t" /></title>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="imprint">
							<xsl:with-param name="context" select="$struct[$pos - 2]" />
						</xsl:call-template>
					</monogr>
				</xsl:if>
				<idno type="siglum"><xsl:value-of select="$idNo" /></idno>
				<note type="copies">
					<list>
						<xsl:apply-templates select="$struct[hab:starts(., 'Editionsv')
							or hab:starts(., 'Weitere')]" mode="item" />
					</list>
				</note>
				<note type="references">
					<listBibl>
						<xsl:variable name="weitere">
							<xsl:apply-templates select="$struct[hab:starts(., 'Bibliographische')]//w:r" />
						</xsl:variable>
						<xsl:for-each select="tokenize(substring-after($weitere, ':'), '–|—')">
							<bibl>
								<!-- TODO ID aus bibliography übernehmen -->
								<xsl:value-of select="normalize-space(current())"/>
							</bibl>
						</xsl:for-each>
					</listBibl>
					<xsl:apply-templates select="$struct[last()]/following-sibling::w:p
						intersect $struct[last()]/following-sibling::w:p[hab:isSigle(.)][1]/preceding-sibling::w:p"/>
				</note>
			</xsl:if>
		</biblStruct>
	</xsl:template>
	
	<!-- neu 2017-10-15 DK -->
	<xsl:template match="w:p" mode="item">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<item n="editionsvorlage">
						<xsl:variable name="temp">
							<hab:t>
								<xsl:apply-templates select="w:r[hab:contains(preceding-sibling::w:r, 'vorlage')]
									| w:commentRangeEnd" mode="item"/>
							</hab:t>
						</xsl:variable>
						<xsl:apply-templates select="$temp" mode="ex" />
					</item>
				</xsl:when>
				<xsl:otherwise>
					<!-- leere Exemplarangaben abfangen; 2017-10-24 DK -->
					<xsl:if test="w:r[hab:contains(., 'plare')] and string-length(hab:string(.)) &gt; 20">
						<xsl:variable name="t1">
							<hab:t>
								<xsl:apply-templates select="w:r[hab:contains(preceding-sibling::w:r, 'plare')]
									| w:commentRangeEnd" mode="item"/>
							</hab:t>
						</xsl:variable>
						<xsl:variable name="t2">
							<xsl:apply-templates select="$t1" mode="split"/>
						</xsl:variable>
						<xsl:apply-templates select="$t2/hab:br"/>
						<item>
							<xsl:variable name="t3">
								<hab:t>
									<xsl:copy-of select="$t2/node()[not(following-sibling::hab:br)]"/>
								</hab:t>
							</xsl:variable>
							<xsl:apply-templates select="$t3" mode="ex" />
						</item>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>
	
	<!-- Angaben zu Exemplaren; 2017-10-28 DK -->
	<xsl:template match="w:r | w:commentRangeEnd" mode="item">
		<xsl:choose>
			<xsl:when test="hab:is(., 'KSAnmerkunginberlieferung', 'r')
				and preceding-sibling::w:r[1][hab:is(., 'KSAnmerkunginberlieferung', 'r')]"/>
			<xsl:when test="hab:is(., 'KSAnmerkunginberlieferung', 'r')
				and not(preceding-sibling::w:r[1][hab:is(., 'KSAnmerkunginberlieferung', 'r')])">
				<note>
					<xsl:variable name="anmerkung">
						<xsl:apply-templates select=". | following-sibling::w:r[hab:is(., 'KSAnmerkunginberlieferung', 'r')]"/>
					</xsl:variable>
					<xsl:for-each select="$anmerkung/node()">
						<xsl:choose>
							<xsl:when test="self::text()">
								<xsl:value-of select="hab:substring-before-if-ends(hab:substring-after-if-starts(current(), '('), ')')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					
				</note>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Exemplare in Literaturlisten trennen -->
	<!-- neu 2017-10-24 DK -->
	<xsl:template match="hab:t" mode="ex">
		<xsl:variable name="temp">
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test="self::text() and contains(., ' , ')">
						<xsl:value-of select="substring-before(., ' , ')"/>
						<idno><xsl:value-of select="normalize-space(substring-after(., ' , '))"/></idno>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
		<label>
			<xsl:for-each select="$temp/node()[following-sibling::*:idno]">
				<xsl:choose>
					<xsl:when test="self::text()">
						<xsl:value-of select="normalize-space(hab:substring-after(current(), ':'))"/>
					</xsl:when>
					<xsl:when test="self::hab:br" />
					<xsl:otherwise>
						<xsl:copy-of select="current()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</label>
		<xsl:variable name="strings" select="tokenize($temp/*:idno, '\(')"/>
		<idno type="signatur">
			<xsl:choose>
				<xsl:when test="count($strings) = 3">
					<xsl:value-of select=" $strings[1]"/>
					<xsl:value-of select="concat('(', normalize-space($strings[2]))"/>
				</xsl:when>
				<xsl:when test="count($strings) = 2 and string-length($strings[2]) &lt; 10">
					<xsl:value-of select=" $strings[1]"/>
					<xsl:value-of select="concat('(', normalize-space($strings[2]))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$strings[1]"/>
				</xsl:otherwise>
			</xsl:choose>
		</idno>
		<xsl:copy-of select="*:note" />
		<xsl:copy-of select="*:ptr"/>
	</xsl:template>
	
	<xsl:template match="hab:t" mode="split">
		<xsl:for-each select="node()">
			<xsl:choose>
				<xsl:when test="self::text()">
					<xsl:analyze-string select="." regex="–|—">
						<xsl:matching-substring><hab:br/></xsl:matching-substring>
						<xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="hab:br">
		<xsl:variable name="myId" select="generate-id()" />
		<xsl:variable name="temp">
			<hab:t>
				<xsl:copy-of select="preceding-sibling::node()[following-sibling::hab:br[1][generate-id()=$myId]]"/>
			</hab:t>
		</xsl:variable>
		<item>
			<xsl:apply-templates select="$temp" mode="ex" />
		</item>
	</xsl:template>
	<!-- ENDE Exemplare trennen -->
	
	<xsl:template match="w:p[hab:isSigle(.)
		and hab:starts(preceding-sibling::w:p[hab:isHead(., 2)][1], 'Hand')]">
		<xsl:variable name="myId" select="generate-id()"/>
		<msDesc>
			<xsl:variable name="desc" select="hab:string(w:r[not(hab:isSigle(.))])" />
			<xsl:variable name="md" select="tokenize($desc, ' , ')" />
			<xsl:variable name="si"
				select="hab:string(w:r[hab:isSigle(.)])" />
			<xsl:variable name="sigle">
				<xsl:value-of select="hab:substring-before(hab:rmSquare($si), ':')"/>
			</xsl:variable>
			<xsl:if test="string-length($si) &gt; 1">
				<!-- Fälle besser behandeln; 2017-10-12 -->
				<xsl:attribute name="xml:id" select="$sigle"/>
			</xsl:if>
			<msIdentifier>
				<xsl:if test="string-length($si) &gt; 1">
					<altIdentifier type="siglum">
						<idno><xsl:value-of select="$sigle"/></idno>
					</altIdentifier>
				</xsl:if>
				<repository><xsl:value-of select="normalize-space($md[1])"/></repository>
				<idno type="signatur">
					<xsl:choose>
						<xsl:when test="contains($md[2], '(') and contains($md[2], ')')">
							<!-- ggf. Punkt entfernen -->
							<xsl:variable name="str" select="normalize-space(substring-before($md[2], '('))"/>
							<xsl:choose>
								<xsl:when test="ends-with($str, '.')">
									<xsl:value-of select="substring($str, 1, string-length($str)-1)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$str"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$md[2]"/>
						</xsl:otherwise>
					</xsl:choose>
				</idno>
			</msIdentifier>
			<xsl:if test="$md[3]">
				<msContents>
					<msItem>
						<locus>
							<xsl:choose>
								<xsl:when test="contains($md[3], '(')">
									<xsl:value-of select="normalize-space(substring-before($md[3], '('))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space($md[3])" />
								</xsl:otherwise>
							</xsl:choose>
						</locus>
						<xsl:apply-templates select="descendant::w:endnoteReference" />
					</msItem>
				</msContents>
			</xsl:if>
			<physDesc>
				<xsl:if test="contains($md[3], '(')">
					<handDesc>
						<handNote>
							<xsl:value-of select="substring-before(substring-after($md[3], '('), ')')"/>
						</handNote>
					</handDesc>
				</xsl:if>
				<!-- falls keine Seitenangabe vorhanden -->
				<xsl:if test="not($md[3]) and contains($md[2], '(')">
				<handDesc>
					<handNote>
						<xsl:value-of select="substring-before(substring-after($md[2], '('), ')')"/>
					</handNote>
				</handDesc>
				</xsl:if>
				<xsl:if test="following-sibling::w:p[1]/w:r/w:commentReference">
					<xsl:variable name="link">
						<xsl:variable name="ln" select="following-sibling::w:p[1]/w:r/w:commentReference/@w:id" />
						<xsl:value-of select="normalize-space(string-join(//w:comment[@w:id = $ln]//w:t, ''))" />
					</xsl:variable>
					<p><ptr type="digitalisat" target="{$link}"/></p>
				</xsl:if>
				<xsl:apply-templates select="following-sibling::w:p[not(hab:starts(., 'Edition') or hab:starts(., 'Literatur'))
					and following-sibling::w:p[hab:isHead(., 1)]
					and generate-id(preceding-sibling::w:p[hab:isSigle(.)][1]) = $myId]"/>
			</physDesc>
		</msDesc>
	</xsl:template>
	
	<xsl:template match="w:p[hab:starts(., 'Edition') or hab:starts(., 'Literatur')]">
		<listBibl>
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="hab:starts(., 'Edi')">editions</xsl:when>
					<xsl:otherwise>literatur</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="preceding-sibling::w:p[1][hab:starts(., 'Beilage')]">
				<head><xsl:apply-templates select="preceding-sibling::w:p[1]/w:r"/></head>
			</xsl:if>
			<xsl:apply-templates select="w:r[hab:is(., 'KSbibliographischeAngabe', 'r')
				and not(preceding-sibling::w:r[1][hab:is(., 'KSbibliographischeAngabe', 'r')])]" mode="bibl" />
				<!--and preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
				or descendant::w:rStyle[@w:val='Kommentarzeichen']
				or descendant::w:commentReference)]]" mode="bibl"/>-->
		</listBibl>
	</xsl:template>
	
	<!-- neu 2017-10-15 DK -->
	<xsl:template match="w:p[hab:is(., 'KSZitatblock')]">
		<cit>
			<quote>
				<xsl:apply-templates select="w:r[not(hab:is(., 'KSbibliographischeAngabe', 'r')
					or hab:is(., 'EndnoteReference', 'r'))]"/>
			</quote>
			<xsl:apply-templates select="w:r[hab:is(., 'KSbibliographischeAngabe', 'r')
				or hab:is(., 'EndnoteReference', 'r')]"/>
		</cit>
	</xsl:template>
	<xsl:template match="w:br[ancestor::w:p[hab:is(., 'KSZitatblock')]]">
		<lb/>
	</xsl:template>
	
	<xsl:template name="imprint">
		<xsl:param name="context" />
		<xsl:variable name="imprintText">
			<xsl:apply-templates select="$context/w:r" />
		</xsl:variable>
		
		<xsl:variable name="imp">
			<xsl:for-each select="$imprintText/node()">
				<xsl:choose>
					<xsl:when test="self::text()">
						<xsl:analyze-string select="." regex="(.*): ([^,]*), ([^,]*)">
							<xsl:matching-substring>
								<hab:odj><xsl:value-of select="."/></hab:odj>
							</xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:value-of select="."/>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:analyze-string select="$imp/hab:odj" regex="(.*): ([^,]*), ([^,]*)">
			<xsl:matching-substring>
				<imprint>
					<pubPlace>
						<xsl:if test="starts-with(regex-group(1), '[')">
							<xsl:attribute name="cert">unknown</xsl:attribute>
						</xsl:if>
						<rs type="place">
							<xsl:value-of select="hab:rmSquare(regex-group(1))"/>
						</rs>
					</pubPlace>
					<publisher>
						<xsl:if test="starts-with(regex-group(2), '[')">
							<xsl:attribute name="cert">unknown</xsl:attribute>
						</xsl:if>
						<rs type="person">
							<xsl:value-of select="hab:rmSquare(regex-group(2))"/>
						</rs>
					</publisher>
					<xsl:variable name="dWhen">
						<xsl:choose>
							<xsl:when test="ends-with(hab:rmSquare(regex-group(3)), '.')">
								<xsl:value-of select="substring-before(hab:rmSquare(regex-group(3)), '.')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="hab:rmSquare(regex-group(3))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<date when="{$dWhen}">
						<xsl:if test="ends-with(regex-group(3), ']')">
							<xsl:attribute name="cert">unknown</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$dWhen"/>
					</date>
				</imprint>
				<extent><xsl:apply-templates select="$context/following-sibling::w:p[1]/w:r"/></extent>
			</xsl:matching-substring>
		</xsl:analyze-string>
		
		<xsl:if test="$imp/node()[preceding-sibling::hab:odj]">
			<biblScope>
				<xsl:for-each select="$imp/node()[preceding-sibling::hab:odj]">
					<xsl:choose>
						<xsl:when test="position() = 1 and self::text()">
							<xsl:value-of select="hab:substring-after(., ', ')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</biblScope>
		</xsl:if>
		
		<!--<xsl:analyze-string select="$imprintText"
			regex="(.*): ([^,]*), ([^,]*),? ?(.*)??">
			<xsl:matching-substring>
				<imprint>
					<pubPlace>
						<xsl:if test="starts-with(regex-group(1), '[')">
							<xsl:attribute name="cert">unknown</xsl:attribute>
						</xsl:if>
						<rs type="place">
							<xsl:value-of select="hab:rmSquare(regex-group(1))"/>
						</rs>
					</pubPlace>
					<publisher>
						<xsl:if test="starts-with(regex-group(2), '[')">
							<xsl:attribute name="cert">unknown</xsl:attribute>
						</xsl:if>
						<rs type="person">
							<xsl:value-of select="hab:rmSquare(regex-group(2))"/>
						</rs>
					</publisher>
					<xsl:variable name="dWhen">
						<xsl:choose>
							<xsl:when test="ends-with(hab:rmSquare(regex-group(3)), '.')">
								<xsl:value-of select="substring-before(hab:rmSquare(regex-group(3)), '.')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="hab:rmSquare(regex-group(3))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<date when="{$dWhen}">
						<xsl:if test="ends-with(regex-group(3), ']')">
							<xsl:attribute name="cert">unknown</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$dWhen"/>
					</date>
				</imprint>
				<extent><xsl:apply-templates select="$context/following-sibling::w:p[1]/w:r"/></extent>
				<xsl:if test="regex-group(4)">
					<biblScope><xsl:apply-templates select="normalize-space(regex-group(4))" /></biblScope>
				</xsl:if>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:copy-of select="." />
			</xsl:non-matching-substring>
		</xsl:analyze-string>-->
	</xsl:template>
	
	<!-- leere p abfangen; 2017-10-24 DK -->
	<xsl:template match="w:p[not(descendant::w:t) or string-length(hab:string(.)) &lt; 5]" />
	<xsl:template match="w:p[(not(descendant::w:pStyle)
		or hab:is(., 'KSText')) and not(hab:isSigle(.) or hab:starts(., 'Edition') or
		hab:starts(., 'Literatur')) and descendant::w:t and string-length(hab:string(.)) &gt; 5]">
		<!-- Endnoten berücksichtigen; 2017-08-08 DK -->
		<p><xsl:apply-templates select="w:r" /></p>
	</xsl:template>
	
	<!-- Style von Textabschnitten -->
	<!-- hochgestellte -->
	<xsl:template match="w:r[descendant::w:vertAlign
		and not(w:endnoteReference or w:footnoteReference)]">
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
	
	<xsl:template match="w:r[w:endnoteReference]">
		<xsl:apply-templates select="w:endnoteReference" />
	</xsl:template>
	<!-- (auch) zur einfacheren Verarbeitung im XSpec; 2017-10-31 DK -->
	<xsl:template match="w:endnotes" />
	
	<!-- neu 2017-06-11 DK -->
	<xsl:template match="w:t" mode="exemplar">
		<xsl:apply-templates />
		<xsl:apply-templates select="parent::w:r/following-sibling::*[1][self::w:commentRangeEnd]" mode="exemplar"/>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:variable name="text">
			<xsl:apply-templates select="hab:string(//w:comment[@w:id=$coID])"/>
		</xsl:variable>
		<xsl:if test="contains($text, 'http')">
			<ptr type="digitalisat" target="{'http'||hab:substring-after($text, 'http')}" />
		</xsl:if>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd" mode="exemplar">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:text>→</xsl:text>
		<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
	</xsl:template>

	<!-- (auch) für Verabreitung im XSPEC -->
	<xsl:template match="w:comments" mode="item" />
	
	<xsl:template match="w:r" mode="bibl">
		<xsl:variable name="me" select="generate-id()" />
		<xsl:variable name="next" select="following-sibling::w:r[ancestor::w:body and hab:is(., 'KSbibliographischeAngabe', 'r')
			and not(preceding-sibling::w:r[1][hab:is(., 'KSbibliographischeAngabe', 'r')])][1]" />
		<bibl>
			<xsl:choose>
				<xsl:when test="$next">
					<xsl:apply-templates select="descendant::w:t |
						following-sibling::w:r[descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
							and preceding-sibling::w:r[generate-id()=$me]
							and following::w:r[generate-id() = $next]]//w:t" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="descendant::w:t |
						following-sibling::w:r[descendant::w:rStyle[@w:val='KSbibliographischeAngabe']]//w:t" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="following-sibling::w:commentRangeEnd[generate-id(preceding-sibling::w:r[
				preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe'])]][1])
				= $me]" />
			<xsl:if test="following-sibling::w:r[descendant::w:rStyle[@w:val='KSAnmerkunginberlieferung']
				and following::w:r[generate-id() = $next]]">
				<xsl:apply-templates select="following-sibling::w:r[descendant::w:rStyle[@w:val='KSAnmerkunginberlieferung'] and
					following::w:r[generate-id() = $next]]" />
			</xsl:if>
			<!-- FN berücksichtigen; 2017-08-07 DK -->
			<xsl:choose>
				<xsl:when test="$next">
					<xsl:apply-templates select="following-sibling::w:r[w:endnoteReference
						and following-sibling::w:r[generate-id() = $next]]/w:endnoteReference"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="following-sibling::w:r/w:endnoteReference" />
				</xsl:otherwise>
			</xsl:choose>
		</bibl>
	</xsl:template>
	
	<!-- neu 2017-08-07 DK -->
	<xsl:template match="w:endnoteReference">
		<xsl:variable name="wid" select="@w:id"/>
		<note type="footnote">
			<xsl:apply-templates select="//w:endnote[@w:id = $wid]/w:p/w:r" />
		</note>
	</xsl:template>
	
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
		<xsl:value-of select="hab:is($context, 'KSberschrift'||$num)"/>
	</xsl:function>
	
	<xsl:function name="hab:isSigle" as="xs:boolean">
		<xsl:param name="context" as="node()" />
		<xsl:value-of select="hab:is($context/descendant-or-self::w:r, 'KSSigle', 'r')"/>
	</xsl:function>
	
	<xsl:function name="hab:is" as="xs:boolean">
		<xsl:param name="context" />
		<xsl:param name="test"/>
		<xsl:value-of select="hab:is($context, $test, 'p')"/>
	</xsl:function>
	<xsl:function name="hab:is" as="xs:boolean">
		<xsl:param name="context" />
		<xsl:param name="test"/>
		<xsl:param name="pr"/>
		<xsl:variable name="val">
			<xsl:choose>
				<xsl:when test="$pr = 'p'">
					<xsl:value-of select="$context//w:pStyle/@w:val"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$context//w:rStyle/@w:val"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="contains($val, $test)"/>
	</xsl:function>
	
	<xsl:function name="hab:starts" as="xs:boolean">
		<xsl:param name="elem" />
		<xsl:param name="test" />
		<xsl:value-of select="starts-with(hab:string($elem), $test)"/>
	</xsl:function>
	
	<xsl:function name="hab:contains" as="xs:boolean">
		<xsl:param name="elem" />
		<xsl:param name="test" />
		<xsl:value-of select="contains(hab:string($elem), $test)"/>
	</xsl:function>
	
	<xsl:function name="hab:string" as="xs:string">
		<xsl:param name="context" />
		<xsl:value-of select="string-join($context//w:t, '')"/>
	</xsl:function>
	
	<xsl:function name="hab:substring-after" as="xs:string">
		<xsl:param name="s" />
		<xsl:param name="c" />
		<xsl:value-of
			select="if (contains($s, $c)) then substring-after($s, $c) else $s" />
	</xsl:function>
	
	<xsl:function name="hab:substring-before" as="xs:string">
		<xsl:param name="s" />
		<xsl:param name="c" />
		<xsl:value-of
			select="if (contains($s, $c)) then substring-before($s, $c) else $s" />
	</xsl:function>
	
	<xsl:function name="hab:substring-before-if-ends">
		<xsl:param name="s" />
		<xsl:param name="c" />
		<xsl:variable name="l" select="string-length($s)" />
		<xsl:value-of select="if(ends-with($s, $c)) then substring($s, 1, $l - 1) else $s"/>
	</xsl:function>
	
	<xsl:function name="hab:substring-after-if-starts">
		<xsl:param name="s" />
		<xsl:param name="c" />
		<xsl:value-of select="if(starts-with($s, $c)) then substring($s, 2) else $s"/>
	</xsl:function>
</xsl:stylesheet>
