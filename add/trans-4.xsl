<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all" version="3.0">
	
<!--	<xsl:output indent="true"/>-->
	
	<xsl:include href="../string-pack.xsl"/>
	<xsl:include href="bibl.xsl"/>
	
	<xsl:template match="/">
		<xsl:processing-instruction name="xml-model">href="http://dev2.hab.de/edoc/ed000240/rules/phase.sch"</xsl:processing-instruction>
		<xsl:apply-templates select="node()" />
	</xsl:template>
	
	<xsl:template match="tei:ref[@type='biblical']">
		<ref type="biblical" cRef="{normalize-space(replace(., 'ö', ''))}">
			<xsl:value-of select="."/>
		</ref>
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
			<xsl:when test="starts-with($note, 'folgt') and $note/tei:orig">
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
			<xsl:when test="$note/node()[1][self::text()[ends-with(., ';')]]">
				<!--<xsl:variable name="witA">
					<xsl:value-of select="wdb:substring-before-if-ends($note/text()[1], ';')"/>
				</xsl:variable>-->
				<xsl:variable name="witA">
					<xsl:variable name="wits">
						<xsl:for-each select="tokenize(wdb:substring-before-if-ends($note/text()[1], ';'), ',')">
							<xsl:if test="string-length(.) &lt; 5">
								<xsl:value-of
									select="'#'||normalize-space(wdb:substring-before(wdb:substring-before(., ';'), '.'))||' '"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="normalize-space(wdb:substring-before-if-ends($wits, ';'))"/>
				</xsl:variable>
				<app>
					<lem wit="{$witA}"><xsl:value-of select="$last"/></lem>
				    <xsl:apply-templates select="$note/tei:orig" />
				</app>
			</xsl:when>
			<xsl:when test="($note/node()[1][self::tei:orig] and $note/node()[2])
			    or ($note/node()[1][self::text()[normalize-space()='']] and $note/node()[2][self::tei:orig])">
				<xsl:choose>
					<xsl:when test="starts-with(normalize-space(($note/tei:orig/following-sibling::text())[1]), 'vermutet')">
						<xsl:value-of select="$last"/>
						<note type="crit_app">
							<orig><xsl:value-of select="normalize-space($note/tei:orig)"/></orig>
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space($note/tei:orig/following-sibling::text())"/>
						</note>
					</xsl:when>
					<xsl:otherwise>
						<app>
							<lem wit="#A"><xsl:value-of select="$last"/></lem>
							<xsl:apply-templates select="$note/tei:orig" />
						</app>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$last"/>
				<xsl:sequence select="$note"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
    <xsl:template match="tei:note[@type = 'crit_app'
        and (preceding-sibling::node()[1][self::tei:*] or not(preceding-sibling::node()))]">
        <xsl:choose>
            <xsl:when test="starts-with(., 'folgt')">
                <xsl:variable name="wit" select="normalize-space(./tei:orig/following-sibling::text())"/>
                <xsl:variable name="val" select="normalize-space(./tei:orig)"/>
                <add wit="{'#'||$wit}">
                    <xsl:value-of select="$val"/>
                </add>
            </xsl:when>
            <!-- Phrasen in 128 -->
            <!--<xsl:when
                test="matches(./text()[1], '[vV]o[mn] Editor verbessert (für|aus)')">
                <choice>
                    <sic>
                        <xsl:value-of select="normalize-space(./tei:orig[1])"/>
                        <xsl:if test="./tei:orig[1]/following-sibling::node()">
                            <note type="comment"><xsl:sequence select="./tei:orig[1]/following-sibling::node()"/></note>
                        </xsl:if>
                    </sic>
                    <corr><xsl:value-of select="$last"/></corr>
                </choice>
            </xsl:when>-->
            <xsl:when test="./text()[1][normalize-space() = 'Danach gestrichen']">
                <del>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="normalize-space(./tei:orig)"/>
                </del>
            </xsl:when>
            <xsl:when test="./node()[1][self::text()[ends-with(., ';')]]">
            	<xsl:variable name="witA">
            		<xsl:variable name="wits">
            			<xsl:for-each select="tokenize(wdb:substring-before-if-ends(text()[1], ';'), ',')">
            				<xsl:if test="string-length(.) &lt; 5">
            					<xsl:value-of
            						select="'#'||normalize-space(wdb:substring-before(wdb:substring-before(., ';'), '.'))||' '"/>
            				</xsl:if>
            			</xsl:for-each>
            		</xsl:variable>
            		<xsl:value-of select="normalize-space(wdb:substring-before-if-ends($wits, ';'))"/>
            	</xsl:variable>
                <app>
                    <lem wit="{$witA}"/>
                    <xsl:apply-templates select="./tei:orig" />
                </app>
            </xsl:when>
            <xsl:when test="./node()[1][self::tei:orig]
                or (./node()[1][self::text()[normalize-space()='']] and ./node()[2][self::tei:orig])">
                <xsl:choose>
                    <xsl:when test="starts-with(normalize-space((./tei:orig/following-sibling::text())[1]), 'vermutet')">
                        <note type="crit_app">
                            <orig><xsl:value-of select="normalize-space(./tei:orig)"/></orig>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="normalize-space(./tei:orig/following-sibling::text())"/>
                        </note>
                    </xsl:when>
                    <xsl:otherwise>
                        <app>
                            <lem wit="#A"/>
                            <xsl:apply-templates select="./tei:orig" />
                        </app>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

	
	<xsl:template match="tei:note[@type='crit_app' and preceding-sibling::node()[1][self::text()]]" />
	
	<xsl:template match="tei:orig">
		<xsl:choose>
		    <xsl:when test="normalize-space() = '.' and normalize-space(following-sibling::text()) = ''"/>
			<xsl:when test="following-sibling::node()[self::text()]">
			    <xsl:variable name="myId" select="generate-id()"/>
			    <xsl:variable name="val" select="normalize-space(string-join(following-sibling::node()[not(self::tei:orig
			    	or self::tei:note)
			            and generate-id(preceding-sibling::tei:orig[1]) = $myId]))"/>
				<rdg>
				    <xsl:attribute name="wit">
				        <xsl:variable name="wits">
				            <xsl:for-each select="tokenize($val, ',')">
<!--				                <xsl:if test="string-length(normalize-space()) &lt; 5">-->
    				                <xsl:value-of
    				                    select="'#'||normalize-space(wdb:substring-before(wdb:substring-before(., ';'), '.'))||' '"/>
				                <!--</xsl:if>-->
				            </xsl:for-each>
				        </xsl:variable>
				        <xsl:value-of select="normalize-space(wdb:substring-before-if-ends($wits, ';'))"/>
				    </xsl:attribute>
					<xsl:value-of select="normalize-space()"/>
				    <!--<xsl:for-each select="tokenize($val, ',')">
				    	<xsl:if test="string-length(normalize-space()) &gt; 4">
				            <note type="comment">
				                <xsl:value-of select="normalize-space(wdb:substring-before(., ';'))"/>
				            </note>
				        </xsl:if>
				    </xsl:for-each>-->
					<xsl:sequence select="following-sibling::*[1][self::tei:note]"/>
				</rdg>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
				<orig><xsl:value-of select="normalize-space()"/></orig>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:note[@type='comment']"/>
	
	<xsl:template match="text()[preceding-sibling::*[1][self::tei:anchor] and following-sibling::*[1][self::tei:anchor]
		and following-sibling::tei:span]">
		<xsl:variable name="span" select="following-sibling::tei:span[1]"/>
		
		<xsl:choose>
			<!--<xsl:when test="starts-with($note, 'folgt')">
				<xsl:variable name="wit" select="normalize-space($note/tei:orig/following-sibling::text())"/>
				<xsl:variable name="val" select="normalize-space($note/tei:orig)"/>
				<xsl:value-of select="$last"/>
				<add wit="{'#'||$wit}">
					<xsl:value-of select="$val"/>
				</add>
			</xsl:when>
			<!-\- Phrasen in 128 -\->
			<xsl:when
				test="matches($note/text()[1], '[vV]o[mn] Editor verbessert (für|aus)')">
				<!-\- ('vom Editor verbessert für', 'vom Editor verbessert aus', 'von Editor verbessert aus') -\->
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
			<xsl:when test="$note/node()[1][self::text()[ends-with(., ';')]]">
				<!-\- TODO später für mehrere rdg anpassen -\->
				<xsl:variable name="textB" select="normalize-space($note/tei:orig[1]/following-sibling::node())"/>
				<xsl:variable name="witA">
					<xsl:value-of select="wdb:substring-before-if-ends($note/text()[1], ';')"/>
				</xsl:variable>
				<xsl:variable name="witB">
					<xsl:value-of select="wdb:substring-before($textB, ',')"/>
				</xsl:variable>
				<app>
					<lem wit="#{$witA}"><xsl:value-of select="$last"/></lem>
					<xsl:choose>
						<xsl:when test="contains($textB, ',')">
							<rdg wit="#{$witB}">
								<xsl:value-of select="normalize-space($note/tei:orig[1])"/>
								<note type="comment"><xsl:value-of select="normalize-space(substring-after($textB, ','))"/></note>
							</rdg>
						</xsl:when>
						<xsl:otherwise>
							<rdg wit="#{$witB}"><xsl:value-of select="normalize-space($note/tei:orig[1])"/></rdg>
						</xsl:otherwise>
					</xsl:choose>
				</app>
			</xsl:when>-->
			<xsl:when test="$span/node()[1][self::tei:orig]">
				<app>
					<lem wit="#A">
						<xsl:analyze-string select="." regex="(\$)">
							<xsl:matching-substring><lb/></xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:value-of select="."/>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
					</lem>
					<xsl:apply-templates select="$span/tei:orig" />
				</app>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="preceding-sibling::tei:anchor[1]" />
				<xsl:value-of select="."/>
				<xsl:sequence select="following-sibling::tei:anchor[1]" />
				<xsl:sequence select="$span"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:span[preceding-sibling::*[2][self::tei:anchor]]" />
	<xsl:template match="tei:anchor[following-sibling::*[1][self::tei:anchor]]" />
	<xsl:template match="tei:anchor[preceding-sibling::*[1][self::tei:anchor]]" />
	
	<xsl:template match="text()[following-sibling::node()[1][self::tei:ex]]">
		<xsl:variable name="first" select="wdb:substring-before-last(., ' ')"/>
		<xsl:variable name="before" select="wdb:substring-after-last(., ' ')"/>
		<xsl:variable name="ex" select="following-sibling::tei:ex[1]"/>
		
		<xsl:value-of select="$first"/>
		<xsl:if test="string-length($first) &gt; 0">
			<xsl:text> </xsl:text>
		</xsl:if>
		<expan>
			<xsl:value-of select="$before"/>
			<xsl:sequence select="$ex" />
		</expan>
	</xsl:template>
	<xsl:template match="tei:ex" />
	
	<xsl:template match="@* | * | comment()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
