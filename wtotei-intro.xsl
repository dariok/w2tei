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
	
<!--	<xsl:output indent="yes"/>-->
	
	<!-- die überwiegend genutzte Schriftgröße für Normaltext ermitteln; 2017-05-03 DK -->
	<!--<xsl:variable name="mainsize">
		<xsl:variable name ="t">
			<xsl:for-each-group select="//w:rPr/w:sz" group-by="@w:val">
				<xsl:sort select="count(current-group())" order="descending"/>
				<s>
					<xsl:value-of select="current-group()[1]/@w:val"/>
				</s>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:value-of select="$t/*[1]"/>
	</xsl:variable>-->
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
			xsi:schemaLocation="http://www.tei -c.org/ns/1.0 http://diglib.hab.de/edoc/ed000216/rules/tei-p5-transcr.xsd"
			n="{$nr}">
			<xsl:attribute name="xml:id" select="concat('edoc_ed000240_', $ee, '_introduction')" />
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title><xsl:apply-templates select="//w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel'][2]//w:t" mode="mTitle" />
							<xsl:apply-templates select="//w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel'][3]"
								mode="date"/></title>
						<!-- Kurztitel erzeugen; 2017-08-07 DK -->
						<title type="short">
							<xsl:if test="//w:p[descendant::w:pStyle[contains(@w:val, 'KSberschrift1')]][1]//w:t='Referenz'">
								<xsl:text>Verschollen: </xsl:text>
							</xsl:if>
							<xsl:apply-templates select="//w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel'][2]//w:t" mode="mTitle" />
							<xsl:text> (</xsl:text>
							<xsl:variable name="dpline">
								<xsl:apply-templates select="//w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel'][3]"
									mode="date"/>
							</xsl:variable>
							<xsl:value-of select="$dpline/*:date"/>
							<xsl:text>)</xsl:text>
						</title>
						<xsl:apply-templates select="(//w:p[starts-with(string-join(descendant::w:t, ''), 'Bearb')])[1]"
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
						<xsl:if test="//w:p[descendant::w:pStyle[contains(@w:val, 'KSberschrift1')]][1]//w:t='Referenz'">
							<msDesc><physDesc><objectDesc form="codex_lost"/></physDesc></msDesc>
						</xsl:if>
					</sourceDesc>
				</fileDesc>
				<encodingDesc>
					<p>Zeichen aus der Private Use Area entsprechen MUFI 3.0 (http://mufi.info)</p>
					<projectDesc>
						<p xml:id="kgk">
							<ref target="http://diglib.hab.de/edoc/ed000216/start.htm">Kritische Gesamtausgabe der Schriften und Briefe
								Andreas Bodensteins von Karlstadt</ref>
						</p>
					</projectDesc>
				</encodingDesc>
			</teiHeader>
			<text>
				<body>
					<xsl:apply-templates select="descendant::w:body"/>
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<!-- neu 2016-08-11 DK -->
	<!-- Word produziert ggf. leere Absätze oder Text in Body. Auch wenn diese für die Gliederung erwünscht sind,
		dürfen sie nicht ausgegeben werden -->
<!--	<xsl:template match="w:p[not(descendant::w:t)]" />-->
	<xsl:template match="w:p[not(descendant::w:t)]" mode="text" />
	<xsl:template match="w:body/text()" />
	
	<!-- Bearbeiter/Autor; 2017-05-03 DK -->
	<xsl:template match="w:p[starts-with(string-join(descendant::w:t, ''), 'Bearb')]" mode="head">
		<xsl:variable name="aut" select="substring-after(string-join(descendant::w:t, ''), 'Bearbeitet von ')"/>
		<xsl:analyze-string select="$aut" regex="(,|und)">
			<xsl:non-matching-substring>
				<author><xsl:value-of select="normalize-space()"/></author>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- Ort/Datum zusammensetzen; 2017-05-16 DK -->
	<!-- fertiggestellt 2017-06-05 DK -->
	<xsl:template match="w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel']" mode="date">
		<xsl:variable name="pdline">
<!--			<xsl:apply-templates select="w:r/w:t" mode="pdContent" />-->
			<xsl:value-of select="string-join(descendant::w:t, '')" />
		</xsl:variable>
		<!-- RegEx aktualisiert; hoffentlich geht das auf eXist...; 2017-08-07 DK -->
		<xsl:analyze-string select="normalize-space($pdline)" regex="(?:([\[\]A-Za-z ]+), )?([\[\]\w\sä\?,\.]+)">
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
								<xsl:value-of select="concat($numYear, '-', $month, '-00')"/>
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
	<xsl:template match="w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel']" />
	
	<!-- Grobgliederung; 2017-06-05 DK -->
	<xsl:template match="w:p[preceding-sibling::w:p[descendant::w:pStyle/@w:val='KSberschrift1']
		and not(descendant::w:pStyle/@w:val='KSberschrift1')]"/>
	<xsl:template match="w:p[descendant::w:pStyle[starts-with(@w:val, 'KSberschrift1')]]">
		<div>
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="contains(string-join(descendant::w:t, ''), 'Überlieferung')">history_of_the_work</xsl:when>
					<xsl:when test="contains(string-join(descendant::w:t, ''), 'Entstehung und Inhalt')">contents</xsl:when>
					<xsl:when test="contains(string-join(descendant::w:t, ''), 'Referenz')">reference</xsl:when>
					<xsl:when test="contains(string-join(descendant::w:t, ''), 'Inhaltliche Hinweise')">evidence</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:choose>
				<!-- Ü2 folgt, also Detailangaben -->
				<xsl:when test="following-sibling::w:p[descendant::w:pStyle[@w:val='KSberschrift2']]">
					<xsl:apply-templates select="following-sibling::w:p[descendant::w:pStyle[starts-with(@w:val, 'KSberschrift2')]]"
					mode="content2"/>
				</xsl:when>
				<!-- Hinter der 2. Ü1, also nur Text ausgeben -->
				<xsl:when test="count (//w:pStyle[@w:val='KSberschrift1']) &gt; 1
					and not(following::w:p[descendant::w:pStyle/@w:val='KSberschrift1'])">
					<xsl:apply-templates select="following-sibling::w:p" mode="content" />
				</xsl:when>
				<!-- In der 1. Ü1, aber keine Sigle, z.B. Brief ohne Original -->
				<xsl:when test="following::w:p[descendant::w:pStyle/@w:val='KSberschrift1'] and
					not(following-sibling::w:p[descendant::w:rStyle/@w:val='KSSigle'])">
					<xsl:call-template name="edlit" />
				</xsl:when>
				<!-- In der Referenz ohne weitere Ü1 - verschollene mit Angaben; 2017-08-08 DK -->
				<xsl:when test="contains(string-join(descendant::w:t, ''), 'Referenz') and
					not(following-sibling::w:p[descendant::w:pStyle/@w:val='KSberschrift1'])">
					<xsl:apply-templates select="following-sibling::w:p[not(starts-with(descendant::w:t[1], 'Lit')
						or starts-with(descendant::w:t[1], 'Edi'))]" mode="content" />
					<xsl:call-template name="edlit" />
				</xsl:when>
				<!-- anderer Text -->
				<xsl:otherwise>
					<xsl:apply-templates select="following-sibling::w:p intersect
						following-sibling::w:p[descendant::w:pStyle/@w:val='KSberschrift1']/preceding-sibling::w:p"
						mode="content"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- Untergliederung im 1. div; 2017-06-05 DK -->
	<xsl:template match="w:p[descendant::w:pStyle[starts-with(@w:val, 'KSberschrift2')]]" mode="content2">
		<xsl:if test="following-sibling::w:p[descendant::w:rStyle/@w:val='KSSigle']">
			<listBibl type="sigla">
				<xsl:choose>
					<xsl:when test="descendant::w:t[starts-with(., 'Frühdruck')]">
						<xsl:for-each select="following-sibling::w:p[descendant::w:rStyle/@w:val='KSSigle'
							and not(preceding-sibling::w:p[descendant::w:pStyle[starts-with(@w:val, 'KSberschrift2')]
								and descendant::w:t[starts-with(., 'Hand')]])]">
							<xsl:variable name="end"
								select="following-sibling::w:p[starts-with(string-join(descendant::w:t, ''), 'Bibliographische')][1]" />
							<xsl:variable name="struct" select="current() | 
								current()/following::w:p intersect $end/preceding::w:p | $end" />
							<xsl:variable name="idNo">
								<xsl:analyze-string select="string-join(w:r[descendant::w:rStyle/@w:val='KSSigle']//w:t, '')"
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
										<xsl:when test="$struct[3]//w:t[starts-with(normalize-space(), 'in')]">
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
											<item n="editionsvorlage">
												<xsl:variable name="ex">
													<xsl:apply-templates select="$struct[$pos]//w:t" />
												</xsl:variable>
												<xsl:choose>
													<xsl:when test="contains($ex, ',')">
														<label><xsl:value-of
															select="normalize-space(substring-before(substring-after($ex, ':'), ','))"/></label>
														<idno type="signatur"><xsl:value-of
															select="normalize-space(substring-after($ex, ','))"/></idno>
													</xsl:when>
													<xsl:otherwise>
														<idno type="signatur"><xsl:value-of
															select="normalize-space(substring-after($ex, ':'))"/></idno>
													</xsl:otherwise>
												</xsl:choose>
												<xsl:if test="$struct[$pos]/w:commentRangeEnd">
													<xsl:variable name="coID" select="$struct[$pos]/w:commentRangeEnd/@w:id"/>
													<ptr type="digitalisat">
														<xsl:attribute name="target">
															<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
														</xsl:attribute>
													</ptr>
												</xsl:if>
											</item>
											<xsl:variable name="weitere">
												<xsl:apply-templates select="$struct[$pos + 1]//w:t" mode="exemplar" />
											</xsl:variable>
											<xsl:for-each select="tokenize(substring-after($weitere, 'Exemplare: '), ';|–|—')">
												<item>
													<xsl:choose>
														<xsl:when test="contains(., ',')">
															<label><xsl:value-of select="normalize-space(substring-before(current(), ','))"/></label>
															<idno type="signatur"><xsl:choose>
																<xsl:when test="contains(current(), '→')">
																	<xsl:value-of select="normalize-space(substring-before(substring-after(current(), ','), '→'))"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="normalize-space(substring-after(current(), ','))"/>
																</xsl:otherwise>
															</xsl:choose></idno>
														</xsl:when>
														<xsl:otherwise>
															<idno type="signatur"><xsl:value-of select="normalize-space()"/></idno>
														</xsl:otherwise>
													</xsl:choose>
													<xsl:if test="contains(., '→')">
														<ptr type="digitalisat" target="{substring-after(., '→')}" />
													</xsl:if>
												</item>
											</xsl:for-each>
										</list>
									</note>
									<note type="references">
										<listBibl>
											<xsl:variable name="weitere">
												<xsl:apply-templates select="$struct[$pos + 2]//w:t" />
											</xsl:variable>
											<xsl:for-each select="tokenize(substring-after($weitere, ':'), '–|—')">
												<bibl>
													<!-- TODO ID aus bibliography übernehmen -->
													<xsl:value-of select="normalize-space(current())"/>
												</bibl>
											</xsl:for-each>
										</listBibl>
									</note>
								</xsl:if>
							</biblStruct>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="descendant::w:t[starts-with(., 'Handschrift')]">
						<msDesc>
							<xsl:if test="following-sibling::w:p[1]/w:r[descendant::w:rStyle/@w:val='KSSigle']">
								<xsl:attribute name="xml:id">
									<xsl:value-of select="substring-before(hab:rmSquare(following-sibling::w:p[1]/w:r[descendant::w:rStyle/@w:val='KSSigle']//w:t), ':')"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:apply-templates select="following-sibling::w:p[1]/w:r[not(descendant::w:rStyle/@w:val='KSSigle')]/w:t" />
						</msDesc>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="edlit" />
					</xsl:otherwise>
				</xsl:choose>
			</listBibl>
		</xsl:if>
		<xsl:if test="(following-sibling::w:p)[1][not(descendant::w:rStyle/@w:val='KSSigle')]">
			<!--<p>-->
				<xsl:apply-templates select="(following-sibling::w:p)[1]" mode="content"/>
			<!--</p>-->
		</xsl:if>
		<!-- auslagern für z.B. verschollene -->
		<!-- TODO !important! $struct erstellen mit allen Knoten und dann durchgehen,
			damit hier die Literatur auftaucht, aber bei beim ersten Eintrag nur die vom
			1. und nicht auch die von den folgenden Einträgen! -->
		<xsl:if test="not(following-sibling::w:p[descendant::w:pStyle[contains(@w:val, 'KSberschrift2')]])
			and (starts-with(string-join((following-sibling::w:p)[1]//w:t, ''),  'Edi')
			or starts-with(string-join((following-sibling::w:p)[1]//w:t, ''),  'Litera'))">
			<xsl:call-template name="edlit" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="edlit">
		<xsl:if test="following-sibling::w:p[starts-with(string-join(descendant::w:t, ''), 'Edi')]">
			<listBibl type="editions">
				<xsl:variable name="text"
					select="following-sibling::w:p[starts-with(string-join(descendant::w:t, ''), 'Edi')]"/>
				<xsl:apply-templates select="$text/w:r[descendant::w:rStyle and
					descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
					and preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
					or descendant::w:rStyle[@w:val='Kommentarzeichen']
					or descendant::w:commentReference)]]" mode="bibl"/>
			</listBibl>
		</xsl:if>
		<xsl:if test="following-sibling::w:p[starts-with(string-join(descendant::w:t, ''), 'Literatur:')]">
			<listBibl type="literatur">
				<xsl:variable name="text"
					select="following-sibling::w:p[starts-with(string-join(descendant::w:t, ''), 'Literatur:')]"/>
				<xsl:apply-templates select="$text/w:r[descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
					and preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe'])]]" 
				mode="bibl" />
			</listBibl>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="imprint">
		<xsl:param name="context" />
		<xsl:variable name="imprintText">
			<xsl:apply-templates select="$context//w:t" mode="imprintContent" />
		</xsl:variable>
		<xsl:analyze-string select="$imprintText"
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
				<extent><xsl:apply-templates select="$context/following-sibling::w:p[1]//w:t"/></extent>
				<xsl:if test="regex-group(4)">
					<biblScope><xsl:value-of select="normalize-space(regex-group(4))" /></biblScope>
				</xsl:if>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="w:p" mode="content2" />
	<xsl:template match="w:p" mode="content">
		<!-- Endnoten berücksichtigen; 2017-08-08 DK -->
		<p><xsl:apply-templates select="descendant::w:t | descendant::w:endnoteReference" /></p>
	</xsl:template>
	
	<xsl:template match="w:t[preceding-sibling::w:rPr/w:vertAlign/@w:val='superscript']">
		<hi rend="super"><xsl:value-of select="."/></hi>
	</xsl:template>
	
	<!-- neu 2017-06-11 DK -->
	<xsl:template match="w:t" mode="exemplar">
		<xsl:apply-templates />
		<xsl:apply-templates select="parent::w:r/following-sibling::*[1][self::w:commentRangeEnd]" mode="exemplar"/>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:variable name="text">
			<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
		</xsl:variable>
		<xsl:if test="starts-with($text, 'http')">
			<ptr type="digitalisat" target="{$text}" />
		</xsl:if>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd" mode="exemplar">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:text>→</xsl:text>
		<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
	</xsl:template>
	
	<xsl:template match="w:r" mode="bibl">
		<xsl:variable name="me" select="generate-id()" />
		<xsl:variable name="next" select="generate-id((following::w:r[descendant::w:rStyle and
			descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
			and preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
			or descendant::w:rStyle[@w:val='Kommentarzeichen']
			or descendant::w:commentReference)]])[1])" />
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
				<!--<note>-->
					<xsl:apply-templates select="following-sibling::w:r[descendant::w:rStyle[@w:val='KSAnmerkunginberlieferung'] and
						following::w:r[generate-id() = $next]]//w:t" />
				<!--</note>-->
			</xsl:if>
			<!-- FN berücksichtigen; 2017-08-07 DK -->
			<xsl:choose>
				<xsl:when test="$next">
					<xsl:apply-templates select="following-sibling::w:r[w:endnoteReference
						and preceding-sibling::w:r[generate-id() = $me] and following-sibling::w:r[generate-id() = $next]]/w:endnoteReference"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="following-sibling::w:r[w:endnoteReference]/w:endnoteReference" />
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
	<xsl:template match="w:endnote//w:r">
		<xsl:apply-templates select="w:t" />
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
</xsl:stylesheet>
