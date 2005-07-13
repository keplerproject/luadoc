-- $Id: html.lua,v 1.21 2005/07/13 18:45:15 tuler Exp $

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

module "luadoc.doclet.html"

local lp = require "luadoc.lp"
require "luadoc.util"

-------------------------------------------------------------------------------
-- Preprocess and include the content of a mixed HTML file into the 
-- currently 'open' HTML document. 

function lp2func (filename, doc)
	local fh = assert (io.open (filename))
	local prog = fh:read("*a")
	fh:close()
	prog = lp.translate (prog, "file "..filename)
	if prog then
		local f, err = loadstring (prog, "@"..filename)
		if f then
			return f
		else
			error (err)
		end
	end
end

function envexec (prog, env)
	local _env
	if env then
		_env = getfenv (prog)
		setfenv (prog, env)
	end
	prog ()
	if env then
		setfenv (prog, _env)
	end
end

function lp.include (filename, env)
	local prog = lp2func (filename)
	envexec (prog, env)
end

-------------------------------------------------------------------------------
-- Include the result of a lp template into the current stream.

function include (template, env)
	local templatepath = options.template_dir .. template
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
--		luadoc.logger:error(string.format("unresolved reference to module `%s'", modulename))
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
-- Returns a link to a function
-- @param fname name of the function to link to.
-- @param doc documentation table

function function_link (fname, doc, module_doc, file_doc, from)
	assert(fname)
	assert(doc)
	from = from or ""
	
	if file_doc then
		for _, func_name in file_doc.functions do
			if func_name == fname then
				return file_link(file_doc.name, from) .. "#" .. fname
			end
		end
	end
	
	local _, _, modulename, fname = string.find(fname, "^(.-)[%.%:]?([^%.%:]*)$")
	assert(fname)

	-- if fname does not specify a module, use the module_doc
	if string.len(modulename) == 0 and module_doc then
		modulename = module_doc.name
	end

	local module_doc = doc.modules[modulename]
	if not module_doc then
--		luadoc.logger:error(string.format("unresolved reference to function `%s': module `%s' not found", fname, modulename))
		return
	end
	
	for _, func_name in module_doc.functions do
		if func_name == fname then
			return module_link(modulename, doc, from) .. "#" .. fname
		end
	end
	
--	luadoc.logger:error(string.format("unresolved reference to function `%s' of module `%s'", fname, modulename))
end

-------------------------------------------------------------------------------
-- Make a link to a file, module or function

function symbol_link (symbol, doc, module_doc, file_doc, from)
	assert(symbol)
	assert(doc)
	
	local href = 
--		file_link(symbol, from) or
		module_link(symbol, doc, from) or 
		function_link(symbol, doc, module_doc, file_doc, from)
	
	if not href then
		luadoc.logger:error(string.format("unresolved reference to symbol `%s'", symbol))
	end
	
	return href or ""
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

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.

function start (doc)
	-- Generate index file
	if (table.getn(doc.files) > 0 and table.getn(doc.modules) > 0) and (not options.noindexpage) then
		local filename = options.output_dir.."index.html"
		luadoc.logger:info(string.format("generating file `%s'", filename))
		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		include("index.lp", { doc = doc })
		f:close()
	end
	
	-- Process modules
	if options.modules then
		for _, modulename in ipairs(doc.modules) do
			local module_doc = doc.modules[modulename]
			-- assembly the filename
			local filename = out_module(modulename)
			luadoc.logger:info(string.format("generating file `%s'", filename))
			
			local f = lfs.open(filename, "w")
			assert(f, string.format("could not open `%s' for writing", filename))
			io.output(f)
			include("module.lp", { doc = doc, module_doc = module_doc })
			f:close()
		end
	end

	-- Process files
	if options.files then
		for _, filepath in ipairs(doc.files) do
			local file_doc = doc.files[filepath]
			-- assembly the filename
			local filename = out_file(file_doc.name)
			luadoc.logger:info(string.format("generating file `%s'", filename))
			
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
