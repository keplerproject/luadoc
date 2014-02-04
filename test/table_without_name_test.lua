-- When a table is added without an explicit name tag, a nasty error occurs.

-------------------------------------------------------------
-- Test table with a name tag, this works fine
-- @class table
-- @name FirstTestTable
-- @field some just data
-- @field hello there!
myTable = {
    some = "data",
    hello = "world",
}

-------------------------------------------------------------
-- Test table without a name tag, this fails
-- @class table
-- @field some just data
-- @field hello there!
anotherTable = {
    some = "data",
    hello = "world",
}
