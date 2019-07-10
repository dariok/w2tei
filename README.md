# Word to TEI conversion - w2tei

A web service and collection of basic scripts to convert Word (XML or DOCX) to TEI.

## How to use (docx to Flat XML)

### Oxygen
1. Import the scenarios into “transformation scenarios“
1. applying “DOCX → Flat OPC” to a **docx** file will create a (very basic) flat XML file

### web service
Build the package using `ant` on `build.xml`. You can upload docx files via a web form or by POSTing them to cnvert2.xql

### CLI
To convert a docx, apply `docx.xsl` to `word-empty.xml` (or any XML file) and pass the parameter `filename` with a full 
  URL to the docx to be converted.
  
## How to use (XML to TEI)
apply basic transformation scenario to docx or apply wt0.xsl and wt1.xsl to any flat Word XML