#!/usr/local/bin/lua

-- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not package then
	if not LUA_PATH then
		LUA_PATH = [[./?.lua;./?/?.lua;c:/users/tuler/prj/kepler/cgilua_head/src/?.lua;c:/users/tuler/prj/kepler/cgilua_head/src/?/?.lua]]
	end
	require"compat-5.1"
	package.cpath = [[./?.dll]]
end

module "luadoc"

-----------------------------------------------------------------
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
}
DEFAULT_OPTIONS = {
	output_dir = "",
	taglet = "luadoc.sub",
	doclet = "luadoc.cmp",
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

function main ()
	-- Process options.
	local argc = table.getn(arg)
	if argc < 1 then
		print_help ()
	end
	local files, options = process_options (arg)
	
	local taglet = require(options.taglet)
	local doclet = require(options.doclet)

	-- analyze input
	local doc = luadoc.analyze.analyze(files, taglet, options, FILTERS)

	-- generate output
--	luadoc.compose.compose(doc, doclet, options)
--	local doclet = require(options.doclet)
	local doclet = require("luadoc.doclet.html")
	doclet.options = options
	doclet.start(doc)
	
--	local raw = require("luadoc.doclet.raw")
--	raw.start(doc)
end

main()
