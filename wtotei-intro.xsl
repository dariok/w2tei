<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:hab="http://diglib.hab.de"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="2.0">
	<!-- neu für Projekt Rist, 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	<!-- übernommen für Karlstadt Einleitungen; 2017-05-03 DK -->
	
	<xsl:output indent="yes"/>
	
	<!-- die überwiegend genutzte Schriftgröße für Normaltext ermitteln; 2017-05-03 DK -->
	<xsl:variable name="mainsize">
		<xsl:variable name ="t">
			<xsl:for-each-group select="//w:rPr/w:sz" group-by="@w:val">
				<xsl:sort select="count(current-group())" order="descending"/>
				<s>
					<xsl:value-of select="current-group()[1]/@w:val"/>
				</s>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:value-of select="$t/*[1]"/>
	</xsl:variable>
	<xsl:variable name="nr">
		<xsl:variable name="t" select="string-join((//w:p)[1]//w:t, ' ')"/>
		<xsl:value-of select="hab:rmSquare(substring-after($t, 'Nr. '))" />
	</xsl:variable>
	<xsl:variable name="ee">
		<xsl:variable name="t" select="string-join((//w:p)[1]//w:t, ' ')"/>
		<xsl:variable name="nr" select="substring-before(substring-after($t, 'EE '), ' ')" />
		<xsl:choose>
			<xsl:when test="$nr castable as xs:integer">
				<xsl:value-of select="format-number(number($nr), '000')" />
			</xsl:when>
			<xsl:when test="string-length($nr) &lt; 4">
				<xsl:value-of select="concat('0', $nr)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$nr" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<TEI xmlns="http://www.tei-c.org/ns/1.0" n="{$nr}">
			<xsl:attribute name="xml:id" select="concat('edoc_ed000240_', $ee, '_introduction')" />
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title><xsl:apply-templates select="//w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel'][2]//w:t" mode="mTitle" />
							<xsl:apply-templates select="//w:p[w:pPr/w:pStyle/@w:val='KSEE-Titel'][3]"
								mode="date"/></title>
						<xsl:apply-templates select="(//w:p[starts-with(normalize-space(), 'Bearbeitet')])[1]"
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
	<xsl:template match="w:p[starts-with(normalize-space(), 'Bearbeitet')]" mode="head">
		<xsl:variable name="aut" select="substring-after(normalize-space(), 'Bearbeitet von ')"/>
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
			<xsl:apply-templates select="w:r/w:t" mode="pdContent" />
		</xsl:variable>
		<xsl:analyze-string select="normalize-space($pdline)" regex="(.*), (\[?\d+, .*)">
			<xsl:matching-substring>
				<placeName><xsl:if test="starts-with(regex-group(1), '[')">
					<xsl:attribute name="cert">unknown</xsl:attribute>
				</xsl:if>
				<xsl:analyze-string select="regex-group(1)"
					regex="\[?(\w+)\]?">
					<xsl:matching-substring>
						<xsl:value-of select="regex-group(1)"/>
					</xsl:matching-substring>
				</xsl:analyze-string></placeName>
				<xsl:text>, </xsl:text>
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
					<xsl:attribute name="when">
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
					<xsl:when test="descendant::w:t='Überlieferung'">history_of_the_work</xsl:when>
					<xsl:when test="descendant::w:t='Entstehung und Inhalt'">contents</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="following-sibling::w:p[descendant::w:pStyle[starts-with(@w:val, 'KSberschrift2')]]">
					<xsl:apply-templates select="following-sibling::w:p[descendant::w:pStyle[starts-with(@w:val, 'KSberschrift2')]]"
					mode="content2"/>
				</xsl:when>
				<xsl:when test="not(following::w:p[descendant::w:pStyle/@w:val='KSberschrift1'])">
					<xsl:apply-templates select="following-sibling::w:p" mode="content" />
				</xsl:when>
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
		<xsl:choose>
			<xsl:when test="descendant::w:t = 'Frühdrucke'">
				<listBibl type="sigla">
					<xsl:for-each select="following-sibling::w:p[descendant::w:rStyle/@w:val='KSSigle']">
						<xsl:variable name="idNo">
							<xsl:analyze-string select="w:r[descendant::w:rStyle/@w:val='KSSigle']/w:t"
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
									<xsl:when test="following::w:p[2]//w:t[normalize-space() = 'in:']">
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
								<xsl:if test="not(following::w:p[2]//w:t[normalize-space() = 'in:'])">
									<xsl:call-template name="imprint">
										<xsl:with-param name="context" select="." />
									</xsl:call-template>
								</xsl:if>
							</xsl:element>
							<xsl:if test="following::w:p[2]//w:t[normalize-space() = 'in:']">
								<monogr>
									<title><xsl:apply-templates select="following::w:p[3]//w:t" /></title>
									<xsl:call-template name="imprint">
										<xsl:with-param name="context" select="following-sibling::w:p[2]" />
									</xsl:call-template>
								</monogr>
							</xsl:if>
							<idno type="siglum"><xsl:value-of select="$idNo" /></idno>
							<xsl:variable name="start" as="xs:integer">
								<xsl:choose>
									<xsl:when test="following::w:p[2]//w:t[normalize-space() = 'in:']">6</xsl:when>
									<xsl:otherwise>4</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<note type="copies">
								<list>
									<item n="editionsvorlage">
										<xsl:variable name="ex">
											<xsl:apply-templates select="following-sibling::w:p[$start]//w:t" />
										</xsl:variable>
										<label><xsl:value-of
											select="normalize-space(substring-before(substring-after($ex, ':'), ','))"/></label>
										<idno type="signatur"><xsl:value-of
											select="normalize-space(substring-after($ex, ','))"/></idno>
										<xsl:if test="following-sibling::w:p[$start]/w:commentRangeEnd">
											<xsl:variable name="coID" select="following-sibling::w:p[$start]/w:commentRangeEnd/@w:id"/>
											<ptr type="digitalisat">
												<xsl:attribute name="target">
													<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
												</xsl:attribute>
											</ptr>
										</xsl:if>
									</item>
									<xsl:variable name="weitere">
										<xsl:apply-templates select="following-sibling::w:p[$start+1]//w:t" mode="exemplar" />
									</xsl:variable>
									<xsl:for-each select="tokenize(substring-after($weitere, 'Exemplare: '), ';')">
										<item>
											<label><xsl:value-of select="normalize-space(substring-before(current(), ','))"/></label>
											<idno type="signatur"><xsl:choose>
												<xsl:when test="contains(current(), '→')">
													<xsl:value-of select="normalize-space(substring-before(substring-after(current(), ','), '→'))"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="normalize-space(substring-after(current(), ','))"/>
												</xsl:otherwise>
											</xsl:choose></idno>
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
										<xsl:apply-templates select="following-sibling::w:p[$start+2]//w:t" />
									</xsl:variable>
									<xsl:for-each select="tokenize(substring-after($weitere, ':'), '–|—')">
										<bibl>
											<!-- TODO ID aus bibliography übernehmen -->
											<xsl:value-of select="normalize-space(current())"/>
										</bibl>
									</xsl:for-each>
								</listBibl>
							</note>
						</biblStruct>
					</xsl:for-each>
				</listBibl>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="imprint">
		<xsl:param name="context" />
		<xsl:variable name="imprintText">
			<xsl:apply-templates select="$context/following-sibling::w:p[2]//w:t" mode="imprintContent" />
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
				<extent><xsl:apply-templates select="$context/following-sibling::w:p[3]//w:t"/></extent>
				<xsl:if test="regex-group(4)">
					<biblScope><xsl:value-of select="regex-group(4)" /></biblScope>
				</xsl:if>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="w:p" mode="content2" />
	<xsl:template match="w:p" mode="content">
		<p><xsl:apply-templates select="descendant::w:t" /></p>
	</xsl:template>
	
	<xsl:template match="w:t[preceding-sibling::w:rPr/w:vertAlign/@w:val='superscript']">
		<hi rend="super"><xsl:value-of select="."/></hi>
	</xsl:template>
	
	<!-- neu 2017-06-11 DK -->
	<xsl:template match="w:t" mode="exemplar">
		<xsl:apply-templates />
		<xsl:apply-templates select="parent::w:r/following-sibling::*[1][self::w:commentRangeEnd]"/>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:text>→</xsl:text>
		<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
	</xsl:template>
	
	<xsl:function name="hab:rmSquare" as="xs:string">
		<xsl:param name="input" />
		<xsl:analyze-string select="normalize-space($input)" regex="\[?([^\]]+)\]?">
			<xsl:matching-substring>
				<xsl:value-of select="normalize-space(regex-group(1))"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
</xsl:stylesheet>
