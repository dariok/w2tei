<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:hab="http://diglib.hab.de"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	<!-- neu 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	
	<xsl:include href="ks-common.xsl"/>
	
<!--	<xsl:output indent="yes"/>-->
	
	<xsl:template match="w:body">
		<xsl:apply-templates
		  select="w:p[wdb:is(., 'berschrift1')]/following-sibling::w:p[hab:isDiv(.)]"/>
	</xsl:template>
	
	<!-- Paragraphen -->
	<xsl:template match="w:p[hab:isDiv(.)]">
		<xsl:variable name="myId" select="generate-id()"/>
		<div>
			<xsl:apply-templates select="following-sibling::w:p[(hab:isP(.) or wdb:is(., 'KSZwischenberschrift', 'p'))
				and generate-id(preceding-sibling::w:p[hab:isDiv(.)][1]) = $myId]" />
		</div>
	</xsl:template>
	
	<xsl:template match="w:p[wdb:is(., 'berschrift1')]" />
	
	<xsl:template match="w:p[hab:isP(.)]">
		<xsl:variable name="myId" select="generate-id()"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="wdb:is(., 'KSWidmung') or wdb:is(., 'KSAnrede')">salute</xsl:when>
				<xsl:when test="wdb:is(., 'KSAdresse')">opener</xsl:when>
				<xsl:when test="wdb:is(., 'KSSchluformeln')">closer</xsl:when>
				<xsl:otherwise>p</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$name}">
			<!-- TODO später auch für Anreden und ggf. Buchtitle -->
			<xsl:if test="wdb:is(., 'KSSchluformeln')">
				<xsl:attribute name="rendition">
					<xsl:choose>
						<xsl:when test="descendant::w:ind/@w:left &lt; 2000">
							<xsl:text>#l</xsl:text>
						</xsl:when>
						<xsl:when test="descendant::w:ind/@w:left &lt; 4900">
							<xsl:text>#c</xsl:text>
						</xsl:when>
						<xsl:when test="descendant::w:ind/@w:left &lt; 6400">
							<xsl:text>#r</xsl:text>
						</xsl:when>
						<xsl:otherwise>#rc</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="preceding-sibling::w:p[descendant::w:t and not(hab:isP(.)
				or hab:isStruct(.))
				and generate-id(following-sibling::w:p[hab:isP(.)][1]) = $myId]" />
			<xsl:text>
               </xsl:text>
			<lb/>
			<xsl:apply-templates select="." mode="pb"/>
		</xsl:element>
	</xsl:template>
	
	<!-- Marginalie -->
	<xsl:template match="w:p[wdb:is(., 'KSMarginalie', 'p')]">
		<note place="margin"><xsl:apply-templates select="w:r" /></note>
	</xsl:template>
	
	<!-- Zwischenüberschriften -->
	<xsl:template match="w:p[wdb:is(., 'KSZwischenberschrift', 'p')]">
		<head>
			<xsl:if test="wdb:is(., 'KSZwischenberschrift2', 'p')">
				<xsl:attribute name="type">subheading</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="w:r"/>
		</head>
	</xsl:template>
	
	<!-- normaler Absatz -->
	<xsl:template match="w:p[descendant::w:t and not(hab:isStruct(.)) and not(descendant::w:numPr)
		and not(hab:isP(.) or hab:isDiv(.) or wdb:is(., 'KSMarginalie', 'p'))]">
		<xsl:if test="not(matches(wdb:string(.), '^\[.+?\]$'))">
			<xsl:text>
               </xsl:text>
			<lb/>
		</xsl:if>
		<xsl:apply-templates select="." mode="pb"/>
	</xsl:template>
	
	<xsl:template match="w:p[descendant::w:numPr][position() &gt; 1]"/>
	<xsl:template match="w:p[descendant::w:numPr][1]">
		<list>
			<xsl:apply-templates select=". | following-sibling::w:p[descendant::w:numPr]" mode="item" />
		</list>
	</xsl:template>
	<xsl:template match="w:p[descendant::w:numPr]" mode="item">
		<xsl:variable name="numId" select="descendant::w:numPr/w:numId/@w:val"/>
		<xsl:variable name="ilvl" select="descendant::w:numPr/w:ilvl/@w:val"/>
		<xsl:variable name="num" select="//w:numbering/w:num[@w:numId = $numId]/w:abstractNumId/@w:val"/>
		<xsl:variable name="style" select="//w:numbering/w:abstractNum[@w:abstractNumId = $num]/w:lvl[@w:ilvl = $ilvl]/w:numFmt/@w:val" />
		
		<label>
			<xsl:choose>
				<xsl:when test="wdb:is(w:r[1], 'KSkorrigierteThesennummer', 'r')">
					<app>
						<lem>
							<xsl:choose>
								<xsl:when test="$style = 'upperRoman'">
									<xsl:number count="w:p[descendant::w:numPr]" format="I" />
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
						<xsl:otherwise>
							<xsl:number count="w:p[descendant::w:numPr]" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>.</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</label>
		<item>
			<xsl:apply-templates select="." mode="pb" />
		</item>
	</xsl:template>
	<xsl:template match="w:r[wdb:is(., 'KSkorrigierteThesennummer', 'r')]" />
	
	<xsl:template match="w:p" mode="pb">
		<xsl:variable name="temp">
			<xsl:apply-templates select="w:r | w:bookmarkStart"/>
		</xsl:variable>
		<xsl:for-each select="$temp/node()">
			<xsl:choose>
				<xsl:when test="self::text()">
					<xsl:analyze-string select="." regex="(\[.+?\])">
						<xsl:matching-substring>
							<xsl:text>
               </xsl:text>
							<pb n="{regex-group(1)}" />
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="wdb:substring-before-if-ends(., '')"/>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- Ende Paragraphen -->
	
	<!-- Vertweise -->
	<xsl:template match="w:bookmarkStart">
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
	</xsl:template>
	
	<!-- kritische Anmerkungen -->
	<xsl:template match="w:r[descendant::w:footnoteReference]">
		<note type="crit_app">
			<xsl:variable name="wid" select="w:footnoteReference/@w:id"/>
			<xsl:variable name="temp">
				<xsl:apply-templates select="//w:footnote[@w:id = $wid]/w:p/w:r" />
			</xsl:variable>
			<xsl:for-each select="$temp/node()">
				<xsl:choose>
					<xsl:when test="position() = 1 and self::text() and normalize-space() = ''" />
					<xsl:when test="position() = 1 and self::text() and starts-with(., ' ')">
						<xsl:value-of select="substring(., 2)" />
					</xsl:when>
					<xsl:when test="position() = last() and self::text() and matches(., '\s$')">
						<xsl:value-of select="substring(., 1, string-length()-1)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</note>
	</xsl:template>
	
	<xsl:template match="w:r[wdb:isFirst(., 'KSkritischeAnmerkungbermehrereWrter', 'r')
		and following-sibling::w:r[wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')]]">
		<anchor type="crit_app" ref="s"/>
		<xsl:apply-templates select="w:t" />
	</xsl:template>
	<xsl:template match="w:r[wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r') and
		not(following-sibling::w:r[wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')])]">
		<xsl:if test="not(preceding-sibling::w:r[1][wdb:is(., 'KSkritischeAnmerkungbermehrereWrter', 'r')])">
			<anchor type="crit_app" ref="s" />
		</xsl:if>
		<xsl:apply-templates select="w:t" />
		<anchor type="crit_app" ref="se" />
	</xsl:template>
	<!-- ENDE kritische Anmerkungen -->
	
	<!-- RS -->
	<xsl:template match="w:r[wdb:is(., 'KSOrt', 'r')]">
		<rs type="place">
			<xsl:comment>TODO ref eintragen</xsl:comment>
			<xsl:apply-templates select="w:t"/>
		</rs>
	</xsl:template>
	
	<xsl:template match="w:r[wdb:is(., 'KSPerson', 'r')]">
		<rs type="person">
			<xsl:comment>TODO ref eintragen</xsl:comment>
			<xsl:apply-templates select="w:t"/>
		</rs>
	</xsl:template>
	
	<!-- neu 2017-12-06 DK -->
	<xsl:template match="w:r[wdb:is(., 'KSbibliographischeAngabe', 'r') and
		not(wdb:isFirst(., 'KSbibliographischeAngabe', 'r'))]" />
	<xsl:template match="w:r[wdb:isFirst(., 'KSbibliographischeAngabe', 'r')]">
		<xsl:variable name="me" select="." />
		<bibl>
			<xsl:apply-templates select="w:t | following-sibling::w:r[wdb:followMe(., $me, 'KSbibliographischeAngabe', 'r')]/w:t" />
		</bibl>
	</xsl:template>
	<xsl:template match="w:r[wdb:is(., 'KSbibliographischeAngabe', 'r') and
		not(descendant::w:vertAlign or descendant::w:i)]" mode="eval">
		<xsl:apply-templates select="w:t" />
	</xsl:template>
	
	<!-- neu 2017-12-08 DK -->
	<xsl:template match="w:r[wdb:is(., 'KSBibelstelle', 'r')]">
		<xsl:choose>
			<xsl:when test="ends-with(w:t, 'Vg')">
				<ref type="biblical"><xsl:value-of select="substring-before(w:t, ' Vg')"/></ref> Vg
			</xsl:when>
			<xsl:otherwise>
				<ref type="biblical"><xsl:apply-templates select="w:t" /></ref>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="w:r[wdb:is(., 'KSAutorenstelle', 'r')]">
		<ref type="medieval">
			<xsl:attribute name="cRef">
				<xsl:value-of select="substring-before(w:t, ',')" />
				<xsl:text>!</xsl:text>
				<xsl:value-of select="normalize-space(substring-after(w:t, ','))" />
			</xsl:attribute>
			<xsl:apply-templates select="w:t" />
		</ref>
	</xsl:template>
	<!-- Ende RS -->
	
	<!-- Funktionen -->
  <xd:doc>
    <xd:desc>Prüfen, ob es einen Absatz bildet</xd:desc>
  </xd:doc>
	<xsl:function name="hab:isP" as="xs:boolean">
		<xsl:param name="context"/>
		<xsl:sequence select="if($context//w:sym/@w:char='F05E' or $context//w:t[contains(., '')])
			then true() else false()"/>
	</xsl:function>
  
  <xd:doc>
    <xd:desc>Prüfen, ob es eine div begrenzt</xd:desc>
  </xd:doc>
  <xsl:function name="hab:isDiv" as="xs:boolean">
    <xsl:param name="context" />
    <xsl:sequence select="if($context//w:t or $context//w:pStyle) then false() else true()" />
  </xsl:function>
  
	<xsl:function name="hab:isStruct" as="xs:boolean">
		<xsl:param name="context" />
		<xsl:sequence select="hab:isP($context) or wdb:is($context, 'KSEE-Titel')
			or wdb:is($context, 'berschrift1') or wdb:is($context, 'KSZwischenberschrift')" />
	</xsl:function>
</xsl:stylesheet>
