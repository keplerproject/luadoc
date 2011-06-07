<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Luadocs for <%= file_doc.name %></title>
    <link rel="stylesheet" href="<%=luadoc.doclet.html.link('luadoc.css', 'files/'..file_doc.name)%>" type="text/css" />
	<!--meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/-->
</head>

<body>
<div id="container">

<div id="product">
	<div id="product_logo"></div>
	<div id="product_name"><big><b></b></big></div>
	<div id="product_description"></div>
</div> <!-- id="product" -->

<div id="main">

<div id="navigation">
<%=luadoc.doclet.html.include("menu.lp", { doc=doc, file_doc=file_doc })%>

</div> <!-- id="navigation" -->

<div id="content">

<h1>File <code><%=file_doc.name%></code></h1>

<%=luadoc.doclet.html.include("module_or_file.lp", { 
    about=file_doc,
    functions=file_doc.functions, file_doc=file_doc, tables=file_doc.tables 
})%>

<%if #file_doc.functions > 0 then%>
<h2><a name="functions"></a>Functions</h2>
<dl class="function">
<%for _, func_name in ipairs(file_doc.functions) do%>
<%=luadoc.doclet.html.include("function.lp", { doc=doc, file_doc=file_doc, func=file_doc.functions[func_name] })%>
<%end%>
</dl>
<%end%>

</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->
</body>
</html>
