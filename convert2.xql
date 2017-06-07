xquery version "3.0";

declare namespace tei	= "http://www.tei-c.org/ns/1.0";
declare namespace mets	= "http://www.loc.gov/METS/";
declare namespace xlink	= "http://www.w3.org/1999/xlink";

let $filter := function ($path as xs:string, $data-type as xs:string, $param as item()*) as xs:boolean {
    switch ($path)
        case "word/document.xml"
        case "word/comments.xml"
        case "word/endnotes.xml"
        case "word/footnotes.xml"
            return true()
        default
            return false()
}

let $entry-data := function ($path as xs:string, $data-type as xs:string, $data as item()?, $param as item()*) {
  $data
}

let $filename := if (request:get-uploaded-file-name('file'))
	then request:get-uploaded-file-name('file')
	else ''
	
let $user := request:get-attribute("wd.user")
return if (not(sm:get-group-members('ed000240') = $user) or $user = 'guest')
	then <p>Keine Schreibberechtigung für Benutzer / No permission to write for user {$user}</p>
	else if (request:is-multipart-content() and $filename != '')
		then
			let $origFileData := string(request:get-uploaded-file-data('file'))
			(: unzip erwartet base64Binary, die vom Upload direkt geliefert werden :)
			let $unpack := compression:unzip($origFileData, $filter, (), $entry-data, ())
			let $word := 
			<pack>{
			    for $item in $unpack
			        return $item}
		    </pack>
		    let $xslt := doc('../xslt/wtotei-intro.xsl')
		    
		    let $xml := transform:transform($word, $xslt, ())
            let $eeID := $xml/tei:TEI/@xml:id
            
(:(:			let $login := xmldb:login('/db/edoc/ed000245/texts', 'guest', 'adf'):):)
(:			(:let $store := try { xmldb:store('/db/edoc/ed000245/texts', $filename, $resultData) }:)
(:				catch * { 'Speicherfehler:\n' || $err:code || ': ' || $err:description || '\nDaten:\n\n' || $resultData }:):)
(:			let $store := xmldb:store('/db/edoc/ed000245/texts', $filename, $resultData):)
(:(:			let $user := xmldb:get-current-user():):)
(:			let $own := try { sm:chown($store, concat($user, ':ed000245')) }:)
(:				catch * { '' } (: XQuery nervt manchmal :):)
(:			let $perm := try { sm:chmod($store, 'rw-rw-r--') }:)
(:				catch * { '' }:)
(:			let $id := $resultData/@xml:id:)
(:			let $title := if (contains($resultData//tei:title[1], '::')):)
(:				then normalize-space(substring-before($resultData//tei:title[1], '::')):)
(:				else normalize-space($resultData//tei:title[1]):)
(:			let $location := substring-after($store, '245/'):)
(:			:)
(:			(: Daten in die METS einfügen :):)
(:			let $mets := doc('/db/edoc/ed000245/mets.xml'):)
(:			let $lastOrder := $mets//mets:div[@ORDER and position()=last()]/@ORDER:)
(:			let $order := format-number($lastOrder + 1, '000'):)
(:			let $metsFile :=:)
(:				<mets:file ID="{$id}" MIMETYPE="application/xml">:)
(:					<mets:FLocat LOCTYPE="URL" xlink:href="{$location}"/>:)
(:				</mets:file>:)
(:			let $metsDiv :=:)
(:				<mets:div LABEL="{$title}" ID="edoc_ed000245_{$order}" ORDER="{$order}">:)
(:					<mets:fptr FILEID="{$id}"/>:)
(:				</mets:div>:)
(:			let $upd1 := if (not($mets//mets:file[@ID=$id])):)
(:				then update insert $metsFile into $mets//mets:fileGrp[@ID='transcript']:)
(:				else ():)
(:			let $upd2 := if ($mets//mets:div[mets:fptr[@FILEID=$id]]):)
(:				then update replace $mets//mets:div[mets:fptr[@FILEID=$id]]/@LABEL with $title:)
(:				else update insert $metsDiv into $mets//mets:div[@ID='edoc_ed000245_dokumente']:)
(:			let $target := concat('/edoc/view.html?id=', $id):)
(:			return response:redirect-to($target):)
		else if ($filename = '')
		then
		    <div>
		        <h1>Problem beim Upload</h1>
		        <p>Es wurde keine Datei ausgewählt</p>
            </div>
        else
		    let $user := request:get-attribute("wd.user")
		    return
			<div>
				<h1>Problem beim Upload</h1>
				<ul>
				    <li>Benutzer (Att): {$user}</li>
				    <li>Benutzer (get): {xmldb:get-current-user()}</li>
				    <li>Gruppen: {sm:get-group-members('ed000245') = $user}</li>
				</ul>
			</div>
			