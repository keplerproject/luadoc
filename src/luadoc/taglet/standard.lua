
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

	local patterns = {
		"^()function%s+([^%(%s]+)%s*%(%s*(.-)%s*%)",
		"^(local)%s+function%s+([^%(%s]+)%s*%(*s*(.-)%s*%)",
	}
	
	local info = table.foreachi(patterns, function (_, pattern)
		local r, _, l, id, param = string.find(line, pattern)
		if r ~= nil then
			return {
				name = id,
				private = (l == "local"),
				param = util.split("%s*,%s*", param),
			}
		end
	end)

	-- TODO: remove these assert's?
	if info ~= nil then
		assert(info.name, "function name undefined")
		assert(info.param, string.format("undefined parameter list for function `%s'", info.name))
	end

	return info
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
-- Extracts summary information from a description. The first sentence of each 
-- doc comment should be a summary sentence, containing a concise but complete 
-- description of the item. It is important to write crisp and informative 
-- initial sentences that can stand on their own
-- @param description text with item description
-- @return summary string or nil if description is nil

local function parse_summary (description)
	-- summary is never nil...
	description = description or ""
	
	-- append an " " at the end to make the pattern work in all cases
	description = string.gsub(description, "(.)$", "%1 ")

	-- read until the first period followed by a space or tab	
	local _, _, summary = string.find(description, "([^%.]*%.)[%s\t]")
	
	-- if pattern did not find the first sentence, summary is the whole description
	summary = summary or description
	
	return summary
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
	-- @author tuler Danilo Tuler de Oliveira
	-- @author carregal
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
-- Parses the information inside a block comment
-- @param block block with comment field
-- @return block parameter

local function parse_comment (block)

	-- get the first non-empty line of code
	local code = table.foreachi(block.code, function(_, line)
		if not util.line_empty(line) then
			return line
		end
	end)
	
	-- parse first line of code
	if code ~= nil then
		local func_info = check_function(code)
		local module_name = check_module(code)
		
		if func_info then
			block.class = "function"
			block.name = func_info.name
			block.param = func_info.param
		elseif module_name then
			block.class = "module"
			block.name = module_name
		end
	else
		-- TODO: comment without any code. Does this means we are dealing
		-- with a file comment?
	end

	-- parse @ tags
	local currenttag = "description"
	local currenttext
	
	-- TODO: remove these handlers from here
	local tag_handlers = {
		["description"] = function (tag, block, text)
			block[tag] = text
		end,

		["return"] = function (tag, block, text)
			tag = "ret"
			if type(block[tag]) == "string" then
				block[tag] = { block[tag], text }
			elseif type(block[tag]) == "table" then
				table.insert(block[tag], text)
			else
				block[tag] = text
			end
		end,
		
		-- same as return
		["see"] = function (tag, block, text)
			if type(block[tag]) == "string" then
				block[tag] = { block[tag], text }
			elseif type(block[tag]) == "table" then
				table.insert(block[tag], text)
			else
				block[tag] = text
			end
		end,
		
		["param"] = function (tag, block, text)
			block[tag] = block[tag] or {}
			-- TODO: make this pattern more flexible, accepting empty descriptions
			local _, _, name, desc = string.find(text, "^([_%w%.]+)%s+(.*)")
			assert(name, "parameter name not defined")
			local i = table.foreachi(block[tag], function (i, v)
				if v == name then
					return i
				end
			end)
			if i == nil then
				luadoc.logger:warn(string.format("documenting undefined parameter `%s'", name))
				table.insert(block[tag], name)
			end
			block[tag][name] = desc
		end,

		-- same as return
		["usage"] = function (tag, block, text)
			if type(block[tag]) == "string" then
				block[tag] = { block[tag], text }
			elseif type(block[tag]) == "table" then
				table.insert(block[tag], text)
			else
				block[tag] = text
			end
		end,
		
	}

	table.foreachi(block.comment, function (_, line)
		line = util.trim_comment(line)
		
		local r, _, tag, text = string.find(line, "@([_%w%.]+)%s+(.*)")
		if r ~= nil then
			-- found new tag, add previous one, and start a new one
			-- TODO: what to do with invalid tags? issue an error? or log a warning?
			assert(tag_handlers[currenttag], string.format("undefined handler for tag `%s'", currenttag))
			tag_handlers[currenttag](currenttag, block, currenttext)
			
			currenttag = tag
			currenttext = text
		else
			currenttext = util.concat(currenttext, line)
			assert(string.sub(currenttext, 1, 1) ~= " ", string.format("`%s', `%s'", currenttext, line))
		end
	end)
	assert(tag_handlers[currenttag], string.format("undefined handler for tag `%s'", currenttag))
	tag_handlers[currenttag](currenttag, block, currenttext)

	-- extracts summary information from the description
	block.summary = parse_summary(block.description)
	
	assert(string.sub(block.description, 1, 1) ~= " ", string.format("`%s'", block.description))
	
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
	local blocks = {
--		modulename = nil,
--		filepath = filepath,
		-- TODO: make iterators for functions, module or tables (based on class field)
	}
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
			
			-- TODO: keep beginning of file somewhere
			
			line = f:read()
		end
		i = i + 1
	end
	f:close()
	
	-- store blocks in file hierarchy
	-- TODO make hierarchy
	assert(doc.files[filepath] == nil, string.format("doc for file `%s' already defined", filepath))
	table.insert(doc.files, filepath)
	doc.files[filepath] = {
		type = "file",
		name = filepath,
		doc = blocks,
	}
	
	-- if module definition is found, store in module hierarchy
	-- TODO make hierarchy
	if modulename ~= nil then
		blocks.modulename = modulename
		if doc.modules[modulename] ~= nil then
			-- module is already defined, just add the blocks
			-- TODO: what to do with blocks.filepath in case of several files 
			-- contributing to a single module
			table.foreachi(blocks, function (_, v)
				table.insert(doc.modules[modulename].doc, v)
			end)
		else
			table.insert(doc.modules, modulename)
			doc.modules[modulename] = {
				type = "module",
				name = modulename,
				doc = blocks,
			}
		end
	end
	
	return doc
end

-------------------------------------------------------------------------------
-- Checks if the file is terminated by ".lua" or ".luadoc" and calls the 
-- function that does the actual parsing
-- @param filepath full path of the file to parse
-- @param doc table with documentation
-- @return table with documentation
-- @see parse_file

function file (filepath, doc)
	local patterns = { "%.lua$", "%.luadoc$" }
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
	assert(doc.files, "undefined `files' field")
	assert(doc.modules, "undefined `modules' field")
	
	table.foreachi(files, function (_, path)
		local attr = lfs.attributes(path)
		assert(attr, string.format("error stating path `%s'", path))
		
		if attr.mode == "file" then
			doc = file(path, doc)
		elseif attr.mode == "directory" then
			doc = directory(path, doc)
		end
	end)
	
	-- order arrays alphabetically
	table.sort(doc.files)
	table.sort(doc.modules)
		
	return doc
end
