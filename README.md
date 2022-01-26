# Word to TEI conversion - w2tei

A web service and collection of basic scripts to convert Word (XML or DOCX) to TEI.

**Incompatible change: As of 2020-11-23, paragraph style names (`w:pStyle/@w:val`) are recorded in `tei:p/@rendition`,
the definitions in `w:rPr` are kept in `tei:p/@style`.** 

**Incompatible change: As of 2021-09-06, heading levels and div structure are evaluated based upon the values given by
w:outlineLvl in a paragraph preset or paragraph style; empty lines or a style called “Heading \d” will not suffice.
Paragraphs not having a defined outline level are not recognized as headings.**

## How to use (docx to Flat XML)

### Oxygen
1. Import the scenarios into “transformation scenarios“
1. applying “DOCX → Flat OPC” to a **docx** file will create a (very basic) flat XML file

### web service
Build the package using `ant` on `build.xml`. You can upload docx files via a web form or by POSTing them to cnvert2.xql

### CLI
! The older `zip:xml-entry` function is available in Saxon ⩽ 9.5.1.1 while `file:read-binary` and `archive:extract-text`
require Saxon *PE or EE* ⩾ 9.6. If you do not have Saxon PE or EE, you currently have to use a different XSLT processor,
use oXygen (as it includes a recent version ofSaxon PE and EE), or use the web service implementation from within
eXist-DB or baseX as these implement the ExPath modules independently.

To convert a docx, apply `docx.xsl` to `word-empty.xml` (or any XML file) and pass the parameter `filename` with a path
to the docx to be converted.
  
## How to use (XML to TEI)
apply basic transformation scenario to docx or apply wt0.xsl and wt1.xsl to any flat Word XML
