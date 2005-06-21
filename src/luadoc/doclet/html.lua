
module "luadoc.doclet.html"

local lp = require "cgilua.lp"
require "luadoc.util"

----------------------------------------------------------------------------
-- Preprocess and include the content of a mixed HTML file into the 
--  currently 'open' HTML document. 

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

options = {
	output_dir = "./",
}

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a module.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param filename Name of the file to be processed, may be a .lua file or
-- a .luadoc file.

function html_module (modulename)
	-- TODO: replace "." by "/" to create directories?
	return string.format("modules/%s.html", modulename)
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a lua(doc) file.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param filename Name of the file to be processed, may be a .lua file or
-- a .luadoc file.

function html_file (filename)
	local h = filename
	h = string.gsub(h, "lua$", "html")
	h = string.gsub(h, "luadoc$", "html")
	return "files/"..h
end

-------------------------------------------------------------------------------
-- Assembly the output filename for an input file.
-- TODO: change the name of this function
function out_file (filename)
	local h = html_file(filename)
--	h = options.output_dir..string.gsub (h, "^.-([%w_]+%.html)$", "%1")
	h = options.output_dir..h
	return h
end

-------------------------------------------------------------------------------
-- Assembly the output filename for a module.
-- TODO: change the name of this function
function out_module (modulename)
	return options.output_dir..html_module(modulename)
end

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.

function start (doc)
	-- Generate index file
	if (table.getn(doc.files) > 0) and (not options.noindexpage) then
		local filename = options.output_dir.."index.html"
		luadoc.logger:info(string.format("generating file `%s'", filename))
		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		lp.include("luadoc/doclet/html/index.lp", { table=table, io=io, tonumber=tonumber, tostring=tostring, type=type, luadoc=luadoc, doc=doc })
		f:close()
	end
	
	-- Process files
	for i, file_doc in doc.files do
		-- assembly the filename
		local filename = out_file(file_doc.name)
		luadoc.logger:info(string.format("generating file `%s'", filename))
		
		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		lp.include("luadoc/doclet/html/file.lp", { table=table, io=io, lp=lp, ipairs=ipairs, tonumber=tonumber, tostring=tostring, type=type, luadoc=luadoc, doc=file_doc.doc })
		f:close()
	end
	
	-- Process modules
	for modulename, module_doc in doc.modules do
		-- assembly the filename
		local filename = out_module(modulename)
		luadoc.logger:info(string.format("generating file `%s' for module `%s'", filename, modulename))
		
		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		lp.include("luadoc/doclet/html/module.lp", { table=table, io=io, lp=lp, ipairs=ipairs, tonumber=tonumber, type=type, luadoc=luadoc, doc=module_doc })
		f:close()
	end
end
