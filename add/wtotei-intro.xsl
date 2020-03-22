<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
	xmlns:hab="http://diglib.hab.de"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns:xstring="https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	<!-- neu für Projekt Rist, 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	<!-- übernommen für Karlstadt Einleitungen; 2017-05-03 DK -->
	<!-- Bearbeiter ab 2018-08-01: DK kampkaspar@baukast.digital -->
	<!-- Erägnzung: Ref und Querverweise – 2020-03-04 -->
	
	<xsl:include href="ks-common.xsl#1" />
	<xsl:include href="ref-qv.xsl" />
	
<!--	<xsl:output indent="yes"/>-->
	
	<xsl:template match="pkg:part[contains(@pkg:name, 'word/document.xml')]">
		<xsl:apply-templates select="w:p[hab:isHead(., 1)]"/>
	</xsl:template>
	
	<!-- Titel mit Untertitel; 2017-10-26 DK -->
	<xsl:template match="w:t" mode="mTitle">
		<xsl:analyze-string select="." regex="\. ">
			<xsl:matching-substring>
				<lb/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- Grobgliederung; 2017-06-05 DK -->
	<xsl:template match="w:p[hab:isHead(., 1)]">
		<xsl:text>
			</xsl:text>
		<div>
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="wt:starts(., 'Überlieferung')">history_of_the_work</xsl:when>
					<xsl:when test="wt:contains(., 'Entstehung')">contents</xsl:when>
					<xsl:when test="wt:starts(., 'Referenz')">reference</xsl:when>
					<xsl:when test="wt:starts(., 'Inhaltliche Hinweise')">evidence</xsl:when>
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
						and (wt:starts(., 'Edition') or wt:starts(., 'Literatur')) and not(wt:starts(., 'Editionsvorlage'))]"/>
					<xsl:apply-templates select="following-sibling::w:p[wt:is(., 'KSText', 'p') and
						following-sibling::w:p[hab:isHead(., 1)] and preceding-sibling::w:p[wt:starts(., 'Literatur')]]"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- Untergliederung im 1. div; 2017-06-05 DK -->
	<xsl:template match="w:p[hab:isHead(., 2) and descendant::w:t]">
		<xsl:variable name="myId" select="generate-id()" />
		<xsl:text>
				</xsl:text>
		<listBibl type="sigla">
			<xsl:apply-templates select="following-sibling::w:p[hab:isSigle(.)
				and generate-id(preceding-sibling::w:p[hab:isHead(., 2)][1]) = $myId]"/>
		</listBibl>
	</xsl:template>
	
	<xsl:template match="w:p[hab:isSigle(.) and wt:starts(preceding-sibling::w:p[hab:isHead(., 2)][1], 'Früh')]">
		<xsl:variable name="myId" select="generate-id()"/>
		<xsl:variable name="end"
			select="following-sibling::w:p[wt:starts(., 'Bibliographische')][1]" />
		<xsl:variable name="struct" select="current() | 
			current()/following::w:p intersect $end/preceding::w:p | $end" />
		<xsl:variable name="idNo">
			<!-- vorher vmtl. um zu lange Markierungen abzufangen -->
			<!--<xsl:analyze-string select="wt:string(w:r[hab:isSigle(.)])"
				regex="\[(\w+).?\]">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)"/>
				</xsl:matching-substring>
			</xsl:analyze-string>-->
			<!-- neu 2018-08-04 DK -->
			<xsl:variable name="idTemp">
				<xsl:apply-templates select="w:r[hab:isSigle(.)]" />
			</xsl:variable>
			<xsl:for-each select="$idTemp/node()">
				<xsl:choose>
					<xsl:when test=". instance of text() and position() = 1 and ends-with(normalize-space(), ':]')">
						<xsl:value-of select="substring-before(substring-after(., '['), ':]')"/>
					</xsl:when>
					<xsl:when test=". instance of text() and position() = 1">
						<xsl:value-of select="substring-after(., '[')"/>
					</xsl:when>
					<xsl:when test=". instance of text() and position() = last()">
						<xsl:value-of select="substring-before(., ':')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="."></xsl:sequence>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:text>
					</xsl:text>
		<biblStruct type="imprint">
			<xsl:attribute name="xml:id" select="normalize-space($idNo)" />
			<xsl:variable name="elem">
				<xsl:choose>
					<xsl:when test="following-sibling::w:p[2][wt:starts(., 'in')]">
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
				<idno type="siglum"><xsl:sequence select="$idNo" /></idno>
				<note type="copies">
					<list>
						<xsl:apply-templates select="$struct[wt:starts(., 'Editionsv')
							or wt:starts(., 'Weitere')]" mode="item" />
					</list>
				</note>
				<note type="references">
					<listBibl>
						<!--<xsl:variable name="weitere">
							<xsl:apply-templates select="$struct[wt:starts(., 'Bibliographische')]//w:r" />
						</xsl:variable>-->
						<!--<xsl:for-each select="tokenize(substring-after($weitere, ':'), '–|—')">
							<bibl>
								<!-\- TODO ID aus bibliography übernehmen -\->
								<xsl:value-of select="normalize-space(current())"/>
							</bibl>
						</xsl:for-each>-->
						<xsl:apply-templates select="$struct[wt:starts(., 'Bibliographische')]//w:r[wt:is(., 'KSbibliographischeAngabe', 'r')
							and not(preceding-sibling::w:r[1][wt:is(., 'KSbibliographischeAngabe', 'r')])]" 
							mode="bibl"/>
					</listBibl>
					<xsl:apply-templates select="($struct[last()]/following-sibling::w:p intersect 
						$struct[last()]/following-sibling::w:p[hab:isHead(., '1')]/preceding-sibling::w:p)
						[not(wt:starts(., 'Edition') or wt:starts(., 'Literatur') or wt:starts(., 'Handschriften') or hab:isHead(., '1')
						or hab:isSigle(.))
						and generate-id(preceding-sibling::w:p[hab:isSigle(.)][1]) = $myId]"/>
					
					<!-- auch dann ausgeben, wenn die Anmerkung hinter dem letzten Exemplar steht -->
					<!--<xsl:choose>
						<xsl:when test="$struct[last()]/following-sibling::w:p[hab:isSigle(.)]">
							<xsl:apply-templates select="$struct[last()]/following-sibling::w:p
								intersect $struct[last()]/following-sibling::w:p[hab:isSigle(.)][1]/preceding-sibling::w:p"/>
						</xsl:when>
						<xsl:when test="$struct[last()]/following-sibling::w:p[not(hab:isHead(., '1'))
							and count(preceding-sibling::w:p[hab:isHead(., '1')]) = 1]">
							<xsl:apply-templates select="$struct[last()]/following-sibling::w:p[not(hab:isHead(., '1'))
								and count(preceding-sibling::w:p[hab:isHead(., '1')]) = 1]" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="($struct[last()]/following-sibling::w:p intersect 
								$struct[last()]/following-sibling::w:p[hab:isHead(., '1')]/preceding-sibling::w:p)[not(
								wt:starts(., 'Edition') or wt:starts(., 'Literatur')
								or wt:is(., 'KSText', 'p'))]"/>
						</xsl:otherwise>
					</xsl:choose>-->
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
								<xsl:apply-templates select="w:r[wt:contains(preceding-sibling::w:r, 'vorlage')]
									| w:commentRangeEnd" mode="item"/>
							</hab:t>
						</xsl:variable>
						<xsl:apply-templates select="$temp" mode="ex" />
					</item>
				</xsl:when>
				<xsl:otherwise>
					<!-- leere Exemplarangaben abfangen; 2017-10-24 DK -->
					<xsl:if test="w:r[wt:contains(., 'plare')] and string-length(wt:string(.)) &gt; 20">
						<xsl:variable name="t1">
							<hab:t>
								<xsl:apply-templates select="w:r[wt:contains(preceding-sibling::w:r, 'plare')]
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
			<xsl:when test="wt:is(., 'KSAnmerkunginberlieferung', 'r')
				and not(wt:isFirst(., 'KSAnmerkunginberlieferung', 'r'))"/>
			<xsl:when test="wt:is(., 'KSAnmerkunginberlieferung', 'r')
				and wt:isFirst(., 'KSAnmerkunginberlieferung', 'r')">
				<note>
					<xsl:variable name="myId" select="generate-id()" />
					<xsl:variable name="anmerkung">
						<xsl:variable name="me" select="." />
						<xsl:apply-templates select=". |
							following-sibling::w:r[wt:followMe(., $me, 'KSAnmerkunginberlieferung', 'r')]" />
					</xsl:variable>
					<xsl:for-each select="$anmerkung/node()">
						<xsl:choose>
							<xsl:when test="self::text()">
								<xsl:value-of select="xstring:substring-before-if-ends(xstring:substring-after-if-starts(current(), '('), ')')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</note>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eval" />
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
		
		<!-- falls keine Exemplardaten vorhanden sind, Text direkt ausgeben; 2017-11-06 DK -->
		<xsl:choose>
			<xsl:when test="string-length($temp/*:idno) &gt; 0">
				<label>
					<xsl:for-each select="$temp/node()[following-sibling::*:idno]">
						<xsl:choose>
							<xsl:when test="self::text()">
								<xsl:value-of select="normalize-space(xstring:substring-after(current(), ':'))"/>
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
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*:note" />
			</xsl:otherwise>
		</xsl:choose>
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
		and wt:starts(preceding-sibling::w:p[hab:isHead(., 2)][1], 'Hand')]">
		<xsl:variable name="myId" select="generate-id()"/>
		<xsl:text>
				</xsl:text>
		<msDesc>
			<xsl:variable name="desc">
				<xsl:apply-templates select="w:r[not(hab:isSigle(.))]" mode="eval" />
			</xsl:variable>
			<xsl:variable name="md">
				<xsl:for-each select="$desc/node()">
					<xsl:choose>
						<xsl:when test="self::text()">
							<xsl:analyze-string select="." regex="( , )">
								<xsl:matching-substring>
									<hab:b/>
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
			<xsl:variable name="md3">
				<xsl:choose>
					<xsl:when test="$md/hab:b[2]">
						<xsl:for-each select="$md/hab:b[2]/following-sibling::node()">
							<xsl:choose>
								<xsl:when test="self::text()">
									<xsl:analyze-string select="." regex="\(|\)">
										<xsl:matching-substring>
											<hab:c/>
										</xsl:matching-substring>
										<xsl:non-matching-substring>
											<xsl:value-of select="."/>
										</xsl:non-matching-substring>
									</xsl:analyze-string>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="val">
							<xsl:for-each select="$md/hab:b/following-sibling::node()">
								<xsl:choose>
									<xsl:when test="self::text()">
										<xsl:analyze-string select="." regex="\(|\)">
											<xsl:matching-substring>
												<hab:c/>
											</xsl:matching-substring>
											<xsl:non-matching-substring>
												<xsl:value-of select="."/>
											</xsl:non-matching-substring>
										</xsl:analyze-string>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:variable>
						<xsl:sequence select="$val/hab:c | $val/hab:c/following-sibling::node()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="si"
				select="wt:string(w:r[hab:isSigle(.)])" />
			<xsl:variable name="sigle">
				<xsl:value-of select="xstring:substring-before(hab:rmSquare($si), ':')"/>
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
				<repository><xsl:apply-templates select="$md/hab:b[1]/preceding::node()" mode="normalize" /></repository>
				<idno type="signatur">
					<xsl:variable name="te">
						<xsl:choose>
							<xsl:when test="$md/hab:b[2]">
								<xsl:apply-templates select="$md/hab:b[2]/preceding-sibling::node() intersect $md/hab:b[1]/following-sibling::node()" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="$md/hab:b[1]/following-sibling::node()" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($te, '(') and contains($te, ')')">
							<!-- ggf. Punkt entfernen -->
							<xsl:variable name="str" select="normalize-space(substring-before($te, '('))"/>
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
							<xsl:value-of select="$te"/>
						</xsl:otherwise>
					</xsl:choose>
				</idno>
			</msIdentifier>
			<xsl:if test="not($md3/hab:c) or $md3/hab:c[1]/preceding-sibling::node()">
				<msContents>
					<msItem>
						<locus>
							<xsl:choose>
								<xsl:when test="$md3/hab:c">
									<xsl:apply-templates select="$md3/hab:c[1]/preceding-sibling::node()" mode="normalize" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="$md3" mode="normalize" />
								</xsl:otherwise>
							</xsl:choose>
						</locus>
						<xsl:apply-templates select="descendant::w:endnoteReference" />
					</msItem>
				</msContents>
			</xsl:if>
			<physDesc>
				<xsl:if test="w:commentRangeEnd">
					<p><xsl:apply-templates select="w:commentRangeEnd"/></p>
				</xsl:if>
				<xsl:if test="$md3/hab:c">
					<handDesc>
						<handNote>
							<xsl:apply-templates select="$md3/hab:c[1]/following-sibling::node()[not(self::hab:c)]" mode="normalize" />
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
				<xsl:apply-templates select="following-sibling::w:p[not(wt:starts(., 'Edition') or wt:starts(., 'Literatur'))
					and following-sibling::w:p[hab:isHead(., 1)] and not(preceding-sibling::w:p[wt:starts(., 'Literatur')])
					and generate-id(preceding-sibling::w:p[hab:isSigle(.)][1]) = $myId]"/>
			</physDesc>
		</msDesc>
	</xsl:template>
	
	<xsl:template match="w:p[wt:starts(., 'Edition') or wt:starts(., 'Literatur')]">
		<listBibl>
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="wt:starts(., 'Edi')">editions</xsl:when>
					<xsl:otherwise>literatur</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="preceding-sibling::w:p[1][wt:starts(., 'Beilage')]">
				<head><xsl:apply-templates select="preceding-sibling::w:p[1]/w:r"/></head>
			</xsl:if>
			<xsl:apply-templates select="w:r[wt:is(., 'KSbibliographischeAngabe', 'r')
				and not(preceding-sibling::w:r[1][wt:is(., 'KSbibliographischeAngabe', 'r')])]" mode="bibl" />
				<!--and preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe']
				or descendant::w:rStyle[@w:val='Kommentarzeichen']
				or descendant::w:commentReference)]]" mode="bibl"/>-->
		</listBibl>
	</xsl:template>
	
	<xsl:template name="imprint">
		<xsl:param name="context" />
		<xsl:variable name="imprintText">
			<xsl:apply-templates select="$context/w:r" mode="eval"/>
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
				<extent><xsl:apply-templates select="$context/following-sibling::w:p[1]/w:r" mode="eval"/></extent>
			</xsl:matching-substring>
		</xsl:analyze-string>
		
		<xsl:if test="$imp/node()[preceding-sibling::hab:odj]">
			<biblScope>
				<xsl:for-each select="$imp/node()[preceding-sibling::hab:odj]">
					<xsl:choose>
						<xsl:when test="position() = 1 and self::text()">
							<xsl:value-of select="xstring:substring-after(., ', ')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</biblScope>
		</xsl:if>
	</xsl:template>
	
	<!-- leere p abfangen; 2017-10-24 DK -->
	<xsl:template match="w:p[not(descendant::w:t) or string-length(wt:string(.)) &lt; 5]" />
	<xsl:template match="w:p[(not(descendant::w:pStyle or ancestor-or-self::w:endnote)
		or wt:is(., 'KSText') ) and not(hab:isSigle(.) or wt:starts(., 'Edition') or
		wt:starts(., 'Literatur')) and descendant::w:t and string-length(wt:string(.)) &gt; 5]">
		<!-- Endnoten berücksichtigen; 2017-08-08 DK -->
		<xsl:text>
				</xsl:text>
		<p><xsl:apply-templates select="w:r | w:bookmarkStart | w:bookmarkEnd | w:hyperlink" /></p>
	</xsl:template>
	
	<!-- neu 2017-06-11 DK -->
	<xsl:template match="w:t" mode="exemplar">
		<xsl:apply-templates />
		<xsl:apply-templates select="parent::w:r/following-sibling::*[1][self::w:commentRangeEnd]" mode="exemplar"/>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:variable name="text">
			<xsl:apply-templates select="wt:string(//w:comment[@w:id=$coID])"/>
		</xsl:variable>
		<xsl:if test="contains($text, 'http')">
			<ptr type="digitalisat" target="{'http'||xstring:substring-after($text, 'http')}" />
		</xsl:if>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd" mode="exemplar">
		<xsl:variable name="coID" select="@w:id" />
		<xsl:text>→</xsl:text>
		<xsl:apply-templates select="//w:comment[@w:id=$coID]//w:t"/>
	</xsl:template>
	<xsl:template match="w:commentRangeEnd" mode="eval">
		<xsl:apply-templates select="." />
	</xsl:template>
	
	<!-- (auch) für Verabreitung im XSPEC -->
	<xsl:template match="w:comments" mode="item" />
	<xsl:template match="w:comments" />
	
	<xsl:template match="w:r" mode="bibl">
		<xsl:variable name="me" select="generate-id()" />
		<xsl:variable name="next" select="following-sibling::w:r[wt:is(., 'KSbibliographischeAngabe', 'r')
			and not(preceding-sibling::w:r[1][wt:is(., 'KSbibliographischeAngabe', 'r')])][1]" />
		<bibl>
			<xsl:choose>
				<xsl:when test="$next">
					<xsl:apply-templates select=". |
						following-sibling::w:r[wt:is(., 'KSbibliographischeAngabe', 'r')]
							intersect $next/preceding-sibling::w:r" mode="eval" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select=". |
						following-sibling::w:r[wt:is(., 'KSbibliographischeAngabe', 'r')]" mode="eval" />
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:apply-templates select="following-sibling::w:commentRangeEnd[generate-id(preceding-sibling::w:r[
				preceding-sibling::w:r[1][not(descendant::w:rStyle[@w:val='KSbibliographischeAngabe'])]][1])
				= $me]" />
			<xsl:apply-templates select="following-sibling::w:r[descendant::w:rStyle[@w:val='KSAnmerkunginberlieferung'] and
				following::w:r[generate-id() = generate-id($next)]]" />
			
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
	
	<!-- Verweise -->
	<!--<xsl:template match="w:bookmarkStart">
		<xsl:if test="not(@name = '_GoBack')">
			<hab:bm name="{@w:name}"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="w:r[w:fldChar]">
		<xsl:if test="not(w:fldChar/@w:fldCharType='separate')">
			<hab:mark>
				<xsl:if test="w:fldChar/@w:fldCharType='begin'">
					<xsl:attribute name="ref" select="normalize-space(following-sibling::w:r[1]/w:instrText)"/>
				</xsl:if>
			</hab:mark>
		</xsl:if>
	</xsl:template>-->
	
	<xsl:template match="w:endnotes" />
	
	<xsl:function name="hab:isSigle" as="xs:boolean">
		<xsl:param name="context" as="node()" />
		<xsl:sequence select="wt:is($context/descendant-or-self::w:r, 'KSSigle', 'r')"/>
	</xsl:function>
</xsl:stylesheet>