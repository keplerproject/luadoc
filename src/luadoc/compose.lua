
module "luadoc.compose"

---------------------------------------------------------------------------
-- Compose documentation.
-- This file defines the functions responsible for the generation of the
-- output document.

---------------------------------------------------------------------------
-- The global object.

CMP = {
	write = io.write,
	files = { },
	sources = { },
}

---------------------------------------------------------------------------
-- Traverse a table based on a description doing some action.
-- @param source Table with analyzed source code.
-- @param description Table with output description.
-- @param action Function to act on source.

function CMP.traverse_table (source, description, action)
end

---------------------------------------------------------------------------
-- Don't know.
-- @param source Table with analyzed source code.
-- @param description Table with output description.

function CMP.resolve_anchoring (source, description)
end

---------------------------------------------------------------------------
function CMP.sort_source (source, description)
   if description.order_field then
      table.sort (source, function (r1, r2)
      	if not r2 then
      	   return nil
      	elseif not r1 then
      	   return 1
      	end
      	local order = description.order_field
      	for i = 1, table.getn(order) do
      	   local field = order[i]
      	   local f1 = r1[field]
      	   local f2 = r2[field]
      	   if not f2 then
      	      return nil
      	   elseif not f1 then
      	      return 1
      	   end
      	   f1 = string.lower (f1)
      	   f2 = string.lower (f2)
      	   if f1 < f2 then
      	      return 1
      	   elseif f1 > f2 then
      	      return nil
      	   end
      	end
      	return nil
      end)
   end
end

---------------------------------------------------------------------------
-- Generate documentation for the given table.
-- @param source Table with the documentation.
-- @param description Table with the formatting information.

function CMP.write_doc (source, description)
	-- Outputs documentation of external level of source
	for i = 1, table.getn(description) do
		local desc = description[i]
		local ty = type (desc)
		if ty == "table" then
			local field = source[desc[1]]
			local func = desc[2]
			if field then
				CMP.write (func (field))
			end
		elseif ty == "string" then
			CMP.write (desc)
		elseif ty == "function" then
			CMP.write (desc (source))
		end
	end

	-- Recursion in the documentation table.
	if source[1] and description.internal_index and description.internal then
		CMP.section_name = nil
		CMP.sort_source (source, description.internal_index)
		for i = 1, table.getn(source) do
			CMP.write_doc (source[i], description.internal_index)
		end
		CMP.section_name = nil
		CMP.sort_source (source, description.internal)
		for i = 1, table.getn(source) do
			CMP.write_doc (source[i], description.internal)
		end
	end
	if description.footer then
		CMP.write (description.footer ())
	end
end

---------------------------------------------------------------------------
-- Compose the output.
-- @param in_tab Table with the descriptions.
-- @param cmp Table with output formatting rules.
-- @param out_file String with the name of the output file.

function compose (in_tab, doclet, out_file)
   CMP.out_format = doclet
   CMP.out_table = {}
   CMP.resolve_anchoring (in_tab, CMP.out_format)
   -- Write output file.
   io.output (out_file)
   in_tab.out_file = out_file
   CMP.write_doc (in_tab, CMP.out_format)
   io.close ()
   -- Save processed sources.
   table.insert (CMP.files, in_tab)
end

---------------------------------------------------------------------------
-- Create the global index.

function index (dir)
   io.output (dir.."index.html")
   CMP.write_doc (CMP.files, CMP.out_format.file_index)
   io.close ()
end
