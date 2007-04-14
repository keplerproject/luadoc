# $Id: Makefile,v 1.3 2007/04/14 04:20:42 tomas Exp $

LUA_DIR= /usr/local/share/lua/5.1
LUADOC_DIR= $(LUA_DIR)/luadoc
DOCLET_DIR= $(LUADOC_DIR)/doclet
HTML_DIR= $(DOCLET_DIR)/html
TAGLET_DIR= $(LUADOC_DIR)/taglet
STANDARD_DIR= $(TAGLET_DIR)/standard
LAUNCHER_DIR= /usr/local/bin
LUADOC_REFMAN= doc/refman

LUADOC_LUAS= src/luadoc/config.lua \
	src/luadoc/init.lua \
	src/luadoc/lp.lua \
	src/luadoc/util.lua
DOCLET_LUAS= src/luadoc/doclet/debug.lua \
	src/luadoc/doclet/formatter.lua \
	src/luadoc/doclet/html.lua \
	src/luadoc/doclet/raw.lua
HTML_LUAS= src/luadoc/doclet/html/file.lp \
	src/luadoc/doclet/html/function.lp \
	src/luadoc/doclet/html/index.lp \
	src/luadoc/doclet/html/luadoc.css \
	src/luadoc/doclet/html/menu.lp \
	src/luadoc/doclet/html/module.lp \
	src/luadoc/doclet/html/table.lp
TAGLET_LUAS= src/luadoc/taglet/standard.lua
STANDARD_LUAS= src/luadoc/taglet/standard/tags.lua

LAUNCHER= $(LAUNCHER_DIR)/luadoc
LAUNCHER_SRC= src/luadoc.lua


build clean:

install:
	mkdir -p $(LUADOC_DIR)
	cp $(LUADOC_LUAS) $(LUADOC_DIR)
	mkdir -p $(DOCLET_DIR)
	cp $(DOCLET_LUAS) $(DOCLET_DIR)
	mkdir -p $(HTML_DIR)
	cp $(HTML_LUAS) $(HTML_DIR)
	mkdir -p $(TAGLET_DIR)
	cp $(TAGLET_LUAS) $(TAGLET_DIR)
	mkdir -p $(STANDARD_DIR)
	cp $(STANDARD_LUAS) $(STANDARD_DIR)
	mkdir -p $(LAUNCHER_DIR)
	cp $(LAUNCHER_SRC) $(LAUNCHER)
	chmod a+x $(LAUNCHER)

refman:
	mkdir -p $(LUADOC_REFMAN)
	$(LAUNCHER) -d $(LUADOC_REFMAN) src/luadoc
