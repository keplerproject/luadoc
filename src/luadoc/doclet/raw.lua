-- $Id: raw.lua,v 1.2 2005/07/11 15:03:46 uid20006 Exp $

module "luadoc.doclet.raw"
require "luadoc.tab2str"

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.
-- @see tab2str#t2s.

function start (doc)
   print(luadoc.tab2str.t2s (doc, "   "))
end
