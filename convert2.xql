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
	then <p>Keine Schreibberechtigung für Benutzer / No permission to write for user {$user}
		<span>{sm:get-group-members('ed000240')}</span></p>
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
			
			(: notwendige Werte aus XML holen :) 
			let $eeID := $xml/@xml:id
			let $nid := $xml/@n
			let $titel := $xml//tei:title[@type='short']
			
			(: ggfs. Collection erstellen :)
			let $nr := substring-before(substring-after($eeID, '240_'), '_')
			let $eeNr := if (string-length($nr) < 3)
				then 0 || $nr
				else if (not($nr castable as xs:integer))
				then 0 || $nr
				else $nr
			let $collName := ('/db/edoc/ed000240/texts/' || $eeNr)
			
			let $createColl := if (not(xmldb:collection-available($collName)))
				then xmldb:create-collection('/db/edoc/ed000240/texts/', $eeNr)
				else ()
			
			(: Datei speichern :)
			let $store := xmldb:store($collName, $eeNr || '_introduction.xml', $xml)
			let $location := substring-after($store, '240/')
			let $mets := doc('/db/edoc/ed000240/mets.xml')
			
			(: Eintragen in die METS :)
			(: 1. ggf. mets:file erstellen :)
			let $metsFile :=
				<mets:file ID="{$eeID}" MIMETYPE="application/xml">
					<mets:FLocat LOCTYPE="URL" xlink:href="{$location}"/>
				</mets:file>
			let $upd1 := if (not($mets//mets:file[@ID=$eeID]))
				then update insert $metsFile into $mets//mets:fileGrp[@ID='introduction']
				else ()
			
			(: 2. ggf. div für EE erstellen :)
			let $div1id := "edoc_ed000240_d" || $eeNr
			let $div1 := <mets:div TYPE="submenu" LABEL="{$titel}" ID="{$div1id}" ORDER="{$nid}"></mets:div>
			let $upd2 := if (not($mets//mets:div[@ID=$div1id]))
				then update insert $div1 into $mets//mets:div[@ID='edoc_ed000240']
				else (: nicht komplett überschreiben, da sonst Digitalisate wegfallen :)
					let $upd2a := update replace $mets//id($div1id)/@LABEL with $titel
					return update replace $mets//id($div1id)/@ORDER with $nid
				
			(: 3. ggf. div für Intro erstellen :)
			let $div2id := $div1id || "_introduction"
			let $div2 :=
				<mets:div TYPE="introduction" LABEL="Einleitung" ID="{$div2id}">
					<mets:fptr FILEID="{$eeID}" />
				</mets:div>
			let $upd2 := if (not($mets//mets:div[@ID=$div2id]))
				then update insert $div2 into $mets//mets:div[@ID=$div1id]
				else ()
			
			(: 4. ggf. in 2. structMap eintragen :)
			let $fptr := <mets:fptr FILEID="{$eeID}" />
			let $upd3 := if (not($mets//mets:div[@ID='ed000240_intros']/mets:fptr[@FILEID=$eeID]))
				then update insert $fptr into $mets//mets:div[@ID='ed000240_intros']
				else ()
			
			(: TODO prüfen, ob das reicht, oder wir die Texte überschreiben müssen :)
			let $target := concat('/edoc/view.html?id=', $eeID)
			return response:redirect-to($target)
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
			