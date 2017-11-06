<?xml version="1.0" encoding="UTF-8"?>
<xsl:package xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:wdb="https://github.com/dariok/wdbplus"
	exclude-result-prefixes="xs math xd"
	version="3.0"
	name="wdb-strings">
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> Nov 6, 2017</xd:p>
			<xd:p><xd:b>Author:</xd:b> dkampkaspar</xd:p>
			<xd:p>Some advanced functions to deal with strings</xd:p>
		</xd:desc>
	</xd:doc>
	
	<!-- Functions to deal with strings more flexibly than the standard versions -->
	<xd:doc>
		<xd:desc>
			<xd:p>Returns the substring after a given test string</xd:p>
		</xd:desc>
		<xd:param name="s">
			<xd:p>The string to be checked</xd:p>
		</xd:param>
		<xd:param name="c">
			<xd:p>The text to be searched for in the string value of <xd:pre>$s</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p>If <xd:pre>$c</xd:pre> is found within the given string, the return value is the same as a call to 
				<xd:pre>fn:substring-after($s, $c)</xd:pre>; if <xd:pre>$c</xd:pre> cannot be found, <xd:pre>$s</xd:pre> is
				returned unaltered.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:substring-after" as="xs:string">
		<xsl:param name="s" as="xs:string"/>
		<xsl:param name="c" as="xs:string"/>
		<xsl:value-of
			select="if (contains($s, $c)) then substring-after($s, $c) else $s" />
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Returns the substring before a given test string</xd:p>
		</xd:desc>
		<xd:param name="s">
			<xd:p>The string to be checked</xd:p>
		</xd:param>
		<xd:param name="c">
			<xd:p>The text to be searched for in the string value of <xd:pre>$s</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p>If <xd:pre>$c</xd:pre> is found within the given string, the return value is the same as a call to 
				<xd:pre>fn:substring-before($s, $c)</xd:pre>; if <xd:pre>$c</xd:pre> cannot be found, <xd:pre>$s</xd:pre>
				is returned unaltered.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:substring-before" as="xs:string">
		<xsl:param name="s" as="xs:string"/>
		<xsl:param name="c" as="xs:string"/>
		<xsl:value-of
			select="if (contains($s, $c)) then substring-before($s, $c) else $s" />
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Returns the substring before a given test string if it ends with this test string.</xd:p>
		</xd:desc>
		<xd:param name="s">
			<xd:p>The string to be checked</xd:p>
		</xd:param>
		<xd:param name="c">
			<xd:p>The text to be searched for in the string value of <xd:pre>$s</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p>If <xd:pre>$c</xd:pre> is found within the given string, the portion of <xd:pre>$s</xd:pre> before this
				string (in final position) is returned; if <xd:pre>$c</xd:pre> cannot be found, <xd:pre>$s</xd:pre>
				is returned unaltered.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:substring-before-if-ends">
		<xsl:param name="s" as="xs:string"/>
		<xsl:param name="c" as="xs:string"/>
		<xsl:variable name="l" select="string-length($s)" />
		<xsl:value-of select="if(ends-with($s, $c)) then substring($s, 1, $l - 1) else $s"/>
	</xsl:function>
	
	<xd:doc>
		<xd:desc>
			<xd:p>Returns the substring after a given test string if it starts with this test string.</xd:p>
		</xd:desc>
		<xd:param name="s">
			<xd:p>The string to be checked</xd:p>
		</xd:param>
		<xd:param name="c">
			<xd:p>The text to be searched for in the string value of <xd:pre>$s</xd:pre>.</xd:p>
		</xd:param>
		<xd:return>
			<xd:p>If <xd:pre>$c</xd:pre> is found within the given string, the portion of <xd:pre>$s</xd:pre> after this
				string (in initial position) is returned; if <xd:pre>$c</xd:pre> cannot be found, or is not in the initial
				position, <xd:pre>$s</xd:pre> is returned unaltered.</xd:p>
		</xd:return>
	</xd:doc>
	<xsl:function name="wdb:substring-after-if-starts">
		<xsl:param name="s" />
		<xsl:param name="c" />
		<xsl:value-of select="if(starts-with($s, $c)) then substring-after($s, $c) else $s"/>
	</xsl:function>
</xsl:package>