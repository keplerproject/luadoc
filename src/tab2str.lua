-----------------------------------------------------------------------------
-- Tab2str: Table to String.
-- Produce a string with Lua code that can rebuild the given table.

-----------------------------------------------------------------------------
-- "Imprime" uma tabela em uma string.
-- Os campos são gerados na ordem que vierem da função next.
-- Os campos de valores numéricos não são separados dos campos "string"
-- e os outros tipos (userdata, função e tabela) são ignorados.
-- Se o parâmetro [[spacing]] for nulo, é considerado como se fosse [[""]].
-- caso contrário, seu valor é usado na indentação e um [[\n]] é acrescentado
-- entre os elementos.
-- Cada tabela listada ganha um número (indicado entre [[<]] e [[>]],
-- logo depois da [[{]] inicial) que serve para referência cruzada de
-- tabelas já listadas.  Neste caso, as tabelas já listadas são
-- representadas por [[{@]] seguido do número da tabela e [[}]].
-- @param t Número a ser "impresso".
-- @param spacing String de espaçamento entre elementos da tabela.
-- @param indent String com a indentação inicial (este parâmetro é utilizado
--	pela própria função para acumular a indentação de tabelas internas).
-- @return String com o resultado.

function tab2str (t, spacing, indent)
   local tipo = type (t)
   if tipo == "string" then
      return format ("%q",t)
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

function t2s (t, s, i)
   local old_table = _table_
   _table_ = { n = 0 }
   local result = tab2str (t, s, i)
   _table_ = old_table
   return result
end
