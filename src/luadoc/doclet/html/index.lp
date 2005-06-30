<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="http://www.keplerproject.org/doc.css" type="text/css" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>

<body>
<div id="container">

<div id="product">
	<div id="product_logo"><a href="http://www.keplerproject.org/luadoc"></a></div>
	<div id="product_name"><big><b></b></big></div>
	<div id="product_description"></div>
</div> <!-- id="product" -->

<div id="main">

<div id="navigation">
<h1>LuaDoc</h1>
	<ul>
		<li><a href="index.html">Index</a></li>
	</ul>

<h1>Modules</h1>
<ul>
<%for modulename, _ in doc.modules do%>
	<li><a href="<%=luadoc.doclet.html.html_module(modulename)%>"><%=modulename%></a></li>
<%end%>
</ul>

<h1>Files</h1>
<ul>
<%for i, file_doc in doc.files do%>
	<li><a href="<%=luadoc.doclet.html.html_file(file_doc.name)%>"><%=file_doc.name%></a></li>
<%end%>
</ul>


</div> <!-- id="navigation" -->

<div id="content">

<h2><a name="modules"></a>Modules</h2>
<ul>
<%for modulename, module_doc in doc.modules do%>
	<li><a href="<%=luadoc.doclet.html.html_module(modulename)%>"><%=modulename%></a></li>
<%end%>
</ul>

<h2><a name="files"></a>Files</h2>
<ul>
<%for i, file_doc in doc.files do%>
	<li><a href="<%=luadoc.doclet.html.html_file(file_doc.name)%>"><%=file_doc.name%></a></li>
<%end%>
</ul>


</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
