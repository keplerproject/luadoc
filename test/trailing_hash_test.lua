-- Run LuaDoc on this file to test the results of the tag-trailing '#'

--------------------------
-- example tag should be the original example tag, concatenated and trimmed
    -- @example for k,v in pairs(sometable) do
    --    print(k,v)
    -- end
function JustATest()
end

--------------------------
-- example tag includes trailing '#', should be the new format, not trimmed and linebreaks retained
    -- @example# for k,v in pairs(sometable) do
    --    print(k,v)
    -- end
function JustAnotherTest()
end

--------------------------
-- example tags contains # in the middle, shouldn't be recognized as a tag
    -- @example#forsome test1
    --    test2
    -- test3
function JustOneLastTest()
end
