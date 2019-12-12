<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:archive="http://expath.org/ns/archive"
  xmlns:file="http://expath.org/ns/file"
  xmlns:zip="http://expath.org/ns/zip"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  <xsl:param name="filename" />
  
  <xsl:variable name="zip">
    <xsl:choose>
      <xsl:when test="function-available('archive:extract-text')">
        <xsl:sequence select="file:read-binary($filename)" />
      </xsl:when>
      <xsl:when test="function-available('zip:xml-entry')">
        <xsl:value-of select="xs:anyURI($filename)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable> 
  
  <xsl:template match="/">
    <pkg:package
      xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">
      <xsl:variable name="parts" select="('word/document.xml', 'word/comments.xml', 'word/endnotes.xml',
        'word/footnotes.xml', 'word/numbering.xml', 'word/_rels/endnotes.xml.rels', 'word/_rels/document.xml.rels',
        'word/_rels/footnotes.xml.rels')" />
      <xsl:for-each select="$parts">
        <xsl:try>
          <pkg:part>
            <xsl:attribute name="pkg:name" select="'/' || ." />
            <pkg:xmlData>
              <xsl:sequence select="parse-xml(archive:extract-text($zip, .))" use-when="function-available('archive:extract-text')"/>
              <xsl:sequence select="zip:xml-entry($zip, .)" use-when="function-available('zip:xml-entry')"/>
            </pkg:xmlData>
          </pkg:part>
          <xsl:catch />
        </xsl:try>
      </xsl:for-each>
    </pkg:package>
  </xsl:template>
</xsl:stylesheet>