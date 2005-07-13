<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="<%=luadoc.doclet.html.link('luadoc.css', 'files/'..file_doc.name)%>" type="text/css" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
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

<h2>Functions</h2>
<table class="function_list">
<%for func in file_doc.functions() do%>
	<tr>
	<td class="name" nowrap><a href="#<%=func.name%>"><%=func.name%></a>&nbsp;(<%=table.concat(func.param, ", ")%>)</td>
	<td class="summary"><%=func.summary%></td>
	</tr>
<%end%>
</table>

<h2><a name="functions"></a>Functions</h2>
<dl>
<%for func in file_doc.functions() do%>
<%=luadoc.doclet.html.include("function.lp", { doc=doc, file_doc=file_doc, func=func })%>
<br>
<hr/>
<%end%>
</dl>

</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
