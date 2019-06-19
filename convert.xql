xquery version "3.0";

declare option exist:serialize "method=html5 media-type=text/html";

<html>
	<head>
		<title>Text document to TEI conversion</title>
	</head>
	<body>
		<div id="content">
			<form enctype="multipart/form-data" method="post" action="convert2.xql">
				<fieldset>
					<legend>Upload Word (.docx) [or OO (.odt)]:</legend>
					<input type="file" name="file" style="width: 90%;"/>
					<input type="submit" value="Upload" style="float: right;"/>
					<br/>
					<label>select XSLT for processing: </label>
					<select name="xslt">
						<option selected="selected">none</option>
						{
							for $file in doc('adds.xml')//entry
								return
									<option value="{$file/@file}">{xs:string($file/@label)}</option>
						}
					</select>
					<br />
					<label>Apply base Word → TEI transformation? </label> <input name="base" type="checkbox" />
				</fieldset>
			</form>
		</div>
	</body>
</html>