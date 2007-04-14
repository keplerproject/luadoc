
local require = require
local logging = require "logging"
require "logging.console"

module ("luadoc")

logger = logging.console("[%level] %message\n")
--logger = logging.file("luadoc.log") -- use this to get a file log

-------------------------------------------------------------------------------
-- LuaDoc version number.

_COPYRIGHT = "Copyright (c) 2003-2006 The Kepler Project"
_DESCRIPTION = "Documentation Generator Tool for the Lua language"
_VERSION = "LuaDoc 3.0 alpha 1"

-------------------------------------------------------------------------------
-- Main function
-- @see luadoc.doclet.html, luadoc.doclet.formatter, luadoc.doclet.raw
-- @see luadoc.taglet.standard

function main (files, options)
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
	taglet.logger = logger
	local doc = taglet.start(files)

	-- generate output
	doclet.options = options
	doclet.logger = logger
	doclet.start(doc)
end
