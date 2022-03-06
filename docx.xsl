<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:archive="http://expath.org/ns/archive"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:file="http://expath.org/ns/file"
  xmlns:zip="http://expath.org/ns/zip"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:output indent="1" />
  <xsl:param name="filename" />
  
  <xsl:variable name="zip">
    <xsl:sequence select="file:read-binary($filename)" use-when="function-available('archive:extract-text')" />
    <xsl:value-of select="xs:anyURI($filename)" use-when="function-available('zip:xml-entry')" />
    </xsl:variable> 
  
  <xsl:template match="/">
    <xsl:if test="not(function-available('file:read-binary')) and not(function-available('zip:xml-entry'))">
      <xsl:message terminate="yes">!!
Neither file:read-binary nor zip:xml-entry functions are available. Word document
cannot be extracted with this XSLT processor. zip:xml-entry is available in Saxon
⩽ 9.5.1.1, file:read-binary requires Saxon PE or EE ⩾ 9.6.
</xsl:message>
    </xsl:if>
    <pkg:package
      xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">
      <xsl:variable name="parts" select="('word/document.xml', 'word/comments.xml', 'word/endnotes.xml',
        'word/footnotes.xml', 'word/numbering.xml', 'word/_rels/endnotes.xml.rels', 'word/_rels/document.xml.rels',
        'word/_rels/footnotes.xml.rels', 'word/settings.xml', 'word/styles.xml')" />
      <xsl:for-each select="$parts">
        <xsl:try>
          <pkg:part>
            <xsl:attribute name="pkg:name" select="'/' || ." />
            <pkg:xmlData>
              <xsl:choose>
                <xsl:when test="function-available('archive:extract-text')" use-when="function-available('archive:extract-text')">
                  <xsl:variable name="extracted" select="archive:extract-text($zip, .)" />
                  <xsl:variable name="parsable">
                    <xsl:choose>
                      <xsl:when test="$extracted => substring(1, 6) => contains('&lt;?xml')">
                        <xsl:value-of select="substring-after($extracted, '?&gt;')" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:sequence select="$extracted" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:sequence select="parse-xml($parsable)" />
                </xsl:when>
                <xsl:when test="function-available('zip:xml-entry')" use-when="function-available('zip:xml-entry')">
                  <xsl:sequence select="zip:xml-entry($zip, .)" />
                </xsl:when>
              </xsl:choose>
            </pkg:xmlData>
          </pkg:part>
          <xsl:catch />
        </xsl:try>
      </xsl:for-each>
    </pkg:package>
  </xsl:template>
</xsl:stylesheet>
