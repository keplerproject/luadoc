<div class="function">
<dt><a name="<%=func.name%>"><strong><%=func.name%></strong></a><%=func.param_list%></dt>
<dd><b><%=func.resume or "(nil)"%></b><%=func.description or "(nil)"%></dd>

<em>Parameters</em>
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

<em>Return Value:</em>
<%=func.ret or ""%>
</div>
