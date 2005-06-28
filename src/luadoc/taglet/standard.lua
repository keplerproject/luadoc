
module 'luadoc.taglet.standard'

require "luadoc"
local util = require "luadoc.util"
require "lfs"

-------------------------------------------------------------------------------
-- Checks if the line contains a function definition
-- @param line string with line text
-- @return function information or nil if no function definition found

local function check_function (line)
	line = util.trim(line)
	
	-- function x.y:z (a, b, ...)
	-- local function x.y:z (a, b, ...)

	-- TODO: support "local function"
--	local r, _, identifier, param_list = string.find(line, "^local%s+function%s+([^%(%s])%s*%((.-)%)")
	local r, _, identifier, param_list = string.find(line, "^function%s+([^%(%s]+)%s*%((.-)%)")
	
	if r ~= nil then
		return identifier, param_list
	end
end

-------------------------------------------------------------------------------
-- Checks if the line contains a module definition.
-- @param line string with line text
-- @param currentmodule module already found, if any
-- @return the name of the defined module, or nil if there is no module 
-- definition

local function check_module (line, currentmodule)
	line = util.trim(line)
	
	-- module"x.y"
	-- module'x.y'
	-- module[[x.y]]
	-- module("x.y")
	-- module('x.y')
	-- module([[x.y]])
	-- module(...)

	-- TODO: support all the above formats
	local r, _, modulename = string.find(line, "^module%s*[\"'](.-)[\"']")
	if r then
		-- found module definition
		luadoc.logger:debug(string.format("found module `%s'", modulename))
		return modulename
	end
	return currentmodule
end

-------------------------------------------------------------------------------
-- @param f file handle
-- @param line current line being parsed
-- @param modulename module already found, if any
-- @return current line
-- @return code block
-- @return modulename if found

local function parse_code (f, line, modulename)
	local code = {}
	while line ~= nil do
		if string.find(line, "^%-%-%-") then
			-- reached another luadoc block, end this parsing
			return line, code, modulename
		else
			-- look for a module definition
			modulename = check_module(line, modulename)
			
			table.insert(code, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, code, modulename
end

-------------------------------------------------------------------------------

local function parse_tag (block)
	-- @author <text>
	-- @param <name> <text>
	-- @see <identifier>
	-- @see <identifier> <text>
	-- @see <identifier>, <identifier> REALLY SUPPORT THIS?
	-- @return <name> <text>
	-- @return <name> <text>
	-- @return <name>, <name>, <name> REALLY SUPPORT THIS?
	-- @usage
	-- @deprecated
	-- @field HOW DOES THIS WORK?	
end

-------------------------------------------------------------------------------
-- Parses the information inside a block comment.
-- @param block.comment comment text of the block
-- @return block parameter

local function parse_comment (block)
	
	-- set a string field on a table key, or if there is already a string
	-- in that key, make an array of strings
	local set_insert = function (t, fieldname)
		return function (text)
			if t[fieldname] == nil then
				t[fieldname] = text
			elseif type(t[fieldname]) == "string" then
				t[fieldname] = { t[fieldname], text }
			elseif type(t[fieldname]) == "table" then
				table.insert(t[fieldname], text)
			end
		end
	end

	-- set a string field on a table key, or if there is already a string
	-- in that key, concatenate the strings
	local set_append = function (t, fieldname, separator)
		separator = separator or " "
		return function (text)
			if t[fieldname] == nil then
				t[fieldname] = text
			else
				t[fieldname] = string.format("%s%s%s", t[fieldname], separator, text)
			end
		end
	end

	-- parse @ tags
	local section
	local process = set_append(block, "description")
	local process = function () end

	table.foreachi(block.comment, function (i, line)
		line = util.trim_comment(line)
		
		local r, _, section, text = string.find(line, "@([_%w]+)%s+(.-)")
		if r ~= nil then
			-- found subsection
			-- TODO: use set_insert in any tag type?
			--process = set_insert(block, section)
			--process = insert(block, section)
			process = function () end
			process(line)
		else
			process(line)
		end
	end)
	
	-- TODO: discover class of block
	-- parse first line of code
	
	-- get the first non-empty line of code
	local code = table.foreachi(block.code, function(i, line)
		if not util.line_empty(line) then
			return line
		end
	end)
	
	if code ~= nil then
		local func_name, param_list = check_function(code)
		local module_name = check_module(code)
		
		if func_name then
			block.class = "function"
			block.name = func_name
			block.param_list = param_list
			block.resume = "TODO: resume"
		elseif module_name then
			block.class = "module"
			block.name = module_name
		end
	end	
	
	block.resume = "TODO: resume"
	
	return block
end

-------------------------------------------------------------------------------
-- Parses a block of comment, started with ---. Read until the next block of
-- comment.
-- @param f file handle
-- @param line being parsed
-- @param modulename module already found, if any
-- @return line
-- @return block parsed
-- @return modulename if found

local function parse_block (f, line, modulename)
	local block = {
		comment = {},
		code = {},
	}
	
	while line ~= nil do
		if string.find(line, "^%-%-") == nil then
			-- reached end of comment, read the code below it
			-- TODO: allow empty lines
			line, block.code, modulename = parse_code(f, line, modulename)
			
			-- parse information in block comment
			block = parse_comment(block)
			
			return line, block, modulename
		else
			table.insert(block.comment, line)
			line = f:read()
		end
	end
	-- reached end of file
	
	-- parse information in block comment
	block = parse_comment(block)
	
	return line, block, modulename
end

-------------------------------------------------------------------------------
-- Parses a file documented following luadoc format.
-- @param filepath full path of file to parse
-- @param doc table with documentation
-- @return table with documentation

function parse_file (filepath, doc)
	local blocks = {}
	local modulename = nil
	
	-- read each line
	local f = io.open(filepath, "r")
	local i = 1
	local line = f:read()
	while line ~= nil do
		if string.find(line, "^%-%-%-") then
			-- reached a luadoc block
			local block
			line, block, modulename = parse_block(f, line, modulename)
			table.insert(blocks, block)
		else
			-- look for a module definition
			modulename = check_module(line, modulename)
			
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
	-- TODO find a way to write module level comments
	-- TODO make hierarchy
	if modulename ~= nil then
		if doc.modules[modulename] ~= nil then
			-- module is already defined, just add the blocks
			table.foreachi(blocks, function (i, v) table.insert(doc.modules[modulename], v) end)
		else
			doc.modules[modulename] = blocks
		end
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
