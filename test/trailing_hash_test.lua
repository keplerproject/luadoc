-- Run LuaDoc on this file to test the results of the tag-trailing '#'

--------------------------
-- Usage tag should be the original usage tag, concatenated and trimmed
    -- @usage for k,v in pairs(sometable) do
    --    print(k,v)
    -- end
function JustATest()
end

--------------------------
-- Usage tag includes trailing '#', should be the new format, not trimmed and linebreaks retained
    -- @usage# for k,v in pairs(sometable) do
    --    print(k,v)
    -- end
function JustAnotherTest()
end

--------------------------
-- Usage tags contains # in the middle, shouldn't be recognized as a tag
    -- @usage#forsome test1
    --    test2
    -- test3
function JustOneLastTest()
end
