#!/usr/local/bin/lua

-- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not package then
	if not LUA_PATH then
		LUA_PATH = [[./?.lua;./?/?.lua;../../cgilua/src/?.lua;../../cgilua/src/?/?.lua;../../lualogging/src/?.lua]]
	end
	require"compat-5.1"
	package.cpath = [[./?.dll;../../luafilesystem/bin/vc6/?.dll]]
end

module "luadoc"

require "lfs"
require "logging"
require "logging.console"
logger = logging.console()
--logger = logging.file("luadoc.log")

-------------------------------------------------------------------------------
-- LuaDoc version number.

_NAME = "LuaDoc"
_DESCRIPTION = "Documentation Generator Tool for the Lua language"
_VERSION = "3.0.0"
_COPYRIGHT = "Copyright (c) 2003-2005 The Kepler Project"

-- Load sub-modules
require "luadoc.analyze"
require "luadoc.compose"

-- Print version number.
function print_version ()
	print (string.format("%s %s\n%s\n%s", _NAME, _VERSION, _DESCRIPTION, _COPYRIGHT))
end

-- Print usage message.
function print_help ()
	print ("Usage: "..arg[0]..[[ [options|files]
Extract documentation from files.  Available options are:
  -d path               output directory path
  -f "<find>=<repl>"    define a substitution filter (only string patterns)
  -g "<find>=<repl>"    define a substitution filter (string.gsub patterns)
  -h, --help            print this help and exit
      --noindexpage     do not generate global index page
      --doclet doclet   doclet module to generate output
      --taglet taglet   taglet module to parse input code
  -q, --quiet           suppress all normal output
  -v, --version         print version information]])
end

function off_messages (arg, i, options)
	options.verbose = nil
end

-- Global filters.
FILTERS = {}
-- Process options.
OPTIONS = {
	d = function (arg, i, options)
		local dir = arg[i+1]
		if string.sub (dir, -2) ~= "/" then
			dir = dir..'/'
		end
		options.output_dir = dir
		return 1
	end,
	f = function (arg, i, options)
		local sub = arg[i+1]
		local find = string.gsub (sub, '^([^=]+)%=.*$', '%1')
		find = string.gsub (find, "(%p)", "%%%1")
		local repl = string.gsub (sub, '^.-%=([^"]+)$', '%1')
		repl = string.gsub (repl, "(%p)", "%%%1")
		table.insert (FILTERS, { find, repl })
		return 1
	end,
	g = function (arg, i, options)
		local sub = arg[i+1]
		local find = string.gsub (sub, '^([^=]+)%=.*$', '%1')
		local repl = string.gsub (sub, '^.-%=([^"]+)$', '%1')
		table.insert (FILTERS, { find, repl })
		return 1
	end,
	h = print_help,
	help = print_help,
	q = off_messages,
	quiet = off_messages,
	v = print_version,
	version = print_version,
	doclet = function (arg, i, options)
		options.doclet = arg[i+1]
		return 1
	end,
	taglet = function (arg, i, options)
		options.taglet = arg[i+1]
		return 1
	end,
}
DEFAULT_OPTIONS = {
	output_dir = "",
	taglet = "luadoc.taglet.standard",
	doclet = "luadoc.doclet.html",
	verbose = 1,
}
function process_options (arg)
	local files = {}
	local options = DEFAULT_OPTIONS
	for i = 1, table.getn(arg) do
		local argi = arg[i]
		if string.sub (argi, 1, 1) ~= '-' then
			table.insert (files, argi)
		else
			local opt = string.sub (argi, 2)
			if string.sub (opt, 1, 1) == '-' then
				opt = string.gsub (opt, "%-", "")
			end
			if OPTIONS[opt] then
				if OPTIONS[opt] (arg, i, options) then
					i = i+1
				end
			else
				options[opt] = 1
			end
		end
	end
	return files, options
end 

-------------------------------------------------------------------------------
-- Creates a list of files, based on the given list of files/directories, 
-- recursing into directories. Only files with some defined extensions are
-- included in the list.

function filelist (files, t)
	local patterns = { ".*%.lua$", ".*%.luadoc$" }
	t = t or {}
	for i = 1, table.getn(files) do
		local f = files[i]
		local attr = lfs.attributes(f)
		assert(attr, string.format("error stating file `%s'", f))
		if attr.mode == "file" then
			for j = 1, table.getn(patterns) do
				if string.find(f, patterns[j]) ~= nil then
					table.insert(t, f)
					break
				end
			end
		elseif attr.mode == "directory" then
			for file in lfs.dir(f) do
				if file ~= "." and file ~= ".." then
					filelist({ f .. "/" .. file }, t)
				end
			end
		else
			error(string.format("invalid file `%s': %s", f, attr.mode))
		end
	end
	return t
end

function main ()
	-- Process options.
	local argc = table.getn(arg)
	if argc < 1 then
		print_help ()
	end
	local files, options = process_options (arg)

	-- recurse subdirectories
--	files = filelist(files)
	
	-- load config file
	if options.config ~= nil then
		-- load specified config file
		dofile(options.config)
	else
		-- load default config file
		require("luadoc.config")
	end
	
	local taglet = require(options.taglet)
	local doclet = require(options.doclet)

	-- analyze input
--	local doc = luadoc.analyze.analyze(files, taglet, options, FILTERS)
	taglet.options = options
	local doc = taglet.start(files)

	-- generate output
--	luadoc.compose.compose(doc, doclet, options)
	doclet.options = options
	doclet.start(doc)
end

main()
