package = "LuaDoc"
version = "cvs-1"
source = {
   url = "cvs://:pserver:anonymous:@cvs.luaforge.net:/cvsroot/luadoc",
   cvs_tag = "HEAD",
}
description = {
   summary = "LuaDoc is a documentation tool for Lua source code",
   detailed = [[
      	LuaDoc is a documentation generator tool for Lua source code.
	It parses the declarations and documentation comments in a set of
	Lua source files and produces a set of XHTML pages describing the
	commented declarations and functions.

	The output is not limited to XHTML. Other formats can be generated
	by implementing new doclets. The format of the documentation comments
	is also flexible and can be customized by implementing new taglets.
   ]],
   license = "MIT/X11",
   homepage = "http://luadoc.luaforge.net/"
}
dependencies = {
   "lualogging >= 1.1.3",
   "luafilesystem >= 1.2.1",
}
build = {
   type = "make",
   variables = {
      LUA_DIR = "$(LUADIR)",
      SYS_BINDIR = "$(BINDIR)"
   }
}

