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
	<xsl:include href="../word-pack.xsl" />
	<xsl:include href="ref-qv.xsl" />
	
	<xsl:template match="tei:note[@type = 'crit_app'
		and not(preceding-sibling::tei:anchor[1][not(ends-with(@xml:id, 'e'))]
		and following-sibling::tei:anchor[1][ends-with(@xml:id, 'e')])]">
		<xsl:apply-templates select="." mode="eval" />
	</xsl:template>
	<xsl:template match="tei:note[@type = 'crit_app']" mode="eval">
		<xsl:variable name="text">
			<xsl:choose>
				<xsl:when test="preceding-sibling::node()[1][self::tei:w]">
					<xsl:sequence select="preceding-sibling::tei:w[1]/node()" />
				</xsl:when>
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
			<xsl:when test="preceding-sibling::node()[1][self::tei:note]">
				<note type="crit_app"><xsl:apply-templates select="node()" /></note>
			</xsl:when>
			<xsl:when test="preceding-sibling::node()[1][self::tei:*]">
				<xsl:variable name="pre" select="preceding-sibling::*[1]"/>
				<xsl:variable name="proc">
					<xsl:choose>
						<xsl:when test="$pre[self::tei:w]"/>
						<xsl:when test="$pre/node()[last()][self::text()]">
							<xsl:sequence select="$pre/node()[not(position() = last())]" />
							<xsl:value-of select="xstring:substring-before-last($pre/text()[last()], ' ')"/>
							<xsl:if test="count(tokenize($pre/text()[last()], ' ')) > 1">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
					<xsl:sequence select="$content" />
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$pre[self::tei:lb]">
						<xsl:sequence select="$pre" />
						<xsl:sequence select="$proc" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="{local-name($pre)}">
							<xsl:apply-templates select="$pre/@*" />
							<xsl:sequence select="$proc" />
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$content/tei:add[@wit and string-length() > 0] and not($content/tei:rdg)">
				<xsl:value-of select="$text"/>
				<app>
					<lem />
					<xsl:for-each select="$content/tei:add">
						<rdg>
							<xsl:choose>
								<xsl:when test="@place">
									<xsl:sequence select="@wit" />
									<add>
										<xsl:sequence select="@*[not(name() = 'wit')] | node()" />
									</add>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="@* | node()" />
								</xsl:otherwise>
							</xsl:choose>
						</rdg>
					</xsl:for-each>
				</app>
			</xsl:when>
			<xsl:when test="$content/tei:add[not(text() or tei:del)] and count($content) = 1">
				<add>
					<xsl:sequence select="$content/*[1]/@*" />
					<xsl:sequence select="$text" />
				</add>
			</xsl:when>
			<xsl:when test="$content/tei:add and count($content) = 1 and ends-with(preceding-sibling::node()[1], ' ')">
				<xsl:value-of select="$text"/>
				<xsl:sequence select="$content" />
			</xsl:when>
			<xsl:when test="$content/tei:del[not(text())]">
				<app>
					<lem>
						<xsl:sequence select="$text"/>
					</lem>
					<rdg>
						<xsl:sequence select="$content/tei:del/@wit" />
						<del>
							<xsl:sequence select="$content/tei:del/@place" />
							<xsl:sequence select="$text" />
						</del>
					</rdg>
				</app>
			</xsl:when>
			<xsl:when test="$content/tei:choice/tei:sic[@wit]">
				<app>
					<lem>
						<xsl:sequence select="$text" />
					</lem>
					<rdg wit="{$content/tei:choice/tei:sic/@wit}">
						<sic><xsl:sequence select="$content/tei:choice/tei:sic/node()" /></sic>
					</rdg>
				</app>
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
	<xsl:template match="tei:note[@type = 'footnote'
		and preceding-sibling::*[1][self::tei:anchor[ends-with(@xml:id, 'e')]]
		and following-sibling::*[1][self::tei:span]]" />
	
	<xsl:template match="tei:div">
		<div>
			<xsl:choose>
				<xsl:when test="tei:p[following-sibling::tei:head]">
					<xsl:for-each-group select="*"
						group-starting-with="tei:head[not(preceding-sibling::*[1][self::tei:head])]">
						<div>
							<xsl:apply-templates select="current-group()" />
						</div>
					</xsl:for-each-group>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="*" />
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<xsl:template match="node()[not(self::tei:span)][(
		preceding-sibling::tei:anchor[1][@type = 'crit_app' and not(ends-with(@xml:id, 'e'))]
		and following-sibling::tei:anchor[1][@type = 'crit_app' and ends-with(@xml:id, 'e')])
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
			<xsl:when test="self::tei:rs or self::tei:w"/>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="eval"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="tei:span">
		<xsl:variable name="text" select="id(substring-after(@from, '#'))/following-sibling::node()
			intersect id(substring-after(@to, '#'))/preceding-sibling::node()"/>
		<xsl:variable name="content">
			<xsl:call-template name="critapp">
				<xsl:with-param name="text" select="$text" />
				<xsl:with-param name="note" select="." />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="preceding-sibling::*[1][self::tei:note[@type = 'footnote']] and $content/*[1][self::tei:*]">
				<xsl:sequence select="$content" />
				<xsl:sequence select="preceding-sibling::*[1]" />
			</xsl:when>
			<xsl:when test="$content/*[last()][self::tei:span]">
				<anchor type="crit_app">
					<xsl:attribute name="xml:id" select="substring-after(@from, '#')" />
				</anchor>
				<xsl:sequence select="$content/node()[not(position() = last())]" />
				<anchor type="crit_app">
					<xsl:attribute name="xml:id" select="substring-after(@to, '#')" />
				</anchor>
				<xsl:sequence select="$content/tei:span" />
			</xsl:when>
			<xsl:when test="$content/*[1][self::tei:add[not(text())]] and count($content) = 1">
				<add>
					<xsl:sequence select="$content/tei:add/@*" />
					<xsl:sequence select="$text" ></xsl:sequence>
				</add>
			</xsl:when>
			<xsl:when test="$content/*[1][self::tei:*]">
				<xsl:sequence select="$content" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="id(substring-after(@from, '#'))" />
				<xsl:sequence select="preceding-sibling::node() intersect
					id(substring-after(@from, '#'))/following-sibling::node()" />
				<xsl:sequence select="$content" />
			</xsl:otherwise>
		</xsl:choose>
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
					<xsl:apply-templates select="@from |@to" />
					<xsl:apply-templates select="$note/node()" />
				</xsl:element>
			</xsl:when>
			<xsl:when test="$cont/tei:add[@place = 'margin' and not(text())]">
				<add>
					<xsl:sequence select="$cont/tei:add/@*" />
					<xsl:sequence select="$text" />
				</add>
			</xsl:when>
			<xsl:when test="count($cont/*) = count($cont/tei:add)">
				<xsl:sequence select="$cont" />
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
										<xsl:apply-templates select="node() | @place | @rend | @cause"/>
									</xsl:copy>
								</rdg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</app>
			</xsl:when>
			<xsl:when test="$cont/*[1][self::tei:del] and not($cont/tei:rdg)">
				<xsl:sequence select="$text" />
				<xsl:sequence select="$cont" />
			</xsl:when>
			<xsl:when test="$cont/tei:choice and $cont/tei:rdg">
				<app>
					<lem>
						<xsl:sequence select="$cont/tei:choice" />
					</lem>
					<xsl:for-each select="$cont/tei:*[not(self::tei:choice)]">
						<xsl:choose>
							<xsl:when test="self::tei:rdg">
								<xsl:sequence select="."/>
							</xsl:when>
							<xsl:otherwise>
								<rdg wit="{@wit}">
									<xsl:copy>
										<xsl:apply-templates select="node() | @place | @rend | @cause"/>
									</xsl:copy>
								</rdg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</app>
			</xsl:when>
			<xsl:when test="$cont/tei:rdg">
				<app>
					<lem><xsl:sequence select="$text" /></lem>
					<xsl:for-each select="$cont/*">
						<xsl:choose>
							<xsl:when test="self::tei:rdg">
								<xsl:sequence select="."/>
							</xsl:when>
							<xsl:otherwise>
								<rdg wit="{@wit}">
									<xsl:copy>
										<xsl:apply-templates select="node() | @place | @rend | @cause"/>
									</xsl:copy>
								</rdg>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</app>
			</xsl:when>
			<xsl:otherwise>
				<!--<xsl:sequence select="$text" />-->
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
					<xsl:when test="starts-with($inter, 'gestrichen') or starts-with($inter, 'durchgestrichen')
						or starts-with(substring-after(., 'folgt '), 'gestr') or starts-with(substring-after(., 'folgt '), 'durchgestr')">
						<xsl:variable name="wit">
							<xsl:for-each select="tokenize(substring-after(string-join(tei:orig[last()]/following-sibling::node(), ''), 'chen '), ',')">
								<xsl:value-of select="'#' || normalize-space()"/>
								<xsl:if test="not(position() = last())">
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<add>
							<xsl:if test="string-length($wit) > 0">
								<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
							</xsl:if>
							<del><xsl:apply-templates select="tei:orig" mode="norm"/></del>
						</add>
					</xsl:when>
					<xsl:when test="string-length($inter) &lt; 3">
						<xsl:variable name="wit">
							<xsl:for-each
								select="tokenize(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], ''), ',')">
								<xsl:value-of select="'#' || normalize-space()"/>
								<xsl:if test="not(position() = last())">
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<add>
							<xsl:if test="string-length($wit) > 0">
								<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
							</xsl:if>
							<xsl:apply-templates select="tei:orig" mode="norm"/>
							<xsl:apply-templates select="tei:note" />
						</add>
					</xsl:when>
					<xsl:otherwise>
						<wdb:note><xsl:sequence select="node()" /></wdb:note>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains(., 'hinzugefügt')
				and not(contains(., 'gestrichen'))
				and not(tei:orig[1]/following-sibling::node()[1][self::text()]
				and tei:orig/following-sibling::tei:orig)">
				<xsl:variable name="norm" select="normalize-space()" />
				<xsl:variable name="tok"
					select="tokenize(normalize-space(substring-after(string-join(node()[not(self::tei:note or
					self::tei:orig)], ''), 'fügt')), ' ')" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="string-length() > 5" />
							<xsl:when test="contains($norm, 'am Rand')">
								<xsl:if test="not(.='am' or .='Rand')">
									<xsl:value-of select="'#'||normalize-space(translate(., ',.', ''))"/>
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'#'||normalize-space(translate(., ',.', ''))"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<add>
					<xsl:if test="string-length($wit) > 0">
						<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
					</xsl:if>
					<xsl:choose>
						<xsl:when test="contains($norm, 'am Rand')">
							<xsl:attribute name="place">margin</xsl:attribute>
						</xsl:when>
						<xsl:when test="ends-with($norm, 'AuRd-Gl')">
							<xsl:attribute name="place">AuRd-Gl</xsl:attribute>
						</xsl:when>
						<xsl:when test="ends-with($norm, 'InRd-Gl')">
							<xsl:attribute name="place">InRd-Gl</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains($norm, 'über der Zeile')">
							<xsl:attribute name="place">supralinear</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains($norm, 'linksbündig')">
							<xsl:attribute name="place">left</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains($norm, 'zentriert')">
							<xsl:attribute name="place">centre</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains($norm, 'Korrekturverzeichnis')">
							<xsl:attribute name="place">corr</xsl:attribute>
						</xsl:when>
						<xsl:when test="contains($norm, 'handschriftlich')
							or contains($norm, 'hsl')">
							<xsl:attribute name="type">manual</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:apply-templates select="tei:orig 
						| text()[preceding-sibling::*[1][self::tei:orig]
						and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
					<xsl:if test="not(tei:orig)
						and preceding-sibling::wdb:wit[last()][not(tei:orig) and string-length(normalize-space()) > 0]">
						<xsl:value-of select="$text"/>
					</xsl:if>
				</add>
			</xsl:when>
			<xsl:when test="matches(., '[vV]o.\s+.ditor\s+verbessert')">
				<xsl:variable name="tok" select="tokenize(normalize-space(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], '')), ' ')" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="string-length() > 5" />
							<xsl:otherwise>
								<xsl:value-of select="'#'||normalize-space(translate(., ',.', ''))"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<choice>
					<sic>
						<xsl:if test="string-length($wit) > 0">
							<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
						</xsl:if>
						<xsl:apply-templates select="tei:orig 
							| text()[preceding-sibling::*[1][self::tei:orig]
								and following-sibling::*[1][self::tei:orig]]" mode="norm"/>
						<xsl:sequence select="tei:note" />
					</sic>
					<corr><xsl:sequence select="$text" /></corr>
				</choice>
			</xsl:when>
			<xsl:when test="matches(., '^\w* *\w*gestrichen')
				and tei:orig
				and not(contains(., 'über') or contains(., 'Rand') or contains(., 'Zeile')
				or contains(., 'hinzu'))">
				<xsl:variable name="tok" select="tokenize(normalize-space(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], '')), ' ')" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="string-length() > 5" />
							<xsl:otherwise>
								<xsl:value-of select="'#'||normalize-space(translate(., ',.', ''))"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				<del>
					<xsl:if test="string-length($wit) > 0">
						<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
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
			<xsl:when test="matches(., '^\w* *\w*gestrichen')
				and not(contains(., 'über') or contains(., 'Rand') or contains(., 'Zeile')
				or contains(., 'hinzu'))">
				<xsl:variable name="wit" select="tokenize(normalize-space(substring-after(., 'gestrichen')), ', ')"/>
				<del>
					<xsl:attribute name="wit">
						<xsl:for-each select="$wit">
							<xsl:value-of select="'#' || ."/>
							<xsl:if test="position() != last()">
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:attribute>
				</del>
			</xsl:when>
			<xsl:when test="count(tei:orig) = 1">
				<xsl:variable name="tok" select="tokenize(normalize-space(string-join(tei:orig[last()]/following-sibling::node()[not(self::tei:note)], '')), ' ')" />
				<xsl:variable name="wit">
					<xsl:for-each select="$tok">
						<xsl:choose>
							<xsl:when test="string-length() > 5" />
							<xsl:when test="matches(normalize-space(), '^\d')">
								<xsl:value-of select="'#ZZ'||normalize-space(translate(., ',.', ''))"/>
								<xsl:text> </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'#'||normalize-space(translate(., ',.', ''))"/>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$wit = ''
						or count(tokenize(normalize-space(string-join(tei:orig[1]/preceding-sibling::text(), '')), ' ')) > 3
						or (contains(., 'gestrichen') and contains(., 'hinzu'))">
						<wdb:note>
							<xsl:sequence select="node()" />
						</wdb:note>
					</xsl:when>
					<xsl:otherwise>
						<rdg>
							<xsl:if test="string-length($wit) > 0">
								<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
							</xsl:if>
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
									<xsl:attribute name="rend">margin</xsl:attribute>
								</xsl:when>
								<xsl:when test="ends-with(normalize-space(), 'AuRd-Gl')">
									<xsl:attribute name="rend">AuRd-Gl</xsl:attribute>
								</xsl:when>
								<xsl:when test="ends-with(normalize-space(), 'InRd-Gl')">
									<xsl:attribute name="rend">InRd-Gl</xsl:attribute>
								</xsl:when>
								<xsl:when test="contains(normalize-space(), 'über der Zeile')">
									<xsl:attribute name="rend">supralinear</xsl:attribute>
								</xsl:when>
								<xsl:when test="contains(normalize-space(), 'linksbündig')">
									<xsl:attribute name="rend">left</xsl:attribute>
								</xsl:when>
								<xsl:when test="contains(normalize-space(), 'zentriert')">
									<xsl:attribute name="rend">centre</xsl:attribute>
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
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="starts-with(normalize-space(), 'fehlt')">
				<xsl:variable name="wit">
					<xsl:for-each select="tokenize(normalize-space(translate(., ',.', '')), ' ')">
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
			<xsl:when test="((string-length(normalize-space(text()[1])) &lt; 3
				and normalize-space(text()[1]) != '')
				or contains(text()[1], ',')
				or tei:hi[@rend='sub'])
				and string-length(normalize-space(text()[1])) &lt; 10
				and not(tei:*[last()]/following-sibling::text()[normalize-space() != ''])
				and not(count(tei:orig) > 1)">
				<xsl:variable name="wit">
					<xsl:for-each select="tokenize(normalize-space(), ',')">
						<xsl:value-of select="'#'||normalize-space(translate(., ',.', '')) || ' '"/>
					</xsl:for-each>
				</xsl:variable>
				<lem>
					<xsl:if test="string-length($wit) > 0">
						<xsl:attribute name="wit" select="translate(normalize-space($wit), '–', '-')" />
					</xsl:if>
					<xsl:sequence select="$text" />
				</lem>
			</xsl:when>
			<xsl:otherwise>
				<!--<xsl:text>XXX</xsl:text>-->
				<wdb:note><xsl:sequence select="node()" /></wdb:note>
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