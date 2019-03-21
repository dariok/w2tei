<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs math"
	version="3.0">
	
	<!-- front getrennt behandeln -->
	<xsl:template match="tei:body//text()[not(parent::tei:div)]">
		<xsl:variable name="r2" select="'\{\w+\}'"/>
		<xsl:variable name="r1" select="'\w+\{.+?\}\w*'"/>
		<xsl:analyze-string select="." regex="{$r1}">
			<xsl:matching-substring>
				<expan>
					<xsl:analyze-string select="." regex="{$r2}">
						<xsl:matching-substring>
							<ex><xsl:value-of select="substring(substring(., 2), 1, string-length()-2)"/></ex>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="." />
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</expan>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:analyze-string select="." regex="\[\[.+\]\]">
					<xsl:matching-substring>
						<supplied>
							<xsl:value-of select="substring(., 3, string-length() - 4)"/>
						</supplied>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:analyze-string select="." regex="\[.+\]">
							<xsl:matching-substring>
								<unclear>
									<xsl:value-of select="substring(., 2, string-length() - 2)" />
								</unclear>
							</xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:value-of select="."/>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="tei:note[@type = 'crit_app']">
		<xsl:variable name="text" select="xstring:substring-after-last(preceding-sibling::text()[1], ' ')"/>
		<xsl:call-template name="critapp">
			<xsl:with-param name="note" select="." />
			<xsl:with-param name="text" select="$text" />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="text()[following-sibling::node()[1][self::tei:note[@type='crit_app']]]">
		<xsl:value-of select="xstring:substring-before-last(., ' ') || ' '" />
	</xsl:template>
	
	<xsl:template match="tei:anchor" />
	<xsl:template match="text()[preceding-sibling::tei:anchor and following-sibling::tei:anchor]">
		<xsl:variable name="pre" select="preceding-sibling::tei:anchor[1]/@xml:id"/>
		<xsl:choose>
			<xsl:when test="following-sibling::tei:anchor/@xml:id = $pre||'e'" />
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:span">
		<xsl:call-template name="critapp">
			<xsl:with-param name="text" select="id(substring-after(@from, '#'))/following-sibling::node()
				intersect id(substring-after(@to, '#'))/preceding-sibling::node()" />
			<xsl:with-param name="note" select="." />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="critapp">
		<xsl:param name="text" />
		<xsl:param name="note" />
		
		<xsl:choose>
			<xsl:when test="matches($note, 'ergänzt')">
				<add>
					<xsl:attribute name="place">
						<xsl:choose>
							<xsl:when test="matches(., 'am Rand')">margin</xsl:when>
							<xsl:when test="matches(., 'über der Zeile')">above</xsl:when>
							<xsl:when test="matches(., 'unter der Zeile')">below</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test="contains(., 'von anderer Hand')">
							<xsl:attribute name="hand">#other</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(., 'von')">
							<xsl:attribute name="hand" select="'#' || substring-before(substring-after($note, 'von '), ' ')" />
						</xsl:when>
					</xsl:choose>
					<xsl:sequence select="$text" /></add>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$note[self::tei:note]">
						<xsl:sequence select="$text" />
						<xsl:sequence select="$note" />
					</xsl:when>
					<xsl:otherwise>
						<anchor type="crit_app">
							<xsl:attribute name="xml:id" select="substring-after($note/@from, '#')" />
						</anchor>
						<xsl:sequence select="$text" />
						<anchor type="crit_app">
							<xsl:attribute name="xml:id" select="substring-after($note/@to, '#')" />
						</anchor>
						<xsl:sequence select="$note" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:div/text()">
		<xsl:text>
				</xsl:text>
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>