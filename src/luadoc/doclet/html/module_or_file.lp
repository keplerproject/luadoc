<%if about.description then%>
<p><%=about.description%></p>
<%end%>
<%if about.author then%>
<p><b><%= #about.author>1 and "Authors" or "Author" %>:</b>
<ul class="authors_list">
<%for _, author in ipairs(about.author) do%>
	<li class="name"><%= author %></li>
<%end%>
</ul>
</p>
<%end%>
<%if about.copyright then%>
<p>Copyright &copy;<%=about.copyright%></p>
<%end%>
<%if about.release then%>
<p><small><b>Release:</b> <%=about.release%></small></p>
<%end%>

<%
if #tables > 0 then%>
<h2>Tables</h2>
<table class="table_list">
<%for _, tab_name in ipairs(tables) do%>
	<tr>
	<td class="name" nowrap><a href="#<%=tab_name%>"><%=tab_name%></a></td>
	<td class="summary"><%=tables[tab_name].summary%></td>
	</tr>
<%end%>
</table>
<%end%>

<%
if #functions > 0 then

  fnames = { } 
  for _, func_name in ipairs(functions) do
      local is_method = false
      for _, tab_name in ipairs(tables) do
          if func_name:find('^'..tab_name..'[.:]') then
              is_method = true
          end
      end
      if not is_method then
          table.insert(fnames,func_name)
      end
  end

  if #fnames > 0 then%>
    <h2>Functions</h2>
    <table class="function_list">
    <%for _, func_name in ipairs(fnames) do
      local func_data = functions[func_name]%>
	<tr>
	<td class="name" nowrap><%=func_data.private and "local " or ""%><a href="#<%=func_name%>"><%=func_name%></a>&nbsp;(<%=table.concat(func_data.param, ", ")%>)</td>
	<td class="summary"><%=func_data.summary%></td>
	</tr>
    <%end%>
    </table>
  <%end%>
<%end%>

<%if #tables > 0 then%>
<h2><a name="tables"></a>Tables</h2>
<dl class="table">
<%for _, tab_name in ipairs(tables) do%>
  <%if file_doc then%>
    <%=luadoc.doclet.html.include("table.lp", { doc=doc, file_doc=file_doc, tab=tables[tab_name], functions=functions })%>
  <%else%>
    <%=luadoc.doclet.html.include("table.lp", { doc=doc, module_doc=module_doc, tab=tables[tab_name], functions=functions })%>
  <%end%>
<%end%>
</dl>
<%end%>


