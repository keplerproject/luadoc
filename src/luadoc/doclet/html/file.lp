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

<%if table.getn(file_doc.functions) > 0 then%>
<h2>Functions</h2>
<table class="function_list">
<%for _, func_name in ipairs(file_doc.functions) do%>
	<tr>
	<td class="name" nowrap><a href="#<%=func_name%>"><%=func_name%></a>&nbsp;(<%=table.concat(file_doc.functions[func_name].param, ", ")%>)</td>
	<td class="summary"><%=file_doc.functions[func_name].summary%></td>
	</tr>
<%end%>
</table>
<%end%>


<%if table.getn(file_doc.tables) > 0 then%>
<h2>Tables</h2>
<table class="table_list">
<%for _, tab_name in ipairs(file_doc.tables) do%>
	<tr>
	<td class="name" nowrap><a href="#<%=tab_name%>"><%=tab_name%></a></td>
	<td class="summary"><%=file_doc.tables[tab_name].summary%></td>
	</tr>
<%end%>
</table>
<%end%>


<br/>
<br/>



<%if table.getn(file_doc.functions) > 0 then%>
<h2><a name="functions"></a>Functions</h2>
<dl>
<%for _, func_name in ipairs(file_doc.functions) do%>
<%=luadoc.doclet.html.include("function.lp", { doc=doc, file_doc=file_doc, func=file_doc.functions[func_name] })%>
<br>
<hr/>
<%end%>
</dl>
<%end%>


<%if table.getn(file_doc.tables) > 0 then%>
<h2><a name="tables"></a>Tables</h2>
<dl>
<%for _, tab_name in ipairs(file_doc.tables) do%>
<%=luadoc.doclet.html.include("table.lp", { doc=doc, file_doc=file_doc, tab=file_doc.tables[tab_name] })%>
<br>
<hr/>
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
