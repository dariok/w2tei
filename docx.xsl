<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:archive="http://expath.org/ns/archive"
  xmlns:file="http://expath.org/ns/file"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  <xsl:param name="filename" />
  <xsl:variable name="zip" select="file:read-binary($filename)" />
  
  <xsl:template match="/">
    <pkg:package
      xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">
      <!--<xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/document.xml'))" />
      <xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/comments.xml'))" />
      <xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/endnotes.xml'))" />
      <xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/footnotes.xml'))" />
      <xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/numbering.xml'))" />
      <xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/_rels/endnotes.xml.rels'))" />
      <xsl:sequence select="parse-xml(archive:extract-text($zip, 'word/_rels/document.xml.rels'))" />-->
      
      <xsl:variable name="parts" select="('word/document.xml', 'word/comments.xml', 'word/endnotes.xml',
        'word/footnotes.xml', 'word/numbering.xml', 'word/_rels/endnotes.xml.rels', 'word/_rels/document.xml.rels')" />
      <xsl:for-each select="$parts">
        <xsl:try>
          <pkg:part>
            <xsl:attribute name="pkg:name" select="'/' || ." />
            <pkg:xmlData>
              <xsl:sequence select="parse-xml(archive:extract-text($zip, .))" />
            </pkg:xmlData>
          </pkg:part>
          <xsl:catch />
        </xsl:try>
      </xsl:for-each>
    </pkg:package>
  </xsl:template>
</xsl:stylesheet>