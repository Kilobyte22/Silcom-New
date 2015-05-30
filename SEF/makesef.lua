package.path = package.path .. ';../SEF/?.lua'

local libsef = require("libsef")
local libbinio = require("libbinio")

local obj = libsef.SEFObject.new()



local env = {
  addSection = function(type, data)
    return obj:addSection(type, data)
  end,

  addMapping = function(name, platform, section)
    obj:addMapping(name, platform, section)
  end,

  addExport = function(symbol, mapping, name)
    obj:addExport(symbol, mapping, name)
  end,

  platforms = libsef.platforms,
  sections = libsef.sections,

  file = function(name)
    local f = io.open(name, "r")
    local data = f:read('*a')
    f:close()
    return data
  end,

  outfile = "out.sef"
}

setmetatable(env, {__index = _ENV})

local cfile = env.file("sefconfig")

load(cfile, "sefconfig", "t", env)()

local f = io.open(env.outfile, "w")
local wio = libbinio.to_file(f)

obj:store(wio)

f:close()
