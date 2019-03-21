<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:xstring = "https://github.com/dariok/XStringUtils"
	xmlns:wt="https://github.com/dariok/w2tei"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="string-pack.xsl"/>
	<xsl:include href="word-pack.xsl"/>
	
	<xsl:variable name="titelei" select="string-join(//w:p[wt:is(., 'TBEE-Titel')])"/>
	<xsl:variable name="nr" select="normalize-space(xstring:substring-before(substring-after($titelei, 'ID'), ';'))" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="//w:document" />
	</xsl:template>
	
	<!-- TODO Schemapfad anpassen! -->
	<!-- TODO weitere Informationen umsetzen, sobald Beispiel -->
	<!-- Festlegung 2018-10-18: Titel as TBEETitel; danach Regest, danach Textvorlage; ggf. weitere Informationen.
		Nach 2 leeren Absätzen beginnt dann der Text. -->
	<xsl:template match="w:document">
		<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://dev2.hab.de/edoc/ed000240/rules/tei-p5-transcr.xsd"
			n="{substring-after(wt:string(//w:body//w:p[1]), ' ')}">
			<xsl:attribute name="xml:id" select="'bid' || normalize-space(substring-after(lower-case(//w:p[2]), 'id'))" />
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<xsl:apply-templates select="//w:p[wt:is(., 'TBEE-Titel')]" mode="titel"/>
						<xsl:apply-templates select="//w:body//w:p[wt:is(., 'TBText')
							and preceding-sibling::*[1][wt:is(., 'TBEE-Titel')]
							and contains(., 'arbeitet')]" mode="editor" />
					</titleStmt>
					<publicationStmt>
						<publisher>
							<name type="org">Heidelberger Akademie der Wissenschaften</name>
							<ptr target="https://www.hadw-bw.de/"/>
						</publisher>
						<distributor>Heidelberger Akademie der Wissenschaften</distributor>
						<availability status="restricted" />
					</publicationStmt>
					<sourceDesc>
						<xsl:apply-templates select="//w:p[wt:starts(., 'Textvorlage')]" mode="source" />
						<p>Erstellt aus Word-Vorlage mittels <ref target="https://github.com/dariok/w2tei">W2TEI</ref>: <date when="{current-dateTime()}" type="created" /></p>
					</sourceDesc>
				</fileDesc>
				<encodingDesc>
					<p>Zeichen aus der Private Use Area entsprechen MUFI 4.0 (http://mufi.info)</p>
					<projectDesc>
						<p xml:id="tb">
							<ref target="https://www.hadw-bw.de/forschung/forschungsstelle/theologenbriefwechsel-im-suedwesten-des-reichs-der-fruehen-neuzeit-1550">Theologenbriefwechsel im Südwesten des Reichs in der Frühen Neuzeit (1550–1620)</ref>
						</p>
					</projectDesc>
				</encodingDesc>
			</teiHeader>
			<text>
				<front>
					<div type="regest">
						<p><xsl:sequence select="w:body/w:p[wt:starts(., 'Regest:')]/w:r[wt:ends(., ':')][1]/following-sibling::w:r" /></p>
					</div>
					<div type="vorlage">
						<p><xsl:sequence select="w:body/w:p[wt:starts(., 'Textvorlage')]/w:r[wt:ends(., ':')][1]/following-sibling::w:r" /></p>
					</div>
					<xsl:if test="w:body/w:p[wt:starts(., 'Edition')]">
						<div type="edition">
							<p><xsl:sequence select="w:body/w:p[wt:starts(., 'Edition')]/w:r[wt:ends(., ':')][1]/following-sibling::w:r" /></p>
						</div>
					</xsl:if>
					<xsl:if test="w:body/w:p[wt:starts(., 'weitere')]">
						<div type="add">
							<p><xsl:sequence select="w:body/w:p[wt:starts(., 'weitere')]/w:r[wt:ends(., ':')][1]/following-sibling::w:r" /></p>
						</div>
					</xsl:if>
				</front>
				<body>
					<xsl:apply-templates select="//w:body"/>
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<!-- Templates für die Übertragung von Textteilen in den teiHeader -->
	<xsl:template match="w:p[wt:is(., 'TBEE-Titel')]" mode="titel">
		<xsl:choose>
			<xsl:when test="wt:string(.) = ''" />
			<xsl:otherwise>
				<title><xsl:apply-templates select="w:r/w:t" /></title>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="w:p" mode="editor">
		<editor>
			<xsl:value-of select="substring-after(wt:string(.), 'von ')"/>
		</editor>
	</xsl:template>
	<xsl:template match="w:p" mode="source">
		<p>
			<xsl:apply-templates select="w:r[wt:ends(., 'age:')]/following-sibling::w:r/w:t" />
		</p>
	</xsl:template>
	
	<!-- Übernehmen der Hauptbestandteile -->
	<xsl:template match="w:body">
		<!--<xsl:sequence  select="w:p[not(wt:is(., 'TBEE-Titel'))]"/>-->
		<xsl:for-each-group
			select="(w:p[not(descendant::w:t) and preceding-sibling::w:p[1][not(descendant::w:t)]])[1]/following-sibling::w:p"
			group-starting-with="w:p[wt:is(., 'TBZwischenberschrift')
			or wt:isFirst(., 'TBPostscriptum', 'p')]">
			<xsl:text>
			</xsl:text>
			<div>
				<xsl:sequence select="current-group()" />
			</div>
		</xsl:for-each-group>
		<xsl:sequence select="/pack/*[not(self::w:document)]"/>
	</xsl:template>
</xsl:stylesheet>