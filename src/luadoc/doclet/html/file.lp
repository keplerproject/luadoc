<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>LuaDoc Reference</title>
    <link rel="stylesheet" href="http://www.keplerproject.org/doc.css" type="text/css" />
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
</head>

<body>
<div id="container">

<div id="product">
	<div id="product_logo"><a href="http://www.keplerproject.org/luadoc">
<!--		<img alt="LuaDoc logo" src="lua.png"/>-->
	</a></div>
	<div id="product_name"><big><b>LuaDoc</b></big></div>
	<div id="product_description">Documentation Generator Tool for the Lua language</div>
</div> <!-- id="product" -->

<div id="main">

<div id="navigation">
<h1>LuaDoc</h1>
	<ul>
		<li><a href="index.html">Index</a></li>
	</ul>
</div> <!-- id="navigation" -->

<div id="content">
<h2><a name="functions"></a>Functions</h2>

<dl>
<%
for i, func in doc do
    if (type(func) == "table") and (func.class == "function") then
%>
	<dt><a href="#<%=func.name%>"><%=func.name%></a>&nbsp;<%=func.param_list%></dt>
	<dd><%=tostring(func.resume)%></dd>
<%
    end
end
%>
</dl>

<h2><a name="functions"></a>Functions</h2>

<dl>
<%
for i, func in doc do
    if (type(func) == "table") and (func.class == "function") then
%>
<div class="function">
<dt><a name="<%=func.name%>"><b><%=func.name%></b></a><%=func.param_list%></dt>
<dd><b><%=func.resume or "(nil)"%></b><%=func.description or "(nil)"%></dd>

<i>Parameters</i>
<ul>
<%
if type(func.param) == "table" then
   for p = 1, table.getn(func.param) do%>
<li>
  <%=func.param[p]%>:
  <%=func.param[func.param[p]] or ""%></li>
</li>
<%
   end
end
%>
</ul>

<i>Return Value:</i>
<%=func.ret or ""%>
</div>
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
	<p><small>$Id: file.lp,v 1.1 2005/03/15 20:54:25 tuler Exp $</small></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->	
</body>
</html>
