
module "luadoc.doclet.raw"
require "luadoc.tab2str"

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.
-- @see tab2str#t2s.

function start (doc)
   print(luadoc.tab2str.t2s (doc, "   "))
end
