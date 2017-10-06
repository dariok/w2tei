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
				<body>
					<xsl:apply-templates select="descendant::w:body"/>
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<xsl:template match="w:body">
		<!-- Überschriften sind mittig; vor ihnen sind nichtmittige Teile; mit der ersten mittigen nach einer nichtmittigen fängt eine div an -->
		<!--<xsl:apply-templates
			select="w:p[w:pPr/w:jc/@w:val = 'center' and preceding-sibling::*[1][self::w:p[not(w:pPr/w:jc/@w:val = 'center')]]] | w:tbl"
		/>-->
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- neu 2016-08-11 DK -->
    <xsl:template match="w:p[not(descendant::w:t)]" />
    <xsl:template match="w:p[not(descendant::w:t)]" mode="text" />
    <xsl:template match="w:body/text()" />
	
	<xsl:template
		match="w:p[descendant::w:t and (w:pPr/w:jc/@w:val = 'center' and preceding-sibling::*[1][self::w:p[not(w:pPr/w:jc/@w:val = 'center')]]
		and not(parent::w:tc))]">
		<div>
			<head>
				<xsl:apply-templates select="." mode="text"/>
				<!-- angepaßt 2016-07-31 DK -->
				<!-- alle folgenden zentrierten, bis ein nicht zentrierter folgt -->
				<xsl:apply-templates
					select="following-sibling::w:p intersect following-sibling::w:p[not(w:pPr/w:jc/@w:val = 'center')][1]/preceding-sibling::w:p"
					mode="text"/>
			</head>
		</div>
	</xsl:template>
	
	<!-- neu 2016-08-11 DK -->
    <xsl:template match="w:p[descendant::w:t and (w:pPr/w:jc/@w:val = 'center' and preceding-sibling::*[1][self::w:p[w:pPr/w:jc/@w:val = 'center']]
			and not(parent::w:tc))]" />
	
	<xsl:template match="w:p[descendant::w:t and (w:pPr/w:jc/@w:val = 'center')]" mode="text">
		<xsl:apply-templates select="w:r"/>
		<!-- In Titeln werden die Zeilenumbrüche ausgegeben; 2016-07-31 DK -->
		<lb/>
	</xsl:template>
	
	<xsl:template match="w:p[descendant::w:t and (w:r and not(w:pPr/w:jc/@w:val = 'center') and not(parent::w:tc))]">
		<p>
			<xsl:apply-templates select="w:r"/>
		</p>
	</xsl:template>
	
	<!-- neu 2016-07-31 DK -->
	<xsl:template match="w:tc/w:p[descendant::w:t]">
		<xsl:apply-templates select="w:r"/>
		<xsl:if test="following-sibling::w:p">
			<lb/>
		</xsl:if>
	</xsl:template>
	
    <xsl:template match="w:r[not(w:t) and not(w:footnoteReference) and not(ancestor::w:footnote)]" />
	
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
				<xsl:element name="hi">
					<xsl:attribute name="rend">
						<xsl:if test="w:rPr/w:sz">
							<xsl:variable name="si" select="w:rPr/w:sz/@w:val * 0.5"/>
							<xsl:value-of select="concat('font-size:', $si, 'pt;')"/>
						</xsl:if>
						<xsl:if test="w:rPr/w:i">
							<xsl:text>font-style:italic;</xsl:text>
						</xsl:if>
						<xsl:if test="w:rPr/w:b">
							<xsl:text>font-weight:bold;</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:apply-templates select="w:t"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="w:t"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- neu 2016-08-10 DK -->
	<xsl:template match="w:r[ancestor::w:footnote]">
		<!-- Originalschreibung recte; 2016-08-10 DK -->
		<xsl:choose>
			<xsl:when test="not(w:t) or w:t = '*' or w:t = ' '"/>
			<xsl:when test="not(w:rPr) or not(w:rPr/w:i)">
				<orig>
					<xsl:apply-templates select="w:t"/>
				</orig>
			</xsl:when>
		    <!-- neu 2016-08-11 DK -->
		    <!-- aufgrund der viel zu kleinteiligen Kodierung von Word wieder auskommentiert -->
		    <!--<xsl:when test="w:rPr/w:i and w:rPr/w:u">
		        <quote>
		            <xsl:apply-templates select="w:t" />
		        </quote>
		    </xsl:when>-->
			<xsl:otherwise>
				<xsl:apply-templates select="w:t"/>
			</xsl:otherwise>
		</xsl:choose>
	    <xsl:if test="contains(w:t, 'S. #') or contains(w:t, 'Anm. #')">
	        <xsl:comment>TODO: Verweis</xsl:comment>
	    </xsl:if>
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
	
	<!-- Anfang von Seitenumbrüchen; 2016-07-31 DK -->
	<xsl:template match="w:t[contains(., '&lt;fol.') or contains(., '&lt;S.')]">
		<xsl:value-of select="substring-before(., '&lt;')"/>
		<xsl:choose>
			<xsl:when test="contains(., '&gt;')">
				<pb n="{substring-after(substring-before(., '&gt;'), '&lt;')}"/>
			</xsl:when>
			<xsl:otherwise>
				<pb n="{substring-after(., '&lt;')}"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="substring-after(., '&gt;')"/>
	</xsl:template>
	
	<!-- entstehen, wenn in einem Seitenumbruch Fußnoten auftauchen; 2016-07-31 DK -->
	<xsl:template match="w:t[(. = '*' and preceding-sibling::w:rPr//w:vertAlign/@w:val='superscript') or normalize-space() = '&gt;']">
		<!-- ggfs. vorhandener Whitespace muß allerdings übernommen werden -->
		<xsl:if test="ends-with(., ' ')">
			<xsl:text> </xsl:text>
		</xsl:if>
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
