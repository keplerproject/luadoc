
-------------------------------------------------------------------------------
-- Module with several utilities that could not fit in a specific module

module "luadoc.util"
require "lfs"

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

