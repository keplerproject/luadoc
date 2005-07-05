<div class="function">
<dt><a name="<%=func.name%>"></a><strong><%=func.name%></strong>&nbsp;(<%=table.concat(func.param, ", ")%>)</dt>
<dd><%=func.description or ""%></dd>

<%if type(func.param) == "table" and table.getn(func.param) > 0 then%>
<em>Parameters</em>
<ul>
	<%for p = 1, table.getn(func.param) do%>
	<li>
	  <%=func.param[p]%>: <%=func.param[func.param[p]] or ""%></li>
	</li>
	<%end%>
</ul>
<%end%>

<%if type(func.ret) == "string" then%>
<em>Return value:</em>
<%=func.ret%>
<br>
<%end%>

<%if type(func.see) == "table" and table.getn(func.see) > 0 then %>
<em>See also:</em>
	<%for i = 1, table.getn(func.see) do%>
	<a href="#<%=func.see[i]%>"><%=func.see[i]%></a><%if i < table.getn(func.see) then %>, <%end%>
	<%end%>
<br>
<%end%>

</div>
