
-----------------------------------------------------------------------------
-- Tab2str: Table to String.
-- Produce a string with Lua code that can rebuild the given table.

module "luadoc.tab2str"

-----------------------------------------------------------------------------
-- "Imprime" uma tabela em uma string.
-- Os campos sao gerados na ordem que vierem da funcao next.
-- Os campos de valores numericos nao sao separados dos campos "string"
-- e os outros tipos (userdata, funcao e tabela) sao ignorados.
-- Se o parametro [[spacing]] for nulo, eh considerado como se fosse [[""]].
-- caso contrario, seu valor eh usado na indentacao e um [[\n]] eh acrescentado
-- entre os elementos.
-- Cada tabela listada ganha um numero (indicado entre [[<]] e [[>]],
-- logo depois da [[{]] inicial) que serve para referencia cruzada de
-- tabelas ja listadas.  Neste caso, as tabelas ja listadas sao
-- representadas por [[{@]] seguido do numero da tabela e [[}]].
-- @param t Numero a ser "impresso".
-- @param spacing String de espacamento entre elementos da tabela.
-- @param indent String com a indentacao inicial (este parametro eh utilizado
--pela propria funcao para acumular a indentacao de tabelas internas).
-- @return String com o resultado.

function tab2str (t, spacing, indent)
   local tipo = type (t)
   if tipo == "string" then
      return string.format ("%q",t)
   elseif tipo == "number" then
      return t
   elseif tipo == "table" then
      if _table_ then
         if _table_[t] then
            return "{@".._table_[t].."}"
         else
            _table_.n = _table_.n + 1
            _table_[t] = _table_.n
         end
      end
      local aux = ""
      local s = "{"
      if _table_ then
         s = s.."<".._table_[t]..">"
      end
      if not indent then
         indent = ""
      end
      if spacing then
         aux = indent .. spacing
      end
      local i,v
      i, v = next (t, nil)
      while i do
         if spacing then
            s = s .. '\n' .. aux
         end
         local t_i = type(i)
         if t_i == "number" or t_i == "string" then
            s = string.format ("%s[%s] = %s,", s, tab2str (i), tab2str (v, spacing, aux))
         end
         i, v = next (t, i)
      end
      if spacing then
         s = s .. '\n' .. indent
      end
      return s .. "}"
   else
      return "<"..tipo..">"
   end
end

-------------------------------------------------------------------------------

function t2s (t, s, i)
   local old_table = _table_
   _table_ = { n = 0 }
   local result = tab2str (t, s, i)
   _table_ = old_table
   return result
end
