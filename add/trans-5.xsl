<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:xstring="https://github.com/dariok/XStringUtils"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:include href="../string-pack.xsl" />
	
	<xsl:template match="tei:note[@type = 'crit_app'
		and not(preceding-sibling::tei:anchor and following-sibling::tei:anchor)]">
		<xsl:apply-templates select="." mode="eval" />
	</xsl:template>
	<xsl:template match="tei:note[@type = 'crit_app']" mode="eval">
		<xsl:variable name="text">
			<xsl:choose>
				<xsl:when test="preceding-sibling::node()[1][self::text()]">
					<xsl:value-of select="xstring:substring-after-last(preceding-sibling::text()[1], ' ')" />
				</xsl:when>
				<xsl:when test="preceding-sibling::tei:*[1]/node()[last()][self::text()]">
					<xsl:value-of select="xstring:substring-after-last(preceding-sibling::*[1]/text()[last()], ' ')" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="content">
			<xsl:call-template name="critapp">
				<xsl:with-param name="note" select="." />
				<xsl:with-param name="text" select="$text" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="preceding-sibling::node()[1][self::tei:*]">
				<xsl:variable name="pre" select="preceding-sibling::*[1]"/>
				<xsl:element name="{local-name($pre)}">
					<xsl:apply-templates select="$pre/@*" />
					<xsl:choose>
						<xsl:when test="$pre/node()[last()][self::text()]">
							<xsl:sequence select="$pre/node()[not(position() = last())]" />
							<xsl:value-of select="xstring:substring-before-last($pre/text()[last()], ' ')"/>
						</xsl:when>
					</xsl:choose>
					<xsl:sequence select="$content" />
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$content" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--<xsl:template match="text()[following-sibling::node()[1][self::tei:note[@type='crit_app']]]">
		<xsl:value-of select="xstring:substring-before-last(., ' ') || ' '" />
	</xsl:template>-->
	
	<xsl:template match="tei:anchor" />
	
	<xsl:template match="node()[(preceding-sibling::tei:anchor and following-sibling::tei:anchor)
		or following-sibling::node()[1][self::tei:note[@type='crit_app']]]">
		<xsl:variable name="pre" select="preceding-sibling::tei:anchor[1]/@xml:id"/>
		<xsl:choose>
			<xsl:when test="following-sibling::tei:anchor/@xml:id = $pre||'e'" />
			<xsl:when test="self::text() and following-sibling::*[1][self::tei:note]">
				<xsl:choose>
					<xsl:when test="contains(., ' ')">
						<xsl:value-of select="xstring:substring-before-last(., ' ') || ' '" />
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@type = 'footnote'">
				<xsl:sequence select="." />
			</xsl:when>
			<xsl:when test="self::tei:rs"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eval"/>
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
		
		<xsl:variable name="wits">
			<xsl:for-each-group select="$note/node()" group-starting-with="wdb:marker">
				<wdb:wit><xsl:apply-templates select="current-group()[not(self::wdb:marker)]" /></wdb:wit>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:variable name="cont">
			<xsl:apply-templates select="$wits">
				<xsl:with-param name="text" select="$text" />
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$cont/*[self::wdb:note]">
				<xsl:sequence select="$text" />
				<xsl:element name="{local-name($note)}">
					<xsl:attribute name="type" select="'crit_app'" />
					<xsl:apply-templates select="$note/node()" />
				</xsl:element>
			</xsl:when>
			<xsl:when test="count($cont/*) = count($cont/tei:add)">
				<xsl:sequence select="$cont" />
			</xsl:when>
			<xsl:when test="$cont/*[1][self::tei:rdg]">
				<app>
					<lem><xsl:value-of select="$text" /></lem>
					<xsl:for-each select="$cont/*">
						<xsl:choose>
							<xsl:when test="self::tei:rdg">
								<xsl:sequence select="."/>
							</xsl:when>
							<xsl:otherwise>
								<rdg wit="{@wit}">
									<xsl:copy>
										<xsl:apply-templates />
									</xsl:copy>
								</rdg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</app>
			</xsl:when>
			<xsl:when test="$cont/*[1][self::tei:lem]">
				<app>
					<xsl:sequence select="$cont/*[1]" />
					<xsl:for-each select="$cont/*[position() > 1]">
						<xsl:choose>
							<xsl:when test="self::tei:rdg">
								<xsl:sequence select="."/>
							</xsl:when>
							<xsl:otherwise>
								<rdg wit="{@wit}">
									<xsl:copy>
										<xsl:apply-templates select="node() | @place | @cause"/>
									</xsl:copy>
								</rdg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</app>
			</xsl:when>
			<xsl:when test="$cont/*[1][self::tei:del]">
				<xsl:sequence select="$text" />
				<xsl:sequence select="$cont" />
			</xsl:when>
			<!-- TODO ausbauen -->
			<xsl:otherwise>
				<xsl:sequence select="$cont" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="wdb:wit">
		<xsl:param name="text" />
		<xsl:choose>
			<xsl:when test="starts-with(normalize-space(), 'folgt')">
				<xsl:sequence select="$text" />
				
				<xsl:variable name="inter" select="normalize-space(tei:orig[last()]/following-sibling::text()[1])"/>
				<xsl:choose>
					<xsl:when test="not(tei:orig)">
						<wdb:note><xsl:sequence select="node()" /></wdb:note>
					</xsl:when>
					<xsl:when test="string-length($inter) &lt; 3">
						<xsl:variable name="wit">
							<xsl:for-each select="tokenize(string-join(tei:orig[last()]/following-sibling::node(), ''), ',')">
								<xsl:value-of select="'#' || normalize-space()"/>
								<xsl:if test="not(position() = last())">
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<add wit="{$wit}"><xsl:apply-templates select="tei:orig" mode="norm"/></add>
					</xsl:when>
					<xsl:when test="starts-with($inter, 'durchgestrichen')">
						<xsl:variable name="wit">
							<xsl:for-each select="tokenize(substring-after(string-join(tei:orig[last()]/following-sibling::node(), ''), 'chen '), ',')">
								<xsl:value-of select="'#' || normalize-space()"/>
								<xsl:if test="not(position() = last())">
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<add wit="{$wit}"><del><xsl:apply-templates select="tei:orig" mode="norm"/></del></add>
					</xsl:when>
					<xsl:otherwise>
						<wdb:note><xsl:sequence select="node()" /></wdb:note>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains(., 'hinzugefügt')">
				<xsl:variable name="tok" select="tokenize(normalize-space(substring-after(normalize-space(), 'fügt')))" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="matches(., '.+Gl')" />
							<xsl:otherwise>
								<xsl:value-of select="'#'||."/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				
				<add wit="{normalize-space($wit)}">
					<xsl:choose>
						<xsl:when test="contains(normalize-space(), 'am Rand')">
							<xsl:attribute name="place">margin</xsl:attribute>
						</xsl:when>
						<xsl:when test="ends-with(normalize-space(), 'AuRd-Gl')">
							<xsl:attribute name="place">AuRd-Gl</xsl:attribute>
						</xsl:when>
						<xsl:when test="ends-with(normalize-space(), 'InRd-Gl')">
							<xsl:attribute name="place">InRd-Gl</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains(normalize-space(), 'über der Zeile')">
							<xsl:attribute name="place">supralinear</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="tei:orig">
							<xsl:apply-templates select="tei:orig 
								| text()[preceding-sibling::*[1][self::tei:orig]
								and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$text"/>
						</xsl:otherwise>
					</xsl:choose>
				</add>
			</xsl:when>
			<xsl:when test="matches(., '[vV]o.\s+.ditor\s+verbessert')">
				<choice>
					<sic>
						<xsl:apply-templates select="tei:orig 
							| text()[preceding-sibling::*[1][self::tei:orig]
								and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
						<xsl:sequence select="tei:note" />
					</sic>
					<corr><xsl:sequence select="$text" /></corr>
				</choice>
			</xsl:when>
			<xsl:when test="matches(., '^\w* *\w*gestrichen')">
				<xsl:variable name="tok" select="tokenize(normalize-space(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], '')), ' ')" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="matches(., '.+Gl')" />
							<xsl:otherwise>
								<xsl:value-of select="'#'||normalize-space(xstring:substring-before(., ','))"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<del>
					<xsl:if test="normalize-space($wit) != ''">
						<xsl:attribute name="wit" select="normalize-space($wit)" />
					</xsl:if>
					<xsl:choose>
						<xsl:when test="matches(., '[dD]avor')">
							<xsl:attribute name="place" select="'before'" />
						</xsl:when>
						<xsl:when test="matches(., '[dD]anach')">
							<xsl:attribute name="place" select="'after'" />
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates select="tei:orig 
						| text()[preceding-sibling::*[1][self::tei:orig]
						and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
				</del>
			</xsl:when>
			<xsl:when test="tei:orig">
				<!--<xsl:variable name="wit">
					<xsl:for-each select="tokenize(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], ''), ',')">
						<xsl:value-of select="'#' || normalize-space()"/>
						<xsl:if test="not(position() = last())">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<rdg wit="{$wit}"><xsl:apply-templates select="tei:orig 
					| text()[preceding-sibling::*[1][self::tei:orig]
					and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
					<xsl:sequence select="tei:note" />
				</rdg>-->
				<xsl:variable name="tok" select="tokenize(normalize-space(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], '')), ' ')" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="matches(., '.+Gl')" />
							<xsl:otherwise>
								<xsl:value-of select="'#'||normalize-space(xstring:substring-before(., ','))"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				
				<rdg wit="{normalize-space($wit)}">
					<xsl:choose>
						<xsl:when test="starts-with(normalize-space(), 'hsl. korrigiert')">
							<xsl:attribute name="cause">manualCorrection</xsl:attribute>
						</xsl:when>
						<xsl:when test="starts-with(normalize-space(), 'korrigiert')">
							<xsl:attribute name="cause">correction</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="contains(normalize-space(), 'am Rand')">
							<xsl:attribute name="place">margin</xsl:attribute>
						</xsl:when>
						<xsl:when test="ends-with(normalize-space(), 'AuRd-Gl')">
							<xsl:attribute name="place">AuRd-Gl</xsl:attribute>
						</xsl:when>
						<xsl:when test="ends-with(normalize-space(), 'InRd-Gl')">
							<xsl:attribute name="place">InRd-Gl</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="tei:orig">
							<xsl:apply-templates select="tei:orig 
								| text()[preceding-sibling::*[1][self::tei:orig]
								and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$text"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="tei:note" />
				</rdg>
			</xsl:when>
			<xsl:when test="starts-with(normalize-space(), 'fehlt')">
				<xsl:variable name="wit">
					<xsl:for-each select="tokenize(normalize-space(), ' ')">
						<xsl:if test="position() > 1">
							<xsl:value-of select="'#' || normalize-space()"/>
							<xsl:if test="not(position() = last())">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<rdg wit="{$wit}" />
			</xsl:when>
			<xsl:when test="(string-length(normalize-space(text()[1])) &lt; 3
				or contains(text()[1], ',')
				or tei:hi[@rend='sub'])
				and not(tei:*[last()]/following-sibling::text()[normalize-space() != ''])">
				<xsl:variable name="wit">
					<xsl:for-each select="tokenize(normalize-space(), ',')">
						<xsl:value-of select="'#'||."/>
					</xsl:for-each>
				</xsl:variable>
				<lem wit="{$wit}"><xsl:sequence select="$text" /></lem>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>XXX</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:orig" mode="norm">
		<xsl:choose>
			<xsl:when test="count(node()) = 1 and text()">
				<xsl:value-of select="normalize-space()"/>
			</xsl:when>
			<xsl:when test="node()[1][self::text()][starts-with(., ' ')]">
				<xsl:value-of select="normalize-space(text()[1])"/>
			</xsl:when>
			<xsl:otherwise><xsl:sequence select="node()[1]" /></xsl:otherwise>
		</xsl:choose>
		<xsl:sequence select="node()[preceding-sibling::node() and following-sibling::node()[1]]" />
		<xsl:choose>
			<xsl:when test="count(node()) > 1 and node()[last()][self::text()][ends-with(., ' ')]">
				<xsl:value-of select="normalize-space(text()[last()])"/>
			</xsl:when>
			<xsl:when test="count(node()) = 1" />
			<xsl:otherwise><xsl:sequence select="node()[last()]"></xsl:sequence></xsl:otherwise>
		</xsl:choose>
		<xsl:if test="following-sibling::*[1][self::tei:orig]">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="wdb:marker">
		<xsl:text>; </xsl:text>
	</xsl:template>
	<xsl:template match="wdb:note">
		<xsl:apply-templates />
	</xsl:template>
	
	<!--<xsl:template match="text()[following-sibling::node()[1][self::tei:note[@type = 'crit_app']]]">
		<xsl:variable name="last" select="tokenize(., ' ')[last()]"/>
		<xsl:variable name="front" select="xstring:substring-before-last(., ' ')"/>
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
				<xsl:variable name="wit" select="normalize-space(($note/tei:orig/following-sibling::text())[1])"/>
				<xsl:variable name="val" select="normalize-space($note/tei:orig[1])"/>
				<xsl:value-of select="$last"/>
				<add wit="{'#'||$wit}">
					<xsl:value-of select="$val"/>
				</add>
			</xsl:when>
			<!-\- Phrasen in 128 -\->
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
					<xsl:value-of select="normalize-space($note/tei:orig[1])"/>
				</del>
			</xsl:when>
			<xsl:when test="$note/node()[1][self::text()[ends-with(., ';')]]">
				<!-\-<xsl:variable name="witA">
					<xsl:value-of select="xstring:substring-before-if-ends($note/text()[1], ';')"/>
				</xsl:variable>-\->
				<xsl:variable name="witA">
					<xsl:variable name="wits">
						<xsl:for-each select="tokenize(xstring:substring-before-if-ends($note/text()[1], ';'), ',')">
							<xsl:if test="string-length(.) &lt; 5">
								<xsl:value-of
									select="'#'||normalize-space(xstring:substring-before(xstring:substring-before(., ';'), '.'))||' '"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="normalize-space(xstring:substring-before-if-ends($wits, ';'))"/>
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
							<orig><xsl:value-of select="normalize-space($note/tei:orig[1])"/></orig>
							<xsl:text> </xsl:text>
							<xsl:value-of select="normalize-space($note/tei:orig/following-sibling::text()[1])"/>
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
            <!-\- Phrasen in 128 -\->
            <!-\-<xsl:when
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
            </xsl:when>-\->
            <xsl:when test="./text()[1][normalize-space() = 'Danach gestrichen']">
                <del>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="normalize-space(./tei:orig)"/>
                </del>
            </xsl:when>
            <xsl:when test="./node()[1][self::text()[ends-with(., ';')]]">
            	<xsl:variable name="witA">
            		<xsl:variable name="wits">
            			<xsl:for-each select="tokenize(xstring:substring-before-if-ends(text()[1], ';'), ',')">
            				<xsl:if test="string-length(.) &lt; 5">
            					<xsl:value-of
            						select="'#'||normalize-space(xstring:substring-before(xstring:substring-before(., ';'), '.'))||' '"/>
            				</xsl:if>
            			</xsl:for-each>
            		</xsl:variable>
            		<xsl:value-of select="normalize-space(xstring:substring-before-if-ends($wits, ';'))"/>
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
					<xsl:variable name="vals" select="tokenize($val, ' ')" />
					<xsl:if test="count($vals[string-length() &lt; 5]) &gt; 0">
				    <xsl:attribute name="wit">
				        <xsl:variable name="wits">
				        	<xsl:for-each select="$vals[string-length() &lt; 5]">
				                <xsl:if test="string-length(normalize-space()) &lt; 5">
    				                <xsl:value-of
    				                    select="'#'||normalize-space(xstring:substring-before(translate(., ',;', ''), '.'))||' '"/>
				                </xsl:if>
				            </xsl:for-each>
				        </xsl:variable>
				        <xsl:value-of select="normalize-space(xstring:substring-before-if-ends($wits, ';'))"/>
				    </xsl:attribute>
					</xsl:if>
					<xsl:if test="count($vals[string-length() &gt; 5]) &gt; 0">
						<xsl:attribute name="rend">
							<xsl:for-each select="$vals[string-length() &gt; 5]">
								<xsl:value-of select="normalize-space(xstring:substring-before-if-ends(., ';'))"/>
								<xsl:if test="not(position() = last())"><xsl:text> </xsl:text></xsl:if>
							</xsl:for-each>
						</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="normalize-space() = '@'" />
						<xsl:otherwise><xsl:value-of select="normalize-space()"/></xsl:otherwise>
					</xsl:choose>
				    <!-\-<xsl:for-each select="tokenize($val, ',')">
				    	<xsl:if test="string-length(normalize-space()) &gt; 4">
				            <note type="comment">
				                <xsl:value-of select="normalize-space(xstring:substring-before(., ';'))"/>
				            </note>
				        </xsl:if>
				    </xsl:for-each>-\->
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
	
	<xsl:template match="text()[preceding-sibling::*[1][self::tei:anchor] and following-sibling::*[not(self::tei:w)][1][self::tei:anchor]
		and following-sibling::tei:span]">
		<xsl:variable name="span" select="following-sibling::tei:span[1]"/>
		
		<xsl:choose>
			<!-\-<xsl:when test="starts-with($note, 'folgt')">
				<xsl:variable name="wit" select="normalize-space($note/tei:orig/following-sibling::text())"/>
				<xsl:variable name="val" select="normalize-space($note/tei:orig)"/>
				<xsl:value-of select="$last"/>
				<add wit="{'#'||$wit}">
					<xsl:value-of select="$val"/>
				</add>
			</xsl:when>
			<!-\\- Phrasen in 128 -\\->
			<xsl:when
				test="matches($note/text()[1], '[vV]o[mn] Editor verbessert (für|aus)')">
				<!-\\- ('vom Editor verbessert für', 'vom Editor verbessert aus', 'von Editor verbessert aus') -\\->
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
				<!-\\- TODO später für mehrere rdg anpassen -\\->
				<xsl:variable name="textB" select="normalize-space($note/tei:orig[1]/following-sibling::node())"/>
				<xsl:variable name="witA">
					<xsl:value-of select="xstring:substring-before-if-ends($note/text()[1], ';')"/>
				</xsl:variable>
				<xsl:variable name="witB">
					<xsl:value-of select="xstring:substring-before($textB, ',')"/>
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
			</xsl:when>-\->
			<xsl:when test="$span/node()[not(normalize-space() = '')][1][self::tei:orig]">
				<app>
					<lem wit="#A">
						<xsl:analyze-string select="." regex="(\$)">
							<xsl:matching-substring><lb/></xsl:matching-substring>
							<xsl:non-matching-substring>
								<xsl:value-of select="."/>
							</xsl:non-matching-substring>
						</xsl:analyze-string>
						<xsl:sequence select="following-sibling::node()[1][self::tei:w]" />
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
	<xsl:template match="tei:span[preceding-sibling::*[2][self::tei:anchor]
		or (preceding-sibling::*[2][self::tei:w] and preceding-sibling::*[3][self::tei:anchor])]" />
	<xsl:template match="tei:span">
		<span>
			<xsl:apply-templates select="@*" />
			<xsl:choose>
				<xsl:when test="tei:orig"><xsl:apply-templates select="node()[not(preceding-sibling::tei:orig)] | tei:orig"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates /></xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>
	
	<xsl:template match="tei:anchor[following-sibling::*[1][self::tei:anchor]
		or (following-sibling::*[1][self::tei:w] and following-sibling::*[2][self::tei:anchor])]" />
	<xsl:template match="tei:anchor[preceding-sibling::*[1][self::tei:anchor]
		or (preceding-sibling::*[1][self::tei:w] and preceding-sibling::*[2][self::tei:anchor])]" />
	<xsl:template match="tei:w[preceding-sibling::*[1][self::tei:anchor]
		and following-sibling::*[1][self::tei:anchor]]" />-->
	
	<xsl:template match="tei:note[@type = 'footnote']/tei:hi[contains(@style, 'italic')]">
		<term type="term"><xsl:apply-templates /></term>
	</xsl:template>
	
	<xsl:template match="text()" mode="norm">
		<xsl:choose>
			<xsl:when test="normalize-space() = ''"><xsl:text> </xsl:text></xsl:when>
			<xsl:otherwise><xsl:value-of select="normalize-space()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="@* | node()">
		<xsl:copy><xsl:apply-templates select="@* | node()" /></xsl:copy>
	</xsl:template>
</xsl:stylesheet>