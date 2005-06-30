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
	<div id="product_logo"></a></div>
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
<%for i, d in doc.files do
	if d.name == file_doc.filepath then%>
	<li><strong><%=d.name%></strong></li>
	<%else%>
	<li><a href="<%=luadoc.doclet.html.html_file(d.name)%>"><%=d.name%></a></li>
<%	end
end%>
</ul>

</div> <!-- id="navigation" -->

<div id="content">

<h1>File <code><%=tostring(file_doc.filepath)%></code></h1>

<h2><a name="functions"></a>Functions</h2>
<dl>
<%
for i, func in ipairs(file_doc) do
    if (type(func) == "table") and (func.class == "function") then
%>
	<dt><a href="#<%=func.name%>"><%=func.name%></a>&nbsp;(<%=table.concat(func.param, ", ")%>)</dt>
	<dd><%=func.resume or ""%></dd>
	<br>
<%
    end
end
%>
</dl>

<h2><a name="functions"></a>Functions</h2>
<dl>
<%
for i, func in ipairs(file_doc) do
    if (type(func) == "table") and (func.class == "function") then
%>
<%=lp.include("luadoc/doclet/html/function.lp", { io=io, table=table, type=type, func=func })%>
<br>
<hr/>
<%
    end
end
%>
</dl>

</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
