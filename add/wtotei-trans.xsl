<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:hab="http://diglib.hab.de"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	<!-- neu 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	
	<xsl:include href="ks-common.xsl"/>
	
	<xsl:output indent="yes"/>
	
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
			<xsl:attribute name="xml:id" select="concat('edoc_ed000240_', $ee, '_introduction')" />
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title>
							<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel')][2]//w:t" mode="mTitle" />
							<xsl:apply-templates select="//w:p[wdb:is(., 'KSEE-Titel')][3]" mode="date"/>
						</title>
						<!-- Kurztitel erzeugen; 2017-08-07 DK -->
						<title type="short">
							<xsl:if test="//w:p[wdb:isHead(., 1)][1]//w:t='Referenz'">
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
								<xsl:when test="//w:p[wdb:isHead(., 1)][1]//w:t='Referenz'
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
								<xsl:when test="//w:p[wdb:isHead(., 1)][1]//w:t='Referenz'
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
						<xsl:if test="//w:p[wdb:isHead(., 1)][1]//w:t='Referenz'">
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
					<xsl:apply-templates select="//w:body/w:p" />
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<xsl:template match="w:p[wdb:isHead(., 1)]"/>
	
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
	
	<xsl:function name="wdb:isHead" as="xs:boolean">
		<xsl:param name="context" as="node()" />
		<xsl:param name="num"/>
		<xsl:value-of select="wdb:is($context, 'KSberschrift'||$num)"/>
	</xsl:function>
</xsl:stylesheet>
