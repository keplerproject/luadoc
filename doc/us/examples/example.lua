------------------------------------------------------------------------------------
-- Ipsum lorum and then some. This starts after the first dot and hence does not
-- get to go in the short, but the long description. As is the remainder of the
-- text, everything until the next tag or a code line is included.
-- Interesting in this block is the explicit reference in the 'see' tag to the
-- LuaDoc website
-- @author Keplerproject
-- @author Tieske
-- @copyright This example file is free of any copyrights, but 'copyright' and
-- the symbol will be inserted on the left
-- @class module
-- @release LuaDoc testfile version 1.0


------------------------------------------------------------------------------------
-- A list with object properties. And here is the longer description again.
-- @class table
-- @name properties
-- @field verbose Boolean inicating extra verbose output
-- @field type This field contains a string with the current type, either
-- <code>"auto", "semi",</code> or <code>"manual"</code>
-- @see main_func
local properties = {
	verbose = false,
	["type"] = "manual",
}

------------------------------------------------------------------------------------
-- The main module functionality being executed. And another long description without
-- any inspiration other than lots of coffee, and it was bad coffee, and so is the
-- long description. Of special interest here is the 'example' tag which is being
-- used with a trailing '#'. This will preserve whitespace and
-- line-breaks, especially usefull to preserve the layout of example code. The '#'
-- will also work on other tags. Other than that, the 'see' tag is automatically
-- inferred because it references another, also documented, element.
-- @usage preferably call this function once, directly after requiring it
-- @param filepath The filepath to search for input files
-- @param aname Filename of the output file
-- @see properties
-- @example# for _, filename in ipairs(filepath) do
--     print("filename:", filename)
-- end
-- @return a table with all files, or <code>nil + error</code>
function main_func(filepath, aname)
	-- do some stuff here
end

------------------------------------------------------------------------------------
-- The main module functionality being executed. This is the same as above, only
-- showing what happens if there are multiple similar tags.
-- @usage preferably call this function once, directly after requiring it
-- @usage preferably call this function once, directly after requiring it, even
-- if this is twice the same 'usage' tag
-- @param filepath The filepath to search for input files
-- @param aname Filename of the output file
-- @see properties
-- @see LuaDoc http://keplerproject.github.com/luadoc/
-- @example# -- this example is multi-line, the other goes to single line in absence of the '#'
-- for _, filename in ipairs(filepath) do
--     print("filename:", filename)
-- end
-- @example for _, filename in ipairs(filepath) do
--     print("filename:", filename)
-- end
-- @return a table with all files or <code>nil</code> in case of error
-- @return <code>error</code>in case of error
function main_func2(filepath, aname)
	-- do some stuff here
end

