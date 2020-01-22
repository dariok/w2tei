<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:wt="https://github.com/dariok/w2tei"
  xmlns:xstring = "https://github.com/dariok/XStringUtils"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all" version="3.0">
  <!-- neu 2016-07-28 Dario Kampkaspar (DK) – kampkaspar@hab.de -->
  <!-- denuo excusa XV Kal. Maii MMXIX Dario Kampkaspar – dario.kampkaspar@oeaw.ac.at -->
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="../word-pack.xsl"/>
  <xsl:import href="../string-pack.xsl"/>
  
  <!--<!-\- Standard-Schriftgröße bestimmen -\->
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
	</xsl:variable>-->
  
  <xsl:template match="/">
    <teiCorpus xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:for-each-group select="//tei:div"
        group-starting-with="tei:div[tei:p[contains(@style, 'berschriftSitzungMRP')]]">
        <xsl:variable name="title" select="(tei:p[contains(@style, 'berschriftSitzungMRP')], tei:p[1])[1]" />
        <xsl:variable name="md" select="tokenize($title, ', ')"/>
        <xsl:variable name="dat">
          <xsl:choose>
            <xsl:when test="contains($md[3], ' – ')">
              <xsl:value-of select="substring-before($md[3], ' – ')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$md[3]" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <TEI>
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <xsl:variable name="num" select="substring-before(substring-after($md[1], 'Nr. '), ' ')" />
                <xsl:variable name="da" select="tokenize($dat, ' ')" />
                <xsl:variable name="mo">
                  <xsl:choose>
                    <xsl:when test="$da[2] = 'Jänner'">01</xsl:when>
                    <xsl:when test="$da[2] = 'Februar'">02</xsl:when>
                    <xsl:when test="$da[2] = 'März'">03</xsl:when>
                    <xsl:when test="$da[2] = 'April'">04</xsl:when>
                    <xsl:when test="$da[2] = 'Mai'">05</xsl:when>
                    <xsl:when test="$da[2] = 'Juni'">06</xsl:when>
                    <xsl:when test="$da[2] = 'Juli'">07</xsl:when>
                    <xsl:when test="$da[2] = 'August'">08</xsl:when>
                    <xsl:when test="$da[2] = 'September'">09</xsl:when>
                    <xsl:when test="$da[2] = 'Oktober'">10</xsl:when>
                    <xsl:when test="$da[2] = 'November'">11</xsl:when>
                    <xsl:when test="$da[2] = 'Dezember'">12</xsl:when>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="datum" select="concat($mo, '-',
                  format-number(number(substring-before($da[1], '.')), '00'))" />
                <title type="num"><xsl:value-of select="$num"/></title>
                <xsl:if test="contains($md[3], ' – ')">
                  <title type="order">
                    <xsl:value-of select="substring-after($md[3], ' – ')" />
                  </title>
                </xsl:if>
                <title type="short">
                  <xsl:value-of select="format-number(xs:integer($num), '0000')" />
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="concat($da[3], '-', $datum)"/>
                </title>
                <meeting>
                  <placeName><xsl:value-of select="$md[2]"/></placeName>
                  <orgName>
                    <xsl:value-of select="normalize-space(substring-after(substring-after($md[1], 'Nr. '), ' '))"/>
                  </orgName>
                  <date when="{concat($da[3], '-', $datum)}"><xsl:value-of select="$dat" /></date>
                </meeting>
              </titleStmt>
              <publicationStmt><p/></publicationStmt>
              <xsl:sequence select="//tei:sourceDesc" />
            </fileDesc>
          </teiHeader>
          <text>
            <body>
            	<xsl:apply-templates select="tei:div" />
              <!--<xsl:apply-templates select="following-sibling::w:p[wt:isFirst(., 'Kopfregest', 'p')]" />
              <div>
                <xsl:apply-templates select="following-sibling::w:p[wt:is(., 'Protokoll-berschrift')]" />
                <xsl:for-each-group select="following-sibling::w:p[wt:is(., 'ProtokollTOP')]"
                  group-starting-with="w:p[wt:is(., 'ProtokollTOPAbsatz1')]">
                  <div type="top">
                    <xsl:apply-templates select="current-group()" />
                  </div>
                </xsl:for-each-group>
              </div>-->
            </body>
          </text>
        </TEI>
      </xsl:for-each-group>
    </teiCorpus>
  </xsl:template>
  
	<!--<xsl:template match="w:document">
		<teiCorpus xmlns="http://www.tei-c.org/ns/1.0">
			<xsl:for-each-group select="w:body/w:p" group-starting-with="w:p[wt:is(., 'berschriftSitzungMRP', 'p')]">
				<TEI>
					<teiHeader>
						<xsl:variable name="md" select="tokenize(string-join(w:r/w:t, ''), ', ')"/>
						<xsl:variable name="dat">
							<xsl:choose>
								<xsl:when test="contains($md[3], ' – ')">
									<xsl:value-of select="substring-before($md[3], ' – ')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$md[3]" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<fileDesc>
							<titleStmt>
								<xsl:variable name="num" select="substring-before(substring-after($md[1], 'Nr. '), ' ')" />
								<xsl:variable name="da" select="tokenize($dat, ' ')" />
								<xsl:variable name="mo">
									<xsl:choose>
										<xsl:when test="$da[2] = 'Jänner'">01</xsl:when>
										<xsl:when test="$da[2] = 'Februar'">02</xsl:when>
										<xsl:when test="$da[2] = 'März'">03</xsl:when>
										<xsl:when test="$da[2] = 'April'">04</xsl:when>
										<xsl:when test="$da[2] = 'Mai'">05</xsl:when>
										<xsl:when test="$da[2] = 'Juni'">06</xsl:when>
										<xsl:when test="$da[2] = 'Juli'">07</xsl:when>
										<xsl:when test="$da[2] = 'August'">08</xsl:when>
										<xsl:when test="$da[2] = 'September'">09</xsl:when>
										<xsl:when test="$da[2] = 'Oktober'">10</xsl:when>
										<xsl:when test="$da[2] = 'November'">11</xsl:when>
										<xsl:when test="$da[2] = 'Dezember'">12</xsl:when>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="datum" select="concat($mo, '-',
									format-number(number(substring-before($da[1], '.')), '00'))" />
								<title type="num"><xsl:value-of select="$num"/></title>
								<xsl:if test="contains($md[3], ' – ')">
									<title type="order">
										<xsl:value-of select="substring-after($md[3], ' – ')" />
									</title>
								</xsl:if>
								<title type="short">
									<xsl:value-of select="format-number(xs:integer($num), '0000')" />
									<xsl:text>-</xsl:text>
									<xsl:value-of select="concat($da[3], '-', $datum)"/>
								</title>
								<meeting>
									<placeName><xsl:value-of select="$md[2]"/></placeName>
									<orgName><xsl:value-of select="substring-after(substring-after($md[1], 'Nr. '), ' ')"/></orgName>
									<date when="{concat($da[3], '-', $datum)}"><xsl:value-of select="$dat" /></date>
								</meeting>
							</titleStmt>
							<publicationStmt><p/></publicationStmt>
							<sourceDesc><p/></sourceDesc>
						</fileDesc>
					</teiHeader>
					<text>
						<body>
							<xsl:apply-templates select="following-sibling::w:p[wt:isFirst(., 'Kopfregest', 'p')]" />
							<div>
								<xsl:apply-templates select="following-sibling::w:p[wt:is(., 'Protokoll-berschrift')]" />
								<xsl:for-each-group select="following-sibling::w:p[wt:is(., 'ProtokollTOP')]"
									group-starting-with="w:p[wt:is(., 'ProtokollTOPAbsatz1')]">
									<div type="top">
										<xsl:apply-templates select="current-group()" />
									</div>
								</xsl:for-each-group>
							</div>
						</body>
					</text>
				</TEI>
			</xsl:for-each-group>
		</teiCorpus>
	</xsl:template>
	
	<!-\- w:p -\->
	<xsl:template match="w:p[not(descendant::w:t)]" />
	
	<xsl:template match="w:p[wt:isFirst(., 'Kopfregest', 'p') and wt:hasContent(.)]">
		<div type="regest">
			<p>
				<xsl:apply-templates select="w:r"/>
			</p>
			<xsl:apply-templates select="following-sibling::w:p[wt:is(., 'Kopfregest')]"/>
			<xsl:apply-templates select="following-sibling::w:p[wt:is(., 'ProtokollAktenzahlen')]" />
		</div>
	</xsl:template>
	<xsl:template match="w:p[wt:is(., 'Kopfregest', 'p', true()) and not(wt:isFirst(., 'Kopfregest', 'p'))
		and wt:hasContent(.)]">
		<p>
			<xsl:apply-templates />
		</p>
	</xsl:template>
	<xsl:template match="w:p[wt:is(., 'Kopfregest-Namensliste')]">
		<listPerson>
			<xsl:apply-templates select="w:r[wt:is(., 'ErwhntePerson', 'r')] | w:hyperlink" />
		</listPerson>
	</xsl:template>
	<xsl:template match="w:p[wt:is(., 'Kopfregest-TObersicht')]">
		<list type="to">
			<xsl:apply-templates />
		</list>
	</xsl:template>
	
	<xsl:template match="w:p[wt:is(., 'ProtokollAktenzahlen')]">
		<idno><xsl:apply-templates select="w:r" /></idno>
	</xsl:template>
	
	<xsl:template match="w:p[wt:is(., 'Protokoll-berschrift')]">
		<head>
			<xsl:apply-templates />
		</head>
	</xsl:template>
	
	<xsl:template match="w:p[wt:is(., 'ProtokollTOP')]">
		<p>
			<xsl:apply-templates />
		</p>
	</xsl:template>
	<!-\- END w:p -\->
	
	<!-\- w:r -\->
	<!-\- content of w:r incl. styles -\->
	<xsl:template match="w:r" mode="content">
		<xsl:choose>
			<xsl:when test="w:t = ' '">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:when test="w:rPr/w:i | w:rPr/w:b | w:rPr/w:sz[@w:val != $mainsize]">
				<!-\- nur, wenn Größe von Standard abweicht; 2017-08-27 DK -\->
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
				<!-\- manuell hochgestellte FN-Zeichen bei krit. Anm. -\->
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
	
	<!-\- special w:r (need to call w:r mode="content" to get styles right) -\->
	<xsl:template match="w:r[ancestor::w:endnote
		and not(wt:is(., 'Endnotenzeichen', 'r'))]">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="w:r[wt:is(., 'ErwhntePerson', 'r')]">
		<xsl:param name="link" />
		<xsl:variable name="name" select="if(ancestor::w:p[wt:is(., 'Namensliste')]) then 'person' else 'rs'" />
		<xsl:element name="{$name}">
			<xsl:if test="$name = 'rs'">
				<xsl:attribute name="type" select="'person'" />
			</xsl:if>
			<xsl:if test="$link">
				<xsl:attribute name="ref" select="$link" />
			</xsl:if>
			<xsl:variable name="contents" as ="node()*">
				<xsl:apply-templates select="." mode="content"/>
			</xsl:variable>
			<xsl:for-each select="$contents">
				<xsl:choose>
					<xsl:when test="position() = last() and self::text()">
						<xsl:value-of select="xstring:substring-before-if-ends(., ' ')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:element>
		<xsl:if test="ends-with(., ' ')">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="w:r[not(descendant::w:rStyle or ancestor::w:endnote or ancestor::w:footnote)
		and w:t]">
		<xsl:apply-templates select="." mode="content" />
	</xsl:template>
	
	<xsl:template match="w:r[wt:is(., 'Endnotenzeichen', 'r')
		and(not(w:endnoteReference))]" />
	
	<xsl:template match="w:r[w:endnoteReference]">
		<note type="footnote">
			<xsl:variable name="nid" select="w:endnoteReference/@w:id" />
			<xsl:apply-templates
				select="//w:endnote[@w:id = $nid]"
			/>
		</note>
	</xsl:template>
	<!-\- END w:r -\->
	
	<!-\- neu 2016-07-31 DK -\->
	<xsl:template match="w:endnote">
		<xsl:apply-templates select="w:p/w:r | w:p/w:hyperlink"/>
	</xsl:template>
	
	<!-\- innerhalb eines Links sollte es hoffentlich keine besonderen Formatierungen geben; sonst 2. Durchgang nötig -\->
	<xsl:template match="w:hyperlink">
		<xsl:variable name="targetID" select="@r:id"/>
		<xsl:variable name="target" select="//rel:Relationship[@Id = $targetID
		  and contains(@Type, 'hyperlink')]/@Target"/>
		<xsl:variable name="wr">
			<w:p>
				<xsl:sequence select="preceding-sibling::w:pPr" />
				<w:r>
					<xsl:sequence select="w:r[1]/w:rPr" />
					<xsl:sequence select="descendant::w:t" />
				</w:r>
			</w:p>
		</xsl:variable>
		<xsl:apply-templates select="$wr//w:r">
			<xsl:with-param name="link" select="$target" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="*:pack">
		<xsl:apply-templates select="w:document" />
	</xsl:template>
	
	<xsl:template match="w:pPr | w:rPr" />
	<xsl:template match="text()[parent::w:p or parent::w:r][normalize-space() = '']" />-->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
