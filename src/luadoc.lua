#!/usr/local/bin/lua50

-- compatibility code for Lua version 5.0 providing 5.1 behavior
if string.find (_VERSION, "Lua 5.0") and not package then
	if not LUA_PATH then
		LUA_PATH = [[./?.lua;./?/?.lua;../../lualogging/src/?.lua;../../lualogging/src/?/?.lua;../../compat/src/?.lua;../../luadoc/src/?.lua]]
	end
	require"compat-5.1"
	package.cpath = [[./?.dll;../../luafilesystem/bin/vc6/?.dll]]
end

module "luadoc"

require "logging"
require "logging.console"
logger = logging.console("[%level] %message\n")
--logger = logging.file("luadoc.log")

-------------------------------------------------------------------------------
-- LuaDoc version number.

_NAME = "LuaDoc"
_DESCRIPTION = "Documentation Generator Tool for the Lua language"
_VERSION = "3.0.0"
_COPYRIGHT = "Copyright (c) 2003-2005 The Kepler Project"

-------------------------------------------------------------------------------
-- Print version number.

function print_version ()
	print (string.format("%s %s\n%s\n%s", _NAME, _VERSION, _DESCRIPTION, _COPYRIGHT))
end

-------------------------------------------------------------------------------
-- Print usage message.

function print_help ()
	print ("Usage: "..arg[0]..[[ [options|files]
Extract documentation from files.  Available options are:
  -d path                      output directory path
  -t path                      template directory path
  -h, --help                   print this help and exit
      --noindexpage            do not generate global index page
      --files                  generate documentation for files
      --modules                generate documentation for modules
      --doclet doclet_module   doclet module to generate output
      --taglet taglet_module   taglet module to parse input code
  -q, --quiet                  suppress all normal output
  -v, --version                print version information]])
end

function off_messages (arg, i, options)
	options.verbose = nil
end

-------------------------------------------------------------------------------
-- Process options
-- @class table
-- @name OPTIONS

OPTIONS = {
	d = function (arg, i, options)
		local dir = arg[i+1]
		if string.sub (dir, -2) ~= "/" then
			dir = dir..'/'
		end
		options.output_dir = dir
		return 1
	end,
	t = function (arg, i, options)
		local dir = arg[i+1]
		if string.sub (dir, -2) ~= "/" then
			dir = dir..'/'
		end
		options.template_dir = dir
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

-------------------------------------------------------------------------------

function process_options (arg)
	local files = {}
	local options = require "luadoc.config"
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
					i = i + 1
				end
			else
				options[opt] = 1
			end
		end
	end
	return files, options
end 

-------------------------------------------------------------------------------
-- Main function
-- @see luadoc.doclet.html, luadoc.doclet.formatter, luadoc.doclet.raw
-- @see luadoc.taglet.standard

function main (arg)
	-- Process options
	local argc = table.getn(arg)
	if argc < 1 then
		print_help ()
		return
	end
	local files, options = process_options (arg)
	
	if options.verbose then
		logger:setLevel(logging.INFO)
	else
		logger:setLevel(logging.WARN)
	end

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
	taglet.options = options
	local doc = taglet.start(files)

	-- generate output
	doclet.options = options
	doclet.start(doc)
end

main(arg)
