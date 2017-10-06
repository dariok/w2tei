<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="2.0">
	<!-- neu 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
	
<!--	<xsl:output indent="yes"/>-->
	
	<!-- Standard-Schriftgröße bestimmen -->
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
	
	<xsl:template match="/">
		<teiCorpus xmlns="http://www.tei-c.org/ns/1.0">
			<xsl:apply-templates select="//w:p[w:pPr/w:rPr/w:b or w:pPr/w:pStyle[@w:val='berschrift1']]" />
		</teiCorpus>
	</xsl:template>
	
	<xsl:template match="w:p[w:pPr/w:rPr/w:b or w:pPr/w:pStyle[@w:val='berschrift1']]">
		<TEI>
			<teiHeader>
				<xsl:comment>Mainsize: <xsl:value-of select="$mainsize"/> = <xsl:value-of select="$mainsize div 2"/>pt;</xsl:comment>
				<xsl:variable name="md" select="tokenize(w:r/w:t, ', ')"/>
				<fileDesc>
					<titleStmt>
						<title type="num"><xsl:value-of select="substring-before(substring-after($md[1], 'Nr. '), ' ')"/></title>
						<meeting>
							<placeName><xsl:value-of select="$md[2]"/></placeName>
							<orgName><xsl:value-of select="substring-after(substring-after($md[1], 'Nr. '), ' ')"/></orgName>
							<date><xsl:choose>
								<xsl:when test="contains($md[3], ' – ')">
									<xsl:value-of select="substring-before($md[3], ' – ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$md[3]" />
								</xsl:otherwise>
							</xsl:choose></date>
						</meeting>
						<xsl:if test="contains($md[3], ' – ')">
							<title type="order">
								<xsl:value-of select="substring-after($md[3], ' – ')" />
							</title>
						</xsl:if>
					</titleStmt>
					<publicationStmt><p/></publicationStmt>
					<sourceDesc><p/></sourceDesc>
				</fileDesc>
			</teiHeader>
			<text>
				<body>
					<xsl:choose>
						<xsl:when test="following-sibling::w:p[w:pPr/w:rPr/w:b or w:pPr/w:pStye[@w:val='berschrift1']]">
							<xsl:variable name="follId"
								select="generate-id(following-sibling::w:p[w:pPr/w:rPr/w:b or w:pPr/w:pStye[@w:val='berschrift1']][1])"/>
							<xsl:apply-templates select="following-sibling::w:p intersect 
								following-sibling::w:p[generate-id() = $follId]/preceding-sibling::w:p" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="following-sibling::w:p" />
						</xsl:otherwise>
					</xsl:choose>
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<!-- neu 2016-08-11 DK -->
    <xsl:template match="w:p[not(descendant::w:t)]" />
    <xsl:template match="w:p[not(descendant::w:t)]" mode="text" />
    <xsl:template match="w:body/text()" />
	
	<!-- Aktenzeichen -->
	<xsl:template match="w:p[not(w:pPr/w:ind or w:pPr/w:pStyle) and descendant::w:t][1]">
		<div type="idno"><p><idno><xsl:apply-templates select="w:r//w:t"/></idno></p></div>
	</xsl:template>
	
	<!-- Struktur hinter dem AZ -->
	<xsl:template match="w:p[not(w:pPr/w:ind or w:pPr/w:pStyle) and descendant::w:t][2]">
		<div type="text">
			<xsl:apply-templates
				select=".
				| following-sibling::w:p[descendant::w:t and not(w:pPr//w:b or w:pPr/w:ind)
					and not(w:pPr/w:pStyle) and not(descendant::w:sz/@w:val='20')]"
				mode="text" />
		</div>
	</xsl:template>
	
	<!-- normaler Absatz - wird vom ersten nach dem AZ zusammengehalten; 2017-10-06 DK -->
	<xsl:template match="w:p[descendant::w:t and not(w:pPr//w:b or w:pPr/w:ind) and not(w:pPr/w:pStyle)
		and not(descendant::w:sz/@w:val='20')][position()>2]"
		/>
	<xsl:template match="w:p[descendant::w:t and not(w:pPr//w:b or w:pPr/w:ind) and not(w:pPr/w:pStyle)
		and not(descendant::w:sz/@w:val='20')][position()>1]"
		mode="text">
		<p>
			<xsl:apply-templates select="w:r"/>
		</p>
	</xsl:template>
	
	<!-- Schriftgröße 10 sind krit. Anmerkungen -->
	<xsl:template match="w:p[descendant::w:sz/@w:val='20']" mode="fn">
		<xsl:apply-templates select="w:r"/>
	</xsl:template>
	<xsl:template match="w:p[descendant::w:sz/@w:val='20']" />
	
	<!-- neu 2017-10-06 DK -->
	<!-- eingerückt sind die Info am Anfang -->
	<xsl:template match="w:p[w:pPr/w:ind and descendant::w:t]">
		<div>
			<xsl:choose>
				<xsl:when test="starts-with(w:r[1]/w:t, 'P.')">
					<!-- Personen / Anwesenheitsliste -->
					<xsl:attribute name="type">pers</xsl:attribute>
					<xsl:variable name="str" select="string-join(w:r/w:t, '')"/>
					<!-- endet mit Punkt -->
					<xsl:variable name="pers" select="substring($str, 1, string-length($str)-1)" />
					<xsl:variable name="functs" select="tokenize($pers, '; ')" />
					<listPerson>
						<person role="protocol"><xsl:value-of select="substring-after($functs[1], ' ')"/></person>
						<person role="chair"><xsl:value-of select="substring-after($functs[2], ' ')"/></person>
						<xsl:for-each select="tokenize(substring-after($functs[3], 'anw. '), ', ')">
							<person><xsl:value-of select="current()"/></person>
						</xsl:for-each>
					</listPerson>
				</xsl:when>
				<xsl:when test="starts-with(w:r[1]/w:t, 'I.')">
					<!-- Kurzregest -->
					<xsl:attribute name="type">reg</xsl:attribute>
					<xsl:apply-templates select="w:r"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="type">other</xsl:attribute>
					<xsl:apply-templates select="w:r"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
    <xsl:template match="w:r[not(w:t) and not(w:endnoteReference) and not(ancestor::w:endnote)]" />
	
	<!-- neu 2016-07-31 DK -->
	<!-- Fußnoten getrennt behandeln; 2016-08-10 DK -->
	<xsl:template match="w:r[w:t and not(w:endnoteReference) and not(ancestor::w:endnote)]">
		<xsl:choose>
			<xsl:when test="w:t = ' '">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="w:rPr/w:i | w:rPr/w:b | w:rPr/w:sz[@w:val != $mainsize]">
				<!-- nur, wenn Größe von Standard abweicht; 2017-08-27 DK -->
				<hi>
					<xsl:attribute name="rend">
						<xsl:if test="w:rPr/w:sz and w:rPr/w:sz[@w:val != $mainsize]">
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
				</hi>
			</xsl:when>
			<xsl:when test="w:rPr/w:vertAlign">
				<!-- manuell hochgestellte FN-Zeichen bei krit. Anm. -->
				<note type="crit_app">
					<xsl:variable name="fnz" select="normalize-space()" />
					<xsl:apply-templates select="//w:p[descendant::w:sz/@w:val='20'
						and starts-with(descendant::w:t[1], $fnz)]" mode="fn"/>
				</note>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="w:t"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- neu 2016-08-10 DK -->
	<xsl:template match="w:r[ancestor::w:endnote]">
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
	<xsl:template match="w:r[w:endnoteReference]">
		<note type="footnote">
			<xsl:apply-templates
				select="/pkg:package/pkg:part[@pkg:name = '/word/endnotes.xml']/pkg:xmlData/w:endnotes/w:endnote[@w:id = current()/w:endnoteReference/@w:id]"
			/>
		</note>
	</xsl:template>
	
	<!-- neu 2016-07-31 DK -->
	<xsl:template match="w:endnote">
		<xsl:apply-templates select="w:p/w:r"/>
	</xsl:template>
</xsl:stylesheet>
