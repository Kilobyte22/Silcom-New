-- Library to load SEF files

local magic = "#!/bin/sefload\n"

local function rev_table(tab)
  local ret = {}
  for k, v in pairs(tab) do
    ret[k] = v
    ret[v] = k
  end
  return ret
end

local platforms = rev_table({
  all = 0,     -- section applies to all platforms
  silcom = 1,  -- silcom native program
  openos = 2,  -- openos native program
  lua = 3,     -- regular lua
  oc = 4       -- raw oc binary, ie entry point for an OS. Requires special bootloader
})
local sections = rev_table({
  metadata = 0,
  code = 1,
  data = 2
})

local SEFObject = {}

function SEFObject.new()
  return setmetatable({
    sections = {},
    mappings = {},
    exports = {},
    libs = {}
  }, {__index = SEFObject})
end

function SEFObject.load(io)
  local m = io:read_bytes(#magic)
  if m ~= magic then
    return nil, "Could not detect SEF signature"
  end

  local ret = SEFObject.new()
  local toc_count = io:read_number(2)

  for i = 1, toc_count do
    local type = io:read_number(2)
    local length = io:read_number(4)
    ret:addSection(type, length)
  end

  local map_count = io:read_number(2)

  for i = 1, map_count do
    local name = io:read_string(1)
    local platform = io:read_number(2)
    local section = io:read_number(2)
    ret:addMapping(name, platform, ret:getSection(section))
  end

  local ex_count = io:read_number(2)

  for i = 1, ex_count do
    local name = io:read_string(1)
    local mapping = io:read_string(1)
    local element = io:read_string(1)
    ret:addExport(name, mapping, element)
  end

  for i = 1, #ret.sections do
    ret.sections[i].data = io:read_bytes(ret.sections[i].data)
  end
  return ret
end

function SEFObject:addSection(type, data)
  local section = {type = type, data = data}
  table.insert(self.sections, section)
  return section
end

function SEFObject:removeSection(id)
  table.remove(self.sections, id - 1)
end

function SEFObject:getSection(id)
  return self.sections[id + 1]
end

function SEFObject:addMapping(name, platform, section)
  -- TODO: Check if mapping conflicts
  self.mappings[platform] = self.mappings[platform] or {}
  self.mappings[platform][name] = {name = name, section = section, platform = platform}
end

function SEFObject:store(io)
  io:write_bytes(magic)
  io:write_number(2, #self.sections)
  local section_map = {}

  for i = 1, #self.sections do
    local section = self.sections[i]
    section_map[section] = i - 1
    io:write_number(2, section.type)
    io:write_number(4, #section.data)
  end

  local mappings = {}

  for platform, sections in pairs(self.mappings) do
    for name, mapping in pairs(sections) do
      if section_map[mapping.section] then
        table.insert(mappings, mapping)
      end
    end
  end
  io:write_number(2, #mappings)

  for i = 1, #mappings do
    local m = mappings[i]
    io:write_number(1, #m.name)
    io:write_bytes(m.name)
    io:write_number(2, m.platform)
    io:write_number(2, section_map[m.section])
  end

  local exports = {}
  for symbol, export in pairs(self.exports) do
    table.insert(exports, export)
  end
  io:write_number(2, #exports)

  for i = 1, #exports do
    local e = exports[i]
    io:write_string(e.symbol, 1)
    io:write_string(e.mapping, 1)
    io:write_string(e.name, 1)
  end

  for i = 1, #self.sections do
    local section = self.sections[i]
    io:write_bytes(section.data)
  end
end

function SEFObject:addExport(symbol, mapping, name)
  self.exports[symbol] = {mapping = mapping, name = name, symbol = symbol}
end

function SEFObject:removeExport(symbol)
  self.exports[symbol] = nil
end

function SEFObject:sectionForPlatform(name, platform, exact_match)
  local ret = self.mappings[platform] and self.mappings[platform][name]
  if ret then
    return ret.section
  elseif not exact_match then
    ret = self.mappings[platforms.all] and self.mappings[platforms.all][name]
    return ret and ret.section
  end
end

function SEFObject:codeSectionForPlatform(name, platform, exact_match)
  local section = self:sectionForPlatform(name, platform, exact_match)
  if section then
    if section.type ~= sections.code then
      error("Section is not executable")
    end
    if self.libs[name] then
      return self.libs[name]
    end
    local env = self:subEnvironment()
    local data, err = load(section.data, "@" .. name, "t", env)
    if data then
      local lib = data()
      if not lib then
        lib = env
      end
      self.libs[name] = lib
      return lib
    else
      error(err)
    end
  end
end

function SEFObject:resolveExport(name)
  local export = self.exports[name]
  if export then
    return export.mapping, export.name
  end
end

function SEFObject:exportForPlatform(name, platform, exact_match)
  local mapping, func = self:resolveExport(name)
  local section = self:codeSectionForPlatform(mapping, platform or self.platform, exact_match)
  if section then
    return section[func]
  else
    error("Export "..tostring(name).." is not available for platform "..tostring(platforms[platform]))
  end
end

function SEFObject:setPlatform(plat)
  self.platform = plat
end

function SEFObject:environment()
  if self.env then return self.env end
  local sef = {
    load = function(file)
      local section = self:codeSectionForPlatform(file, self.platform)
      if section then
        return section
      else
        error("Mapping '"..file.."' not found in SEF file", 2)
      end
    end,
    data = function(file)
      local section = self:sectionForPlatform(file, self.platform)
      if not section then
        error("Mapping '"..file.."' not found in SEF file", 2)
      end
      if section.type ~= sections.code then
        error("Section '"..file.."' is no data section", 2)
      end
      return section.data
    end
  }
  self.env = {
    require = function(lib)
      if lib:sub(1, 1) == '@' then
        return sef.load(lib:sub(2))
      else
        return require(lib)
      end
    end,

    sef = sef
  }
  return self.env
end

function SEFObject:subEnvironment()
  return setmetatable({}, {__index = self:environment()})
end

return {SEFObject = SEFObject, platforms = platforms, sections = sections}
