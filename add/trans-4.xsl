<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:xstring="https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	
<!--	<xsl:output indent="true"/>-->
	
	<xsl:include href="../string-pack.xsl"/>
	<xsl:include href="bibl.xsl"/>
	

	
	<xsl:template match="tei:ref[@type='biblical']">
		<ref type="biblical" cRef="{normalize-space(replace(., 'ö', ''))}">
			<xsl:value-of select="."/>
		</ref>
	</xsl:template>
	
	<xsl:template match="text()[not(parent::tei:note[@type='crit_app'] or parent::tei:span)]">
		<xsl:analyze-string select="." regex="&lt;.+&gt;">
			<xsl:matching-substring>
				<supplied><xsl:value-of select="substring(substring-before(., '&gt;'), 2)"/></supplied>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="." regex="\w+'.+?'\w?">
					<xsl:matching-substring>
						<expan>
							<xsl:analyze-string select="." regex="'.+'">
								<xsl:matching-substring><ex><xsl:value-of select="substring(substring(., 2), 1, string-length(.)-2)"/></ex></xsl:matching-substring>
								<xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
							</xsl:analyze-string>
						</expan>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="."/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<!-- in krit. Anmerkungen aus dem ; ihnter Zeugen eine Markierung machen, um später zu gruppieren -->
	<xsl:template match="tei:note[@type = 'crit_app']/text() | tei:span/text()">
		<xsl:analyze-string select="." regex=";">
			<xsl:matching-substring>
				<wdb:marker />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
