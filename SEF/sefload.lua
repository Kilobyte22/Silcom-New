#!/bin/lua

-- TODO: Change
package.path = package.path .. ';../SEF/?.lua'

local args = {...}

-- Program to load sef files
local libsef = require("libsef")
local libbinio = require("libbinio")

-- Platform selector
local platform
if component then
  platform = libsef.platforms.openos
else
  platform = libsef.platforms.lua
end

local f = io.open(args[1])
local wrapped_io = libbinio.from_file(f)

local obj = libsef.SEFObject.load(wrapped_io)

obj:setPlatform(platform)
local env = obj:environment()
setmetatable(env, {__index = _ENV})

obj:exportForPlatform("main", platform)(table.unpack(args, 2))
