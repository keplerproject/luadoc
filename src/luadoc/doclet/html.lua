
module "luadoc.doclet.html"

local lp = require "cgilua.lp"

----------------------------------------------------------------------------
-- Preprocess and include the content of a mixed HTML file into the 
--  currently 'open' HTML document. 
----------------------------------------------------------------------------
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
-- Assembly the output filename for an input file
function out_file (in_file)
	local h = string.gsub (in_file, "lua$", "html")
	h = options.output_dir..string.gsub (h, "^.-([%w_]+%.html)$", "%1")
	return h
end

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.

function start (doc)
	-- Generate index file
	if (table.getn(doc.files) > 0) and (not options.noindexpage) then
	
		local filename = options.output_dir.."index.html"
		local f = io.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		lp.include("luadoc/doclet/html/index.lp", { table=table, io=io, tonumber=tonumber, tostring=tostring, type=type, luadoc=luadoc, doc=doc })
		f:close()
	end
	
	-- Process files
	for i, file_doc in doc.files do
	
		-- assembly the filename
		local filename = out_file(file_doc.in_file)
		if options.verbose then
			print ("generating "..filename)
		end
		
		local f = io.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		lp.include("luadoc/doclet/html/file.lp", { table=table, io=io, tonumber=tonumber, tostring=tostring, type=type, luadoc=luadoc, doc=file_doc })
		f:close()	
	end
end
