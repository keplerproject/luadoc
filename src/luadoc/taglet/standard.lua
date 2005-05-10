
module "luadoc.taglet.standard"

require "luadoc"
require "lfs"

function parse_file (filepath, doc)
	-- read the whole file
	local f = io.open(filepath, "r")
	local content = f:read("*a")
	f:close()	
	
	return doc
end

function file (filepath, doc)
	local patterns = { ".*%.lua$", ".*%.luadoc$" }
	local valid = table.foreachi(patterns, function (_, pattern)
		if string.find(filepath, pattern) ~= nil then
			return true
		end
	end)
	
	if valid then
		luadoc.logger:info(string.format("processing file `%s'", filepath))
		doc = parse_file(filepath, doc)
	end
	
	return doc
end

function directory (path, doc)
	for f in lfs.dir(path) do
		local attr = lfs.attributes(f)
		assert(attr, string.format("error stating path `%s'", path))
		
		if attr.mode == "file" then
			doc = file(f, doc)
		elseif attr.mode == "directory" and f ~= "." and f ~= ".." then
			doc = directory(f, doc)
		end
	end
	return doc
end

function start (files, doc)
	assert(files, "file list not specified")
	
	-- Create an empty document, or use the given one
	doc = doc or {
		files = {},
		modules = {},
	}
	
	table.foreachi(files, function (i, path)
		local attr = lfs.attributes(path)
		assert(attr, string.format("error stating path `%s'", path))
		
		if attr.mode == "file" then
			doc = file(path, doc)
		elseif attr.mode == "directory" then
			doc = directory(path, doc)
		end
	end)	
	
	return doc
end
