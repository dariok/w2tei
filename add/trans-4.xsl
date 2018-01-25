<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://tei-c.org/ns/1.0"
	exclude-result-prefixes="xs math" version="3.0">
	
	<xsl:include href="../string-pack.xsl"/>
	
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="text()[following-sibling::node()[1][self::tei:note[@type = 'crit_app']]]">
		<xsl:variable name="last" select="tokenize(., ' ')[last()]"/>
		<xsl:variable name="front" select="wdb:substring-before-last(., ' ')"/>
		<xsl:variable name="note" select="following-sibling::tei:note[1]"/>
		
		<xsl:if test="starts-with(., ' ')">
			<xsl:text> </xsl:text>
		</xsl:if>
		
		<xsl:if test="string-length($front) &gt; 0">
			<xsl:value-of select="string-join($front, ' ')"/>
			<xsl:text> </xsl:text>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="starts-with($note, 'folgt')">
				<xsl:variable name="wit" select="normalize-space($note/tei:orig/following-sibling::text())"/>
				<xsl:variable name="val" select="normalize-space($note/tei:orig)"/>
				<xsl:value-of select="$last"/>
				<add wit="{'#'||$wit}">
					<xsl:value-of select="$val"/>
				</add>
			</xsl:when>
			<!-- Phrasen in 128 -->
			<xsl:when
				test="matches($note/text()[1], '[vV]o[mn] Editor verbessert (für|aus)')">
				<!-- ('vom Editor verbessert für', 'vom Editor verbessert aus', 'von Editor verbessert aus') -->
				<choice>
					<sic>
						<xsl:value-of select="normalize-space($note/tei:orig[1])"/>
						<xsl:if test="$note/tei:orig[1]/following-sibling::node()">
							<note type="comment"><xsl:sequence select="$note/tei:orig[1]/following-sibling::node()"/></note>
						</xsl:if>
					</sic>
					<corr><xsl:value-of select="$last"/></corr>
				</choice>
			</xsl:when>
			<xsl:when test="$note/text()[1][normalize-space() = 'Danach gestrichen']">
				<xsl:value-of select="$last"/>
				<del>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space($note/tei:orig)"/>
				</del>
			</xsl:when>
			<xsl:when test="$note/node()[1][self::text()]">
				<!-- TODO später für mehrere rdg anpassen -->
				<xsl:variable name="wit" select="normalize-space($note/tei:hi)"/>
				<app>
					<lem wit="#A"><xsl:value-of select="$last"/></lem>
					<xsl:choose>
						<xsl:when test="contains($wit, ',')">
							<rdg wit="#{substring-before($wit, ',')}">
								<xsl:value-of select="normalize-space($note/text()[1])"/>
								<note type="comment"><xsl:value-of select="normalize-space(substring-after($wit, ','))"/></note>
							</rdg>
						</xsl:when>
						<xsl:otherwise>
							<rdg wit="#{$wit}"><xsl:value-of select="normalize-space($note/text()[1])"/></rdg>
						</xsl:otherwise>
					</xsl:choose>
				</app>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$last"/>
				<xsl:sequence select="$note"/>
			</xsl:otherwise>
		</xsl:choose>
		<!--				<xsl:text> </xsl:text>-->
	</xsl:template>
	
	<xsl:template match="tei:note[@type='crit_app']" />
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
