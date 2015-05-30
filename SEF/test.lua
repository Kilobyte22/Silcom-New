local sef = dofile('libsef.lua')
local binio = dofile('libbinio.lua')
local inspect = dofile('inspect.lua')

local iolib = io
local f = iolib.open("testfile", "w")
local io = binio.to_file(f)

local obj = sef.SEFObject.new()
local section = obj:addSection(sef.sections.data, "test data")
obj:addMapping("test_mapping", sef.platforms.all, section)
obj:addExport("test_export", "test_mapping", "test_function")

obj:store(io)

f:close()

f = iolib.open("testfile", "r")
local io = binio.from_file(f)
obj = sef.SEFObject.load(io)
f:close()

print(inspect(obj:sectionForPlatform("test_mapping", sef.platforms.lua)))
