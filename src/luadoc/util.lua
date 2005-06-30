
-------------------------------------------------------------------------------
-- Module with several utilities that could not fit in a specific module

module "luadoc.util"
--require "lfs"

-------------------------------------------------------------------------------
-- Removes spaces from the begining and end of a given string
-- @param s string to be trimmed
-- @return trimmed string

function trim (s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-------------------------------------------------------------------------------
-- Removes spaces from the begining and end of a given string, considering the
-- string is inside a lua comment.
-- @param s string to be trimmed
-- @return trimmed string

function trim_comment (s)
	s = string.gsub(s, "%-%-+(.*)$", "%1")
	return trim(s)
end

-------------------------------------------------------------------------------
-- Checks if a given line is empty
-- @param line string with a line
-- @return true if line is empty, false otherwise

function line_empty (line)
	return (string.len(trim(line)) == 0)
end

-------------------------------------------------------------------------------
-- Appends two string, but if the first one is nil, use to second one
-- @param str1 first string, can be nil
-- @param str2 second string
-- @return str1 .. " " .. str2, or str2 if str1 is nil

function concat (str1, str2)
	if str1 == nil then
		return str2
	else
		return str1 .. " " .. str2
	end
end

-------------------------------------------------------------------------------
-- Split text into a list consisting of the strings in text,
-- separated by strings matching delim (which may be a pattern). 
-- @param delim if delim is "" then action is the same as %s+ except that 
-- field 1 may be preceeded by leading whitespace
-- @usage split(",%s*", "Anna, Bob, Charlie,Dolores")
-- @usage split(""," x y") gives {"x","y"}
-- @usage split("%s+"," x y") gives {"", "x","y"}
function split(delim, text)
	local list = {}
	if string.len(text) > 0 then
		delim = delim or ""
		local pos = 1
		-- if delim matches empty string then it would give an endless loop
		if string.find("", delim, 1) and delim ~= "" then 
			error("delim matches empty string!")
		end
		local first, last
		while 1 do
			if delim ~= "" then 
				first, last = string.find(text, delim, pos)
			else
				first, last = string.find(text, "%s+", pos)
				if first == 1 then
					pos = last+1
					first, last = string.find(text, "%s+", pos)
				end
			end
			if first then -- found?
				table.insert(list, string.sub(text, pos, first-1))
				pos = last+1
			else
				table.insert(list, string.sub(text, pos))
				break
			end
		end
	end
	return list
end

-------------------------------------------------------------------------------
-- Opens a file, creating the directories if necessary
-- @param filename full path of the file to open (or create)
-- @param mode mode of opening
-- @return file handle

function lfs.open(filename, mode)
	local f = io.open(filename, mode)
	if f == nil then
		filename = string.gsub(filename, "\\", "/")
		local dir = ""
		for d in string.gfind(filename, ".-/") do
			dir = dir .. d
			lfs.mkdir(dir)
		end
		f = io.open(filename, mode)
	end
	return f
end

