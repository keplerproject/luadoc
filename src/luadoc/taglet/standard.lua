
module 'luadoc.taglet.standard'

require "luadoc"
local util = require "luadoc.util"
require "lfs"

-------------------------------------------------------------------------------
-- Checks if the line contains a module definition.
-- @param line string with line text
-- @return the name of the defined module, or nil if there is no module 
-- definition

local function check_module (line)
	line = util.trim(line)
	
	-- module"x.y"
	-- module'x.y'
	-- module[[x.y]]
	-- module("x.y")
	-- module('x.y')
	-- module([[x.y]])

	-- TODO: support all the above formats
	local r, _, modulename = string.find(line, "^module%s*[\"'](.-)[\"']")
	if r then
		-- found module definition
		luadoc.logger:debug(string.format("found module definition on `%s'", line))
		
		-- now looks for the module name
		local modulename
		return modulename
	end
	return nil
end

-------------------------------------------------------------------------------
-- @param f file handle
-- @param line current line being parsed
-- @return current line
-- @return code block
-- @return modulename if found

local function parse_code (f, line)
	local code = {}
	local modulename
	while line ~= nil do
		if string.find(line, "^%-%-%-") then
			-- reached another luadoc block, end this parsing
			return line, code, modulename
		else
			-- look for a module definition
			modulename = check_module(line)
			
			table.insert(code, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, code, modulename
end

-------------------------------------------------------------------------------
-- Parses a block of comment, started with ---. Read until the next block of
-- comment.
-- @param f file handle
-- @param line being parsed
-- @return line
-- @return block parsed
-- @return modulename if found

local function parse_block (f, line)
	local block = {
		comment = {},
		code = {},
	}
	local modulename
	
	while line ~= nil do
		if string.find(line, "^%-%-") == nil then
			-- reached end of comment, read the code below it
			-- TODO: allow empty lines
			line, block.code, modulename = parse_code(f, line)
			return line, block, modulename
		else
			table.insert(block.comment, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, block, modulename
end

-------------------------------------------------------------------------------
-- Parses a file documented following luadoc format.
-- @param filepath full path of file to parse
-- @param doc table with documentation
-- @return table with documentation

function parse_file (filepath, doc)
	local blocks = {}
	local modulename
	
	-- read each line
	local f = io.open(filepath, "r")
	local i = 1
	local line = f:read()
	while line ~= nil do
		if string.find(line, "^%-%-%-") then
			-- reached a luadoc block
			local block
			line, block = parse_block(f, line)
			table.insert(blocks, block)
		else
			-- look for a module definition
			modulename = check_module(line)
			
			line = f:read()
		end
	end
	f:close()
	
	-- store blocks in file hierarchy
	-- TODO make hierarchy
	table.insert(doc.files, {
		type = "file",
		name = filepath,
		doc = blocks,
	})
	
	-- if module definition is found, store in module hierarchy
	-- TODO find module definition
	if modulename ~= nil then
		doc.modules[modulename] = blocks
	end
	
	return doc
end

-------------------------------------------------------------------------------
-- Checks if the file is terminated by ".lua" or ".luadoc" and calls the 
-- that does the actual parsing
-- @param filepath full path of the file to parse
-- @param doc table with documentation
-- @return table with documentation

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

-------------------------------------------------------------------------------
-- Recursively iterates through a directory, parsing each file
-- @param path directory to search
-- @param doc table with documentation
-- @return table with documentation

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
