-- $Id: raw.lua,v 1.3 2005/07/12 05:19:35 uid20006 Exp $

module "luadoc.doclet.raw"
require "luadoc.tab2str"

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.
-- @see luadoc.tab2str.t2s

function start (doc)
   print(luadoc.tab2str.t2s (doc, "   "))
end
