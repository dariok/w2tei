<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="2.0">
	<!-- neu 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	
	<xsl:output indent="yes"/>
	
	<xsl:template match="/">
		<TEI xmlns="http://www.tei-c.org/ns/1.0">
			<teiHeader/>
			<text>
				<front>
					<xsl:apply-templates select="descendant::w:body/w:p[w:pPr/w:pStyle[@w:val='berschrift1']]"/>
					<xsl:apply-templates select="descendant::w:body/w:p[preceding::w:pPr/w:pStyle[@w:val='berschrift1']
						and not(preceding::w:pPr/w:pStyle[@w:val='berschrift2'] or w:pPr/w:pStyle/@w:val[contains(., 'berschrift2')])]"/>
				</front>
				<body>
					<xsl:apply-templates select="descendant::w:body/w:p[w:pPr/w:pStyle[@w:val='berschrift2']]"/>
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<xsl:template match="w:body">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- neu 2016-08-11 DK -->
	<xsl:template match="w:p[not(descendant::w:t)]" />
	<xsl:template match="w:p[not(descendant::w:t)]" mode="text" />
	<xsl:template match="w:body/text()" />
	
	<!-- Überschrift 1 = Titelei -->
	<xsl:template match="w:p[w:pPr/w:pStyle[@w:val='berschrift1']]">
			<head>
				<!-- Größe 24 = 12pt als Standard annehmen; 2017-03-16 DK -->
				<xsl:if test="w:pPr/w:rPr/w:sz/@w:val != 24">
					<xsl:attribute name="style">
						<xsl:text>font-size:</xsl:text>
						<xsl:value-of select="0.5 * w:pPr/w:rPr/w:sz/@w:val" />
						<xsl:text>pt</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="w:r"/>
			</head>
	</xsl:template>
	
	<!-- Überschrift 2 = Kapitel -->
	<xsl:template match="w:p[w:pPr/w:pStyle[@w:val='berschrift2']]">
		<div>
			<head>
				<xsl:if test="w:pPr/w:rPr/w:sz/@w:val != 24">
					<xsl:attribute name="style">
						<xsl:text>font-size:</xsl:text>
						<xsl:value-of select="0.5 * w:pPr/w:rPr/w:sz/@w:val" />
						<xsl:text>pt</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="w:r"/>
			</head>
			<!--<xsl:variable name="following2"
				select="generate-id(following-sibling::w:p[w:pPr/w:pStyle[@w:val='berschrift2']][1])"/>
			<xsl:variable name="following3"
				select="generate-id(following-sibling::w:p[w:pPr/w:pStyle[@w:val='berschrift3']
				and generate-id(following-sibling::w:p[w:pPr/w:pStyle[@w:val='berschrift2']][1]) = $following2][1])[1]"/>
			<xsl:apply-templates
				select="following-sibling::w:p[
					generate-id(following-sibling::w:p[w:pPr/w:pStyle[@w:val='berschrift2']][1]) = $following2
					and (w:pPr/w:pStyle[@w:val='berschrift3'] 
					or generate-id(following-sibling::w:p[w:pPr/w:pStyle[@w:val='berschrift3']][1]) = $following3)
					]" />-->
			<xsl:variable name="norm" select="following-sibling::w:p[not(w:pPr/w:pStyle/@w:val[contains(., 'berschrift')])]
				intersect following-sibling::w:p[w:pPr/w:pStyle/@w:val[contains(., 'berschrift')]][1]/preceding-sibling::w:p" />
			<xsl:variable name="sub" select="following-sibling::w:p[w:pPr/w:pStyle/@w:val[contains(., 'berschrift3')]]
				intersect following-sibling::w:p[w:pPr/w:pStyle/@w:val[contains(., 'berschrift2')]][1]/preceding-sibling::w:p" />
			<xsl:apply-templates select="$norm | $sub"/>
		</div>
	</xsl:template>
	
	<!-- Überschrift 3 = Abschnitt identisch -->
	<xsl:template match="w:p[w:pPr/w:pStyle[@w:val='berschrift3']]">
		<div>
			<head>
				<xsl:if test="w:pPr/w:rPr/w:sz/@w:val != 24">
					<xsl:attribute name="style">
						<xsl:text>font-size:</xsl:text>
						<xsl:value-of select="0.5 * w:pPr/w:rPr/w:sz/@w:val" />
						<xsl:text>pt</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates select="w:r"/>
			</head>
			<xsl:apply-templates
				select="following::w:p intersect following::w:p[w:pPr/w:pStyle/@w:val[contains(., 'berschrift')]][1]/preceding-sibling::w:p" />
			<!--select="following-sibling::w:p[generate-id(following-sibling::w:p[w:pPr/w:pStyle[@w:val='berschrift3']][1]) = $following]" />-->
		</div>
	</xsl:template>
	
	<!-- Überschrift 4 – nicht als head -->
	<xsl:template match="w:p[w:pPr/w:pStyle[@w:val='berschrift4']]">
		<p n="ü4"><xsl:apply-templates select="w:r" /></p>
	</xsl:template>
	
	<!-- Abbildungen -->
	<xsl:template match="w:p[w:pPr/w:pStyle/@w:val='Beschriftung']">
		<xsl:variable name="nr" select="concat('abb', w:fldSimple/w:t)" />
		<ref type="abb" target="{$nr}"><xsl:apply-templates select="w:r | w:fldSimple/w:r" /></ref>
	</xsl:template>
	
	<!-- Zitate? -->
	<xsl:template match="w:p[w:pPr/w:ind/@w:left &gt; 500 and not(w:pPr/w:pStyle)]">
		<cit><quote><xsl:apply-templates select="w:r" /></quote></cit>
	</xsl:template>
	
	<!-- Zitate? -->
	<xsl:template match="w:p[w:pPr/w:ind/@w:left &gt; 0 and w:pPr/w:ind/@w:left &lt; 500 and not(w:pPr/w:pStyle)]">
		<p><xsl:apply-templates select="w:r" /></p>
	</xsl:template>
	
	<!-- normaler Absatz -->
	<xsl:template match="w:p[w:r/w:t and not(w:pPr/w:pStyle or w:pPr/w:ind)]">
		<p>
			<xsl:apply-templates select="w:r" />
		</p>
	</xsl:template>
	
	<!-- auch normal? -->
	<xsl:template match="w:p[w:pPr/w:pStyle/@w:val[contains(., 'StandardWeb')
				or contains(., 'Text')]]">
		<p>
			<xsl:apply-templates select="w:r" />
		</p>
	</xsl:template>
	
	<!-- neu 2016-07-31 DK -->
	<!-- Fußnoten getrennt behandeln; 2016-08-10 DK -->
	<xsl:template match="w:r[w:t and not(w:footnoteReference) and not(ancestor::w:footnote)]">
		<xsl:if test="w:tab">
			<space dim="horizontal" />
		</xsl:if>
		<xsl:choose>
			<xsl:when test="w:t = ' '">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="w:rPr/w:sz | w:rPr/w:i | w:rPr/w:b">
				<xsl:variable name="rend">
					<xsl:if test="w:rPr/w:sz and
						w:rPr/w:sz/@w:val != parent::w:p/w:pPr/w:rPr/w:sz/@w:val">
						<xsl:variable name="si" select="w:rPr/w:sz/@w:val * 0.5"/>
						<xsl:value-of select="concat('font-size:', $si, 'pt;')"/>
					</xsl:if>
					<xsl:if test="w:rPr/w:i">
						<xsl:text>font-style:italic;</xsl:text>
					</xsl:if>
					<xsl:if test="w:rPr/w:b">
						<xsl:text>font-weight:bold;</xsl:text>
					</xsl:if>
				</xsl:variable>
				<!-- hi nur dann, wenn es wirklich etwas zum Highlighten gibt; 2017-03-16 DK -->
				<xsl:choose>
					<xsl:when test="string-length($rend) &gt; 0">
						<hi>
							<xsl:attribute name="rend" select="$rend" />
							<xsl:apply-templates select="w:t"/>
						</hi>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="w:t"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="w:t"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- neu 2016-08-10 DK -->
	<xsl:template match="w:r[ancestor::w:footnote]">
		<xsl:apply-templates select="w:t"/>
		<xsl:if test="contains(w:t, 'S. #') or contains(w:t, 'Anm. #')">
			<xsl:comment>TODO: Verweis</xsl:comment>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="w:t[matches(., '.*VD.?17 \d+:\w+.*')]">
		<xsl:analyze-string regex="VD.?17 \d+:\w+" select=".">
			<xsl:matching-substring>
				<idno type="vd17"><xsl:value-of select="current()"/></idno>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="current()"/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	
	<!-- neu 2016-07-31 DK -->
	<xsl:template match="w:r[w:footnoteReference]">
		<xsl:element name="note">
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="starts-with((following::w:r/w:t)[1], '*')">
						<xsl:text>crit_app</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>footnote</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates
				select="/pkg:package/pkg:part[@pkg:name = '/word/footnotes.xml']/pkg:xmlData/w:footnotes/w:footnote[@w:id = current()/w:footnoteReference/@w:id]"
			/>
		</xsl:element>
	</xsl:template>
	
	<!-- neu 2016-07-31 DK -->
	<xsl:template match="w:footnote">
		<xsl:apply-templates select="w:p/w:r"/>
	</xsl:template>
	
	<!-- neu 2016-07-31 DK -->
	<xsl:template match="w:tbl">
		<xsl:apply-templates select="w:tr/w:tc"/>
	</xsl:template>
	
	<xsl:template match="w:tc">
		<xsl:if test="descendant::w:t">
			<closer>
				<xsl:attribute name="rend">
					<xsl:choose>
						<xsl:when test="w:p[1]/w:pPr/w:jc/@w:val = 'right'">
							<xsl:text>text-align:right;</xsl:text>
						</xsl:when>
						<xsl:when test="w:p[1]/w:pPr/w:jc/@w:val = 'center'">
							<xsl:text>text-align:center;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>text-align:left;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<!-- es kommen nur Tabellen mit 2 Spalten vor -->
					<xsl:choose>
						<xsl:when test="following-sibling::w:tc">
							<xsl:text>align:left;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>align:right;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="w:p"/>
			</closer>
		</xsl:if>
	</xsl:template>
    
    <!-- neu 2016-08-11 DK -->
    <xsl:template match="w:sectPr" />
</xsl:stylesheet>
