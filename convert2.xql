xquery version "3.0";

declare namespace tei	= "http://www.tei-c.org/ns/1.0";
declare namespace mets	= "http://www.loc.gov/METS/";
declare namespace xlink	= "http://www.w3.org/1999/xlink";

import module namespace console = "http://exist-db.org/xquery/console";

let $filter := function ($path as xs:string, $data-type as xs:string, $param as item()*) as xs:boolean {
switch ($path)
  case "word/document.xml"
  case "word/comments.xml"
  case "word/endnotes.xml"
  case "word/footnotes.xml"
  case "word/numbering.xml"
  case "word/_rels/endnotes.xml.rels"
  case "word/_rels/document.xml.rels"
  case "word/_rels/footnotes.xml.rels"
  case "word/settings.xml"
  case "word/styles.xml"
    return true()
  default
    return false()
}

let $process := function ($path as xs:string, $data-type as xs:string, $data as item()?, $param as item()*) {
  <pkg:part pkg:name="/{$path}" xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">
    <pkg:xmlData>{
      $data
    }</pkg:xmlData>
  </pkg:part>
}
let $title := if (ends-with(request:get-uploaded-file-name('file'), '.odt'))
  then substring-before(request:get-uploaded-file-name('file'), '.odt')
  else substring-before(request:get-uploaded-file-name('file'), '.docx')

let $origFileData := string(request:get-uploaded-file-data('file'))
let $incoming := 
  <pkg:package xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage">{
    compression:unzip($origFileData, $filter, (), $process, ())
  }</pkg:package>
  
let $debug := xmldb:store('/db/apps/w2tei', 'word.xml', document{$incoming})

let $base := request:get-parameter('base', '')
let $add := request:get-parameter('xslt', 'none')

let $params :=
  <parameters/>
  
let $firstPass := if ($base = 'on')
  then
    let $t1 := transform:transform($incoming, doc('wt0.xsl'), $params)
    let $t2 := transform:transform($t1, doc('wt1.xsl'), $params)
    return transform:transform($t2, doc('wt2.xsl'), $params)
  else $incoming

let $attr := <attributes><attr name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverSilently" /></attributes>
let $result := if ($add = 'none')
  then $firstPass
  else 
    try { transform:transform($firstPass, doc($add), $params) }
    catch * { console:log('
      x: ' || $add || '
      p: ' || $params || '
      a: ' || $attr || '
      e: ' ||	$err:code || ': ' || $err:description || ' @ ' || $err:line-number ||':'||$err:column-number || '
      c: ' || $err:value || ' in ' || $err:module || '
      a: ' || $err:additional)
    }

let $create := if (not(xmldb:collection-available('/db/apps/w2tei/result')))
    then xmldb:create-collection('/db/apps/w2tei', 'result')
    else ()

return if (local-name($result) = 'TEI')
  then
  	let $filename := if ($result//tei:title[@type='short'])
  			then $result//tei:title[@type='short'] || '.xml'
  			else $title || '.xml'
  		
  		let $t1 := console:log("short: " || $filename)
  	return <p>{xmldb:store('/db/apps/w2tei/result', encode-for-uri($filename), $result)}</p>
  else
  	for $el in $result//tei:TEI
  		for $el in $result//tei:TEI
  		let $filename := if ($el//tei:title[@type='short'])
  			then $el//tei:title[@type='short'] || '.xml'
  			else $title || '.xml'
  		let $t1 := console:log("short: " || $filename)
  		return <p>{xmldb:store('/db/apps/w2tei/result', encode-for-uri($filename), $el)}</p>