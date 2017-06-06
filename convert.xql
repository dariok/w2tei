xquery version "3.0";

module namespace habq = "http://diglib.hab.de/ns/habq";

declare function habq:query() {
	<div id="content">
		<form enctype="multipart/form-data" method="post" action="ed000245/scripts/xquery/convert2.xql">
			<fieldset>
				<legend>Upload von TEI-P4-Dateien:</legend>
				<input type="file" name="file" style="width: 90%;"/>
				<input type="submit" value="Upload" style="float: right;"/>
			</fieldset>
		</form>
	</div>
};

declare function habq:getTask() {
	<h2>TEI-P4-Upload</h2>
};