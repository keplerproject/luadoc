<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title><%= module_doc.name %>: Module Index</title>
    <link rel="stylesheet" href="<%=luadoc.doclet.html.link('luadoc.css', 'modules/'..module_doc.name)%>" type="text/css" />
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
<%=luadoc.doclet.html.include("menu.lp", { doc=doc, module_doc=module_doc })%>

</div><!-- id="navigation" -->

<div id="content">

<h1>Module <code><%=module_doc.name%></code></h1>

<%=luadoc.doclet.html.include("module_or_file.lp", { 
    about=module_doc,
    functions=module_doc.functions, module_doc=module_doc, tables=module_doc.tables 
})%>

<%if #module_doc.functions > 0 then%>
<h2><a name="functions"></a>Functions</h2>
<dl class="function">
<%for _, func_name in ipairs(module_doc.functions) do%>
<%=luadoc.doclet.html.include("function.lp", { doc=doc, module_doc=module_doc, func=module_doc.functions[func_name] })%>
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
