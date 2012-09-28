<dt><a name="<%=tab.name%>"></a><strong><%=tab.name%></strong></dt>
<dd><%=tab.description%>

<%if type(tab.field) == "table" and #tab.field > 0 then%>
<h3>Fields</h3>
<ul>
	<%for p = 1, #tab.field do%>
	<li>
	  <code><em><%=tab.field[p]%></em></code>: <%=tab.field[tab.field[p]] or ""%>
	</li>
	<%end%>
</ul>
<%end%>

<%if type(functions) == "table" then
    methods = {}
    for _, func_name in ipairs(functions) do
        if func_name:find( '^'..tab.name ) then
            table.insert(methods,func_name)
        end
    end%>    
   <%if #methods > 0 then%>
      <h3>Methods</h3>
      <ul>
        <%for _,m in ipairs(methods) do%>
        <li>
           <a href="#<%=m%>"><%=m%></a>
           <%=functions[m].summary %>
        </li>
        <%end%>
      </ul>
   <%end%>
<%end%>

</dd>
