-----------------------------------------------------------------
-- General file comment.
-- Implement the substitution methods of source files.
-- $Id $

-----------------------------------------------------------------
-- LuaDoc version number.

LUADOC_VERSION = "2.0"

-----------------------------------------------------------------
-- Build an append function for the global table.
-- The created function will be responsible for appends on
-- the table at the given [[field]] of the global table.  The
-- table will be created if necessary.
-- @param field String with the name of the field on the current
--	table that will receive the value.
-- @return Function that insert a value in the table.
-- @see Tappend.

function Gappend (field)
   return function (value)
	local t = global_table[field]
	if type(t) ~= "table" then
	   t = { n = 0 }
	   global_table[field] = t
	end
	table.insert (t, filter (value))
   end
end

-----------------------------------------------------------------
-- Build an append-pair function for the global table.
-- The created function will be responsible for append pair of
-- values on the table at the given [[field]] of the global table.
-- The table will be created if necessary.
-- @param field String with the name of the field on the current
--	table that will receive the value.
-- @return Function that insert a value in the table.
-- @see Tappend.

function Gappend_pair (field)
   return function (index, value)
	local t = global_table[field]
	if type(t) ~= "table" then
	   t = { n = 0 }
	   global_table[field] = t
	end
	table.insert (t, { index, filter (value) })
   end
end

-----------------------------------------------------------------
-- Build an insertion function for the global table.
-- The created function will be responsible for inserting values
-- at a given position on the [[field]] of the current table.
-- The table at [[field]] could be created if necessary.
-- @param field String with the name of the field of the current
--	table that will receive the value.
-- @return Function that insert a given value at a given index
--	of the table.
-- @see Tcreate, Tappend.

function Ginsert (field)
   return function (index, value)
	local t = global_table[field]
	if type (t) ~= "table" then
	   t = { n = 0 }
	   global_table[field] = t
        end
	t[index] = filter (value)
   end
end

-----------------------------------------------------------------
-- Build a "son" for the given table.
-- @param t Current table.
-- @return "Son" table of the given table.

Tson = function (t)
   local newt = { parent = t, n = 0, }
   table.insert (t, newt)
   return newt
end

-----------------------------------------------------------------
-- Build an attribution funciton.
-- The created function will be responsible for attributions to
-- the [[field]] of the current table.
-- @param field String with the name of the field of the current
--	table that will receive the value.
-- @return Function that insert a value in the table.
-- @see Tinsert.
-- @see Tappend.

function Tcreate (field)
   return function (value) current_table[field] = filter (value) end
end

-----------------------------------------------------------------
-- Build an append function.
-- The created funciton will be responsible for insertions to
-- the table at [[field]] of the current table.  The table
-- will be created if necessary.
-- @param field String with the name of the field at the current
--	table.
-- @return Function that insert values in the current table.
-- @see Tcreate, Tinsert.

function Tappend (field)
   return function (value)
	local t = current_table[field]
	if type(t) ~= "table" then
	   t = { n = 0 }
	   current_table[field] = t
	end
	table.insert (t, filter (value))
   end
end

-----------------------------------------------------------------
-- Build an insertion function.
-- The created function will be responsible for inserting values
-- at a given position on the [[field]] of the current table.
-- The table at [[field]] could be created if necessary.
-- @param field String with the name of the field of the current
--	table that will receive the value.
-- @return Function that insert a given value at a given index
--	of the table.
-- @see Tcreate, Tappend.

function Tinsert (field)
   return function (index, value)
	local t = current_table[field]
	if type (t) ~= "table" then
	   t = { n = 0 }
	   current_table[field] = t
        end
	t[index] = filter (value)
   end
end

-----------------------------------------------------------------
-- Build a "return" function.
-- The created function could be used to assign the table built
-- at the current level to the [[field]] of the current table
-- of the upper level.
-- @param field String with the name of the field of the upper
--	level current table.
-- @return Function that "returns" the table to the upper one.

function Treturn (field)
   return function ()
	current_table.parent[field] = current_table
   end
end

-----------------------------------------------------------------
-- Build an attribution funciton to the upper level table.
-- The created function will be responsible for attributions to
-- the [[field]] of the upper level current table.
-- @param field String with the name of the field of the upper
--	level current table that will receive the value.
-- @return Function that insert a value in the upper level
--	current table.
-- @see Tinsert.
-- @see Tappend.

function Ucreate (field)
   return function (value) current_table.parent[field] = filter (value) end
end

-----------------------------------------------------------------
-- Build an append function to the upper level table.
-- The created funciton will be responsible for insertions to
-- at [[field]] of the upper level current table.  The table
-- will be created if necessary.
-- @param field String with the name of the field at the current
--	table.
-- @return Function that insert values in the upper level current table.
-- @see Tappend.


function Uappend (field)
   return function (value)
	local t = current_table.parent[field]
	if type(t) ~= "table" then
	   t = { n = 0 }
	   current_table.parent[field] = t
	end
	table.insert (t, filter (value))
   end
end

-----------------------------------------------------------------
-- Apply a series of filters to a string.
-- @param str String to be processed.
-- @return String after all the filters applied.

function filter (str)
   if global_table.comm_filters then
      return apply (str, global_table.comm_filters, {})
   else
      return str
   end
end

-----------------------------------------------------------------
-- Apply a series of substitutions to a string.
-- @param source String to be processed.
-- @param desc Table with pairs of matching patterns and substitution
--	patterns.
-- @param result_table Table that will receive the structured
--	document.
-- @return String after all the substitutions applied.
-- When the substitution pattern is a table, another entry on the
-- current table is created and the function is called recursively
-- with the matching substring as the source string; [[desc]] is
-- the substitution pattern and the current table is changed to
-- the new one..

function apply (source, desc, result_table)
   local old_table = current_table
   current_table = result_table
   for i = 1, table.getn(desc) do
      if type(desc[i]) == "function" then
         desc[i](current_table)
      else
         local find = desc[i][1]
         local rep = desc[i][2]
         local tr = type (rep)
         if tr == "table" then
            source = string.gsub (source, find, function (new_source)
		return apply (new_source, rep, Tson (current_table))
            end)
         else
            source = string.gsub (source, find, rep)
         end
      end
   end
   current_table = old_table
   return source
end

function copy_table (tab)
	local t = {}
	for i, v in tab do
		t[i] = v
	end
	return t
end

-----------------------------------------------------------------
-- Generate the output.
-- @param doc_table Table with the documentation.
-- @param filter_table Table with the output filters.
-- @see tab2str#t2s.

function write_doc (doc_table, filter_table)
   dofile "tab2str.lua"
   io.write (t2s (doc_table, "   "))
end

-----------------------------------------------------------------
-- Process an input file according to a set of substitutions and
-- generate an output file.
-- @param in_file String with the name of the input file.
-- @param desc_file String with the name of the substitutions file.
-- @param out_file String with the name of the output file (optional).
-- @return Table with the structured document.

function analyze (in_file, desc_file, out_file)
   -- load substitutions file.
   dofile (desc_file)
   -- load source string.
   local file = io.open (in_file, "r")
   local source = file:read ("*a")
   file:close ()
   -- initialize global variables.
   doc_table = { in_file = in_file, n = 0 }
   global_table = { comm_filters = copy_table (FILTERS), n = 0 }
   -- process source string.
   source = apply (source, lua, doc_table)
   -- generate output of the structured document as a table.
   if out_file then
      io.output (out_file)
      write_doc (doc_table, filter_table)
      io.close ()
   end
   return doc_table
end
