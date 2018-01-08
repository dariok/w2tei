<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	exclude-result-prefixes="xs math"
	version="3.0">
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Nov 6, 2017</xd:p>
			<xd:p><xd:b>Author:</xd:b> dkampkaspar</xd:p>
			<xd:p>Provide some very handy functions for parsing Word-XML files</xd:p>
		</xd:desc>
	</xd:doc>
	
	<!-- Functions to check for a type -->
	<xd:doc >
		<xd:desc>
			<xd:p>Check whether a <xd:pre>w:p</xd:pre> has a certain 'type', i.e. a paragraph or character style of a given
				name is applied.</xd:p>
			<xd:p>The 2-param-version checks for paragraph styles; it is equivalent to calling <xd:ref name="wdb:is"
				type="function">wdb:is($context, $text, 'p')</xd:ref>.</xd:p>
		</xd:desc>
		<xd:param name="context">
			<xd:p>The context item to be evaluated</xd:p>
		</xd:param>
		<xd:param name="test">
			<xd:p>The string that is to be checked for.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p><xd:pre>true()</xd:pre> if a paragraph style of the given name is applied to the context element;
			<xd:pre>false()</xd:pre> otherwise.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:is" as="xs:boolean">
		<xsl:param name="context" as="item()*" />
		<xsl:param name="test" as="xs:string" />
		<xsl:value-of select="wdb:is($context, $test, 'p')"/>
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Check whether a <xd:pre>w:p</xd:pre> has a certain 'type', i.e. a paragraph or character style of a given
				name is applied.</xd:p>
		</xd:desc>
		<xd:param name="context">
			<xd:p>The context item to be evaluated</xd:p>
		</xd:param>
		<xd:param name="test">
			<xd:p>The string that is to be checked for.</xd:p>
		</xd:param>
		<xd:param name="pr">
			<xd:p>Either 'p' for a paragraph style or 'r' for a character ('run') style.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p><xd:pre>true()</xd:pre> if a paragraph style of the given name is applied to the context element;
				<xd:pre>false()</xd:pre> otherwise.</xd:p>
			<xd:p>Will also return <xd:pre>false()</xd:pre> if <xs:pre>$pr</xs:pre> is anything but 'p' or 'r'.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:is" as="xs:boolean">
		<xsl:param name="context" as="item()*" />
		<xsl:param name="test" as="xs:string" />
		<xsl:param name="pr" as="xs:string" />
		<xsl:variable name="val">
			<xsl:choose>
				<xsl:when test="not($pr = 'p' or $pr = 'r')">
					<xsl:message>Supplied value for parameter `pr` was neither 'p' nor 'r'</xsl:message>
					<xsl:sequence select="false()"/>
				</xsl:when>
				<xsl:when test="$pr = 'p'">
					<xsl:value-of select="$context//w:pStyle/@w:val"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$context//w:rStyle/@w:val"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="contains($val, $test)"/>
	</xsl:function>
	<!-- END Functions to check for a type -->
	
	<!-- Functions to deal with strings independently of Word 'runs' -->
	<xd:doc>
		<xd:desc>Return the full string</xd:desc>
		<xd:param name="context">
			<xd:p>The context item</xd:p>
		</xd:param>
		<xd:return>The string value of the Word element; i.e. the concatenated value of all <xd:pre>w:p//w:t</xd:pre>
			if the context element is <xd:pre>w:p</xd:pre> or the value of <xd:pre>w:r/w:t</xd:pre> if the context item is
			<xd:pre>w:r</xd:pre>.</xd:return>
	</xd:doc>
	<xsl:function name="wdb:string" as="xs:string">
		<xsl:param name="context" as="item()*" />
		<xsl:value-of select="string-join($context//w:t, '')"/>
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Check whether the element contains a given string</xd:p>
		</xd:desc>
		<xd:param name="context">
			<xd:p>The context element to be checked</xd:p>
		</xd:param>
		<xd:param name="test">
			<xd:p>The text to be searched for in the string value of <xd:pre>$context</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p><xd:pre>true()</xd:pre> if <xd:ref name="wdb:string">wdb:string</xd:ref> of <xd:pre>$context</xd:pre>
				<xd:pre>fn:contains()</xd:pre> the test string, <xd:pre>false()</xd:pre> otherwise.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:contains" as="xs:boolean">
		<xsl:param name="context" as="item()*"/>
		<xsl:param name="test" as="xs:string"/>
		<xsl:value-of select="contains(wdb:string($context), $test)"/>
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Check whether the element starts with a given string</xd:p>
		</xd:desc>
		<xd:param name="context">
			<xd:p>The context element to be checked</xd:p>
		</xd:param>
		<xd:param name="test">
			<xd:p>The text to be searched for in the string value of <xd:pre>$context</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p><xd:pre>true()</xd:pre> if <xd:ref name="wdb:string">wdb:string</xd:ref> of <xd:pre>$context</xd:pre>
				<xd:pre>fn:starts-with()</xd:pre> the test string, <xd:pre>false()</xd:pre> otherwise.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:starts" as="xs:boolean">
		<xsl:param name="context" as="item()"/>
		<xsl:param name="test" as="xs:string"/>
		<xsl:value-of select="starts-with(wdb:string($context), $test)"/>
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Check whether the element ends with a given string</xd:p>
		</xd:desc>
		<xd:param name="context">
			<xd:p>The context element to be checked</xd:p>
		</xd:param>
		<xd:param name="test">
			<xd:p>The text to be searched for in the string value of <xd:pre>$context</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p><xd:pre>true()</xd:pre> if <xd:ref name="wdb:string">wdb:string</xd:ref> of <xd:pre>$context</xd:pre>
				<xd:pre>fn:ends-with()</xd:pre> the test string, <xd:pre>false()</xd:pre> otherwise.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:ends" as="xs:boolean">
		<xsl:param name="context" as="item()"/>
		<xsl:param name="test" as="xs:string"/>
		<xsl:value-of select="ends-with(wdb:string($context), $test)"/>
	</xsl:function>
	<!-- END Functions to deal with strings independently of Word 'runs' -->
	
	<!-- Functions to select runs -->
	<xd:doc>
		<xd:desc>Check whether this is the first run in a possible sequence of runs (e.g. the first 'berschrift1'
		possibly immediately followed by one or more 'berschrift1'). May be used for paragraphs, too.</xd:desc>
		<xd:param name="context">The context item.</xd:param>
		<xd:param name="test">The test string for the paragraph or run style</xd:param>
		<xd:param name="pr">check in Paragraph or Run</xd:param>
		<xd:return><xd:pre>true()</xd:pre> if <xd:pre>wdb:is($xontext, $text, $pr)</xd:pre> evaluates as true and the
		immediately preceding sibling will check as false.</xd:return>
	</xd:doc>
	<xsl:function name="wdb:isFirst" as="xs:boolean">
		<xsl:param name="context" as="item()" />
		<xsl:param name="test" as="xs:string" />
		<xsl:param name="pr" as="xs:string" />
		<xsl:choose>
			<xsl:when test="$pr = 'p'">
				<xsl:sequence select="wdb:is($context, $test, $pr)
					and not(wdb:is($context/preceding-sibling::w:p[1], $test, $pr))" />
			</xsl:when>
			<xsl:when test="$pr = 'r'">
				<xsl:sequence select="wdb:is($context, $test, $pr)
					and not(wdb:is($context/preceding-sibling::w:r[1], $test, $pr))" />
			</xsl:when>
			<xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xd:doc>
		<xd:desc>Matches all those runs with a sequence of runs that immediately follow the first on, i.e. they are of the
			same type and are immediately preceded by w:r of the same type.</xd:desc>
		<xd:param name="context">The context item</xd:param>
		<xd:param name="me">The item that forms the start of the sequence</xd:param>
		<xd:param name="test">The type to test</xd:param>
		<xd:param name="pr">Whether this is a paragraph or a run style</xd:param>
	</xd:doc>
	<xsl:function name="wdb:followMe" as="xs:boolean">
		<xsl:param name="context" as="item()" />
		<xsl:param name="me" as="item()" />
		<xsl:param name="test" as="xs:string" />
		<xsl:param name="pr" as="xs:string" />
		<xsl:choose>
			<xsl:when test="$pr = 'p' or $pr = 'r'">
				<xsl:variable name="myID" select="generate-id($me)"/>
				<xsl:variable name="pre" select="$context/preceding-sibling::w:*[wdb:isFirst(., $test, $pr)][1]" />
				<xsl:sequence select="wdb:is($context, $test, $pr) and not(wdb:isFirst($context, $test, $pr))
					and $myID = generate-id($pre)" />
			</xsl:when>
			<xsl:otherwise><xsl:sequence select="false()" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<!-- END Functions to select runs -->
</xsl:stylesheet>