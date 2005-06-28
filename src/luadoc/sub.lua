
---------------------------------------------------------------------------
-- "Parser" rules for interpreting the input files.

module "luadoc.sub"

require "luadoc.analyze"
local Gappend_pair = luadoc.analyze.Gappend_pair
local Tcreate = luadoc.analyze.Tcreate
local Uappend = luadoc.analyze.Uappend
local Tinsert = luadoc.analyze.Tinsert
local Ucreate = luadoc.analyze.Ucreate

---------------------------------------------------------------------------
-- Begin comment.
P_beg_comm	= "%-%-%-+"

---------------------------------------------------------------------------
-- Space (not including [[\n]]).
P_spc		= "[^%S\n]"

---------------------------------------------------------------------------
-- Not a comment.
P_n_comm	= "[^-%s]"

---------------------------------------------------------------------------
-- Identifier.
P_ident		= "[_%w%.%:][_%w%.%:]*"

---------------------------------------------------------------------------
-- Begin filter.
P_beg_filter	= "%-%-%$"

---------------------------------------------------------------------------
-- Filter pattern.
P_patt		= "\"([^\n\"]*)\""

---------------------------------------------------------------------------
-- Mark a beginning of a comment.
M_1		= "\1"

---------------------------------------------------------------------------
-- Mark an end of a comment.
M_2		= "\2"

---------------------------------------------------------------------------
-- Not used.
M_3		= "\3"

function debug (str)
	print("[["..str.."]]")
	return str
end
---------------------------------------------------------------------------
-- Lua source file description.

lua = {
	-- identifying comment filters.
	{ P_beg_filter.."%s%s-"..P_patt.."%s%s-"..P_patt.."\n", Gappend_pair ("comm_filters") },

	-- marking beginning and end of comments.
	{ "^"..P_beg_comm,			M_1 },
	{ "\n"..P_beg_comm,			"\n"..M_1 },
	{ "\n"..P_spc.."*("..P_n_comm..")",	"\n"..M_2.."%1" },

	-- identifying global comment.
	{ "^(%b"..M_1..M_2..")",	{
		-- deleting comment characters and beginning and end marks.
		{ "%-%-%-*",			"" },
		{ M_1,				"" },
		{ M_2,				"" },
		{ "@author%s+(.-%.)\n",	Ucreate("author") },
		{ "@copyright%s+(.-%.)\n",	Ucreate("copyright") },
		{ "@date%s+(.-%.)\n",		Ucreate("date") },
		{ "@title%s+(.-%.)\n",		Ucreate("title") },
		{ "^([^.]*%.)",			Ucreate("resume") },
		{ "^(.*)$",			Ucreate ("description") },
	} },

	-- identifying function definitions.
	{ M_1.."([^"..M_2.."]*)"..M_2.."function%s+("..P_ident..")%s*%((.-)%)",
		M_1.."-- @name %2.\n-- @param_list (%3).\n-- @class function.\n-- @section 2.\n%1\n"..M_2 },
	{ M_1.."([^"..M_2.."]*)"..M_2.."local%s+function%s+("..P_ident..")%s*%((.-)%)",
		M_1.."-- @name %2.\n-- @param_list (%3).\n-- @class local_function.\n-- @section 2.\n%1\n"..M_2 },
	{ M_1.."([^"..M_2.."]*)"..M_2.."%s*("..P_ident..")%s*=%s*function%s+%((.-)%)",
		M_1.."-- @name %2.\n-- @param_list (%3).\n-- @class function.\n-- @section 2.\n%1\n"..M_2 },
	{ M_1.."([^"..M_2.."]*)"..M_2.."%s*local%s+("..P_ident..")%s*=%s*function%s+%((.-)%)",
		M_1.."-- @name %2.\n-- @param_list (%3).\n-- @class function.\n-- @section 2.\n%1\n"..M_2 },
        
	-- identifying string declarations.
	{ M_1.."([^"..M_2.."]*)"..M_2.."("..P_ident..")%s*=%s*(\"[^\"]*\")",
		M_1.."-- @name %2.\n-- @class string.\n-- @section 1.\n-- @value %3.\n%1\n"..M_2 },
	{ M_1.."([^"..M_2.."]*)"..M_2.."local%s+("..P_ident..")%s*=%s*(\"[^\"]*\")",
		M_1.."-- @name %2.\n-- @class string.\n-- @section 1.\n-- @value %3.\n%1\n"..M_2 },

	-- identifying constant declarations.
	{ M_1.."([^"..M_2.."]*)"..M_2.."("..P_ident..")%s*=%s*([ .:()_\"\'%w]+)",
		M_1.."-- @name %2.\n-- @class constant.\n-- @section 1.\n-- @value %3.\n%1\n"..M_2 },
	{ M_1.."([^"..M_2.."]*)"..M_2.."local%s+("..P_ident..")%s*=%s*([ .:()_\"\'%w]+)",
		M_1.."-- @name %2.\n-- @class constant.\n-- @section 1.\n-- @value %3.\n%1\n"..M_2 },

	-- identifying table declarations.
	{ M_1.."([^"..M_2.."]*)"..M_2.."("..P_ident..")%s*=%s*(%b{})",
		M_1.."-- @name %2.\n-- @class table.\n-- @section 1.\n-- @value %3.\n%1\n"..M_2 },
	{ M_1.."([^"..M_2.."]*)"..M_2.."local%s+("..P_ident..")%s*=%s*(%b{})",
		M_1.."-- @name %2.\n-- @class table.\n-- @section 1.\n-- @value %3.\n%1\n"..M_2 },

	-- garbage collection (not necessary).
	--{ M_2..".-"..M_1,			M_2..M_1 },
	--{ M_2.."[^"..M_1.."]*$",		M_2 },

	-- processing comments.
	{ "(%b"..M_1..M_2..")",			{
		-- deleting comment characters and beginning and end marks.
		{ "%-%-%-*",			"" },
		{ M_1,				"" },
		{ M_2,				"" },
		{ "@name%s+(.-)%.\n",		Tcreate ("name") },
		{ "@param_list%s+(.-)%.\n",	Tcreate ("param_list") },
		{ "@class%s+(.-)%.\n",		Tcreate ("class") },
		{ "@section%s+(.-)%.\n",	Tcreate ("section") },
		{ "@return%s+(.-%.)\n",		Tcreate ("ret") },
		{ "@usage%s+(.-)%.\n",		Tcreate ("usage") },
		{ "@see%s+([^.]+)%.\n",		{
			{ "^(.*)$",		"%1," },
			{ "%s*([^,]+),",		Uappend ("see") },
		} },
		{ "@param%s+([_%w]+)%s+(.-)%.\n",	Tinsert ("param") },
		function (tab)
		   if tab.param_list and tab.param then
		      string.gsub (tab.param_list, "([%w_]+)", function (arg)
		      	table.insert (tab.param, arg)
		      end)
		   end
		end,
		{ "@value%s+(.-)%.\n",		Tcreate ("value") },
		{ "@value%s+(%b{})%.\n",	Tcreate ("value") },
		{ "@value%s+([^\n]+)\n.*$",	Tcreate ("value") },
		{ "^[-%s]*([^%.]-%.)\n",	Tcreate ("resume") },
		{ "\n",				"" },
		{ "  *",			" " },
		{ "^(.*)$",			Tcreate ("description") },
	} },
}

return lua
