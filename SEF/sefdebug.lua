#!/bin/lua

-- TODO: Change
package.path = package.path .. ';SEF/?.lua'

local args = {...}

-- Program to load sef files
local libsef = require("libsef")
local libbinio = require("libbinio")
local inspect = require "inspect"

local f = io.open(args[1])
local wrapped_io = libbinio.from_file(f)

local obj = libsef.SEFObject.load(wrapped_io)

local function findtab(tab, element)
  if not element then error("U SUK") end
  for k, v in pairs(tab) do
    if v == element then
      return k
    end
  end
end

for i = 1, #obj.sections do
  local s = obj.sections[i]
  print("=== Section #"..(i - 1).." ["..(libsef.sections[s.type] or s.type).."] ===")
  print(s.data)
  print("=== END SECTION ===")
end

for platform, mappings in pairs(obj.mappings) do
  for name, mapping in pairs(mappings) do
    print("Mapping: "..name.." ["..libsef.platforms[platform].."] -> #"..(findtab(obj.sections, mapping.section) - 1))
  end
end

for name, export in pairs(obj.exports) do
  print("Export "..name.." -> "..export.mapping..":"..export.name)
end
