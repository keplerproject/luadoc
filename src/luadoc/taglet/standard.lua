
module "luadoc.taglet.standard"

require "luadoc"
require "lfs"

local function parse_code (f, line)
	local code = {}
	while line ~= nil do
		if string.find(line, "^%-%-%-") then
			-- reached another luadoc block
			return line, code
		else
			table.insert(code, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, code
end

local function parse_block (f, line)
	local block = {
		comment = {},
		code = {},
	}
	
	while line ~= nil do
		if string.find(line, "^%-%-") == nil then
			-- reached end of comment, read the code below it
			-- TODO: allow empty lines
			line, block.code = parse_code(f, line)
			return line, block
		else
			table.insert(block.comment, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, block
end

function parse_file (filepath, doc)
	local blocks = {}
	local d = nil
	
	-- read each line
	local f = io.open(filepath, "r")
	local line = f:read()
	while line ~= nil do
		if string.find(line, "^%-%-%-") then
			-- reached a luadoc block
			local block
			line, block = parse_block(f, line)
			table.insert(blocks, block)
		else
			line = f:read()
		end
	end
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
		local fullpath = path .. "/" .. f
		local attr = lfs.attributes(fullpath)
		assert(attr, string.format("error stating file `%s'", fullpath))
		
		if attr.mode == "file" then
			doc = file(fullpath, doc)
		elseif attr.mode == "directory" and f ~= "." and f ~= ".." then
			doc = directory(fullpath, doc)
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
