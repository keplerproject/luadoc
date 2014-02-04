-------------------------------------------------------------------------------
-- Doclet that generates HTML output. This doclet generates a set of html files
-- based on a group of templates. The main templates are:
-- <ul>
-- <li>index.lp: index of modules and files;</li>
-- <li>file.lp: documentation for a lua file;</li>
-- <li>module.lp: documentation for a lua module;</li>
-- <li>function.lp: documentation for a lua function. This is a
-- sub-template used by the others.</li>
-- </ul>
--
-- @release $Id: html.lua,v 1.29 2007/12/21 17:50:48 tomas Exp $
-------------------------------------------------------------------------------

local assert, getfenv, ipairs, loadstring, pairs, setfenv, tostring, tonumber, type = assert, getfenv, ipairs, loadstring, pairs, setfenv, tostring, tonumber, type
local print = print
local io = require"io"
local lfs = require "lfs"
local lp = require "luadoc.lp"
local luadoc = require"luadoc"
local package = package
local string = require"string"
local table = require"table"

module "luadoc.doclet.html"

-------------------------------------------------------------------------------
-- Looks for a file `name' in given path. Removed from compat-5.1
-- @param path String with the path.
-- @param name String with the name to look for.
-- @return String with the complete path of the file found
--	or nil in case the file is not found.

local function search (path, name)
  for c in string.gfind(path, "[^;]+") do
    c = string.gsub(c, "%?", name)
    local f = io.open(c)
    if f then   -- file exist?
      f:close()
      return c
    end
  end
  return nil    -- file not found
end

-------------------------------------------------------------------------------
-- Include the result of a lp template into the current stream.

function include (template, env)
	-- template_dir is relative to package.path
	local templatepath = options.template_dir .. template

	-- search using package.path (modified to search .lp instead of .lua
	local search_path = string.gsub(package.path, "%.lua", "")
	local templatepath = search(search_path, templatepath)
	assert(templatepath, string.format("template `%s' not found", template))

	env = env or {}
	env.table = table
	env.io = io
	env.lp = lp
	env.ipairs = ipairs
	env.tonumber = tonumber
	env.tostring = tostring
	env.type = type
	env.luadoc = luadoc
	env.options = options

	return lp.include(templatepath, env)
end

-------------------------------------------------------------------------------
-- Returns a link to a html file, appending "../" to the link to make it right.
-- @param html Name of the html file to link to
-- @return link to the html file

function link (html, from)
	local h = html
	from = from or ""
	string.gsub(from, "/", function () h = "../" .. h end)
	return h
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a module.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param modulename Name of the module to be processed, may be a .lua file or
-- a .luadoc file.
-- @return name of the generated html file for the module

function module_link (modulename, doc, from)
	-- TODO: replace "." by "/" to create directories?
	-- TODO: how to deal with module names with "/"?
	assert(modulename)
	assert(doc)
	from = from or ""

	if doc.modules[modulename] == nil then
--		logger:error(string.format("unresolved reference to module `%s'", modulename))
		return
	end

	local href = "modules/" .. modulename .. ".html"
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a lua(doc) file.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param to Name of the file to be processed, may be a .lua file or
-- a .luadoc file.
-- @param from path of where am I, based on this we append ..'s to the
-- beginning of path
-- @return name of the generated html file

function file_link (to, from)
	assert(to)
	from = from or ""

	local href = to
	href = string.gsub(href, "lua$", "html")
	href = string.gsub(href, "luadoc$", "html")
	href = "files/" .. href
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

-------------------------------------------------------------------------------
-- Returns a link to a function or to a table
-- @param fname name of the function or table to link to.
-- @param doc documentation table
-- @param kind String specying the kind of element to link ("functions" or "tables").

function link_to (fname, doc, module_doc, file_doc, from, kind)
	assert(fname)
	assert(doc)
	from = from or ""
	kind = kind or "functions"
  local optional
  
--local msg = ""  
--if fname:find("afterset") then msg = msg .. "\n" .. string.rep("=", 50) end
--if fname:find("afterset") and module_doc then msg = msg .. "\n" .. string.format("START module_doc for `%s'", fname) end
--if fname:find("afterset") and file_doc then msg = msg .. "\n" .. string.format("START file_doc for `%s'", fname) end
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("    doc : %s", tostring(doc)) end
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("    from: %s", tostring(from)) end
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("    kind: %s", tostring(kind)) end

	if file_doc then
--if fname:find("afterset") then msg = msg .. "\n" .. "checking file_doc" end
		for _, func_name in pairs(file_doc[kind]) do
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("   \t%s\t%s", tostring(fname), tostring(func_name)) end
			if func_name == fname then
--if fname:find("afterset") then msg = msg .. "\n" .. "  FOUND IT!"; print (msg) end
				return file_link(file_doc.name, from) .. "#" .. fname
			end
      if type(func_name) == "string" and func_name:find("[%.%:]" .. fname .. "$") then
        -- this could be a match; symbol found, but the found one has a prefix
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("  FOUND OPTIONAL!  `%s' for `%s'",func_name, fname) end
        optional = file_link(file_doc.name, from) .. "#" .. func_name
      end
		end
--if fname:find("afterset") then msg = msg .. "\n" .. "  NOT FOUND!" end
	end

	local _, _, modulename, sfname = string.find(fname, "^(.-)[%.%:]?([^%.%:]*)$")
	assert(sfname)
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("Module lookup for `%s', module `%s' and symbol `%s'",fname, modulename, sfname) end

	-- if fname does not specify a module, use the module_doc
	if string.len(modulename) == 0 and module_doc then
		modulename = module_doc.name
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("Update: module lookup for `%s', module `%s' and symbol `%s'",fname, modulename, sfname) end
	end
--if fname:find("afterset") then msg = msg .. "\n" .. "   Modulelist:" end
--if fname:find("afterset") then for k,v in pairs(doc.modules) do msg = msg .. "\n" .. string.format("      \t%s\t%s", tostring(k),tostring(v)) end end

	local module_doc = doc.modules[modulename]
  if not module_doc then
    -- module not found, check for partial module name
    for k,v in pairs(doc.modules) do
      if type(k) == "string" and k:find("%." .. modulename .. "$") then
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("FOUND OPTIONAL MODULE: module `%s' for name `%s'",modulename, fname) end
        module_doc = v
        modulename = k
      end
    end
  end
	if not module_doc then  
    if optional then
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("RETURNING OPTIONAL: module `%s'",modulename); if kind == "functions" then print(msg) end end
      return optional
    else
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("NOT FOUND: module `%s'",modulename); if kind == "functions" then print(msg) end end
--	    logger:error(string.format("unresolved reference to function `%s': module `%s' not found", sfname, modulename))
      return
    end
	end

--if fname:find("afterset") then msg = msg .. "\n" .. "checking module_doc" end
	for _, func_name in pairs(module_doc[kind]) do
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("  \t%s\t%s", tostring(fname), tostring(func_name)) end
		if func_name == sfname then
--if fname:find("afterset") then msg = msg .. "\n" .. "  FOUND IT!"; if kind == "functions" then print(msg) end end
			return module_link(modulename, doc, from) .. "#" .. sfname
    elseif func_name == fname then -- if a @name tag is used check full name
--if fname:find("afterset") then msg = msg .. "\n" .. "  FOUND IT!"; if kind == "functions" then print(msg) end end
			return module_link(modulename, doc, from) .. "#" .. fname
		end
    if type(func_name) == "string" and fname:find("[%.%:]" .. func_name .. "$") then
      -- this could be a match; symbol found, but the found one has a prefix
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("  FOUND OPTIONAL!  `%s' for `%s'",func_name, fname) end
      optional = module_link(modulename, doc, from) .. "#" .. func_name
    end
    if type(func_name) == "string" and func_name:find("[%.%:]" .. fname .. "$") then
      -- this could be a match; symbol found, but the found one has a prefix
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("  FOUND OPTIONAL!  `%s' for `%s'",func_name, fname) end
      optional = module_link(modulename, doc, from) .. "#" .. func_name
    end
	end
  
  if optional then
--if fname:find("afterset") then msg = msg .. "\n" .. string.format("RETURNING: module `%s'",modulename); if kind == "functions" then print(msg) end end
    return optional
  end
--if fname:find("afterset") then msg = msg .. "\n" .. "  FAILED!"; if kind == "functions" then print(msg) end end

--	logger:error(string.format("unresolved reference to function `%s' of module `%s'", fname, modulename))
end

-------------------------------------------------------------------------------
-- Make a link to a file, module or function
-- @return table with keys 'symbol' and 'display'
function symbol_link (symbol, doc, module_doc, file_doc, from)
	assert(symbol)
	assert(doc)

  local href
  local sym
  
  if type(symbol) == "table" then
    -- explicit reference provided
    href = symbol.reference
    sym = symbol.symbol
  else
    -- single string, go look up in our doc
--print("symbol:", symbol)
    href =
  --		file_link(symbol, from) or
      module_link(symbol, doc, from) or
      link_to(symbol, doc, module_doc, file_doc, from, "functions") or
      link_to(symbol, doc, module_doc, file_doc, from, "tables")
    if not href then
      logger:error(string.format("unresolved reference to symbol `%s'", symbol))
    end
    sym = symbol
  end
  
	return {["href"] = (href or ""), ["display"] = sym or ""}
end

-------------------------------------------------------------------------------
-- Assembly the output filename for an input file.
-- TODO: change the name of this function
function out_file (filename)
	local h = filename
	h = string.gsub(h, "lua$", "html")
	h = string.gsub(h, "luadoc$", "html")
	h = "files/" .. h
--	h = options.output_dir .. string.gsub (h, "^.-([%w_]+%.html)$", "%1")
	h = options.output_dir .. h
	return h
end

-------------------------------------------------------------------------------
-- Assembly the output filename for a module.
-- TODO: change the name of this function
function out_module (modulename)
	local h = modulename .. ".html"
	h = "modules/" .. h
	h = options.output_dir .. h
	return h
end

-------------------------------------------------------------------------------
-- Update a table to make all string values refelect html tags for linebreaks
-- a leading spaces.
function fixhtmltable (doc)
    for k,v in pairs(doc) do
        if type(v) == "string" then
            -- update string value
            local s = string.gsub(v, "\n", "<br/>")
            s = string.gsub(s, "<br/> ", "<br/>&nbsp;")
            while string.find(s, "&nbsp; ") do
                s = string.gsub(s, "&nbsp; ", "&nbsp;&nbsp;")
            end
            doc[k] = s
        elseif type(v) == "table" then
            -- recurse update table
            fixhtmltable(v)
        end
    end
end

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.

function start (doc)
    -- Pre proces doc table, replacing linebreaks and leading space by html equiv.
    fixhtmltable(doc)
	-- Generate index file
	if (#doc.files > 0 or #doc.modules > 0) and (not options.noindexpage) then
		local filename = options.output_dir.."index.html"
		logger:info(string.format("generating file `%s'", filename))
		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		include("index.lp", { doc = doc })
		f:close()
	end

	-- Process modules
	if not options.nomodules then
		for _, modulename in ipairs(doc.modules) do
			local module_doc = doc.modules[modulename]
			-- assembly the filename
			local filename = out_module(modulename)
			logger:info(string.format("generating file `%s'", filename))

			local f = lfs.open(filename, "w")
			assert(f, string.format("could not open `%s' for writing", filename))
			io.output(f)
			include("module.lp", { doc = doc, module_doc = module_doc })
			f:close()
		end
	end

	-- Process files
	if not options.nofiles then
		for _, filepath in ipairs(doc.files) do
			local file_doc = doc.files[filepath]
			-- assembly the filename
			local filename = out_file(file_doc.name)
			logger:info(string.format("generating file `%s'", filename))

			local f = lfs.open(filename, "w")
			assert(f, string.format("could not open `%s' for writing", filename))
			io.output(f)
			include("file.lp", { doc = doc, file_doc = file_doc} )
			f:close()
		end
	end

	-- copy extra files
	local f = lfs.open(options.output_dir.."luadoc.css", "w")
	io.output(f)
	include("luadoc.css")
	f:close()
end
