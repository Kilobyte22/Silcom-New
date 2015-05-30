

local BinaryReader = {}

function BinaryReader:read_number(bytes)
  local data = self:read_bytes(bytes)
  if not data then
    error("Could not read number: end of stream")
  end
  local value = 0
  for i = 1, bytes do
    value = value * 256 + data:sub(i):byte()
  end
  return value
end

function BinaryReader:read_string(len_count)
  local len = self:read_number(len_count or 4)
  return self:read_bytes(len)
end

local StringReader = setmetatable({}, {__index = BinaryReader})

function StringReader:read_bytes(count)
  if self.pos > #(self.data) then
    return nil, "End of stream"
  end
  local data = self.pos:sub(self.pos, count)
  self.pos = self.pos + count
  return data
end

local FileReader = setmetatable({}, {__index = BinaryReader})

function FileReader:read_bytes(count)
  return self.file:read(count)
end

local BinaryWriter = {}

function BinaryWriter:write_number(bytes, number)
  --print("Number " .. number)
  for byteid = bytes - 1, 0, -1 do
    local byte = math.floor(number / 256 ^ byteid)
    self:write_bytes(string.char(byte))
    number = number % 256 ^ byteid
    --print("Byte: " .. byte .. " - Number now " .. number)
  end
  assert(number == 0)
end

function BinaryWriter:write_string(data, len_count)
  self:write_number(len_count or 4, #data)
  self:write_bytes(data)
end

local StringWriter = setmetatable({}, {__index = BinaryWriter})

function StringWriter:write_bytes(data)
  self.data = self.data..data
end

local FileWriter = setmetatable({}, {__index = BinaryWriter})

function FileWriter:write_bytes(data)
  self.file:write(data)
end

local function from_string(string)
  local obj = {data = string, pos = 1}
  setmetatable(obj, {__index = StringReader})
  return obj
end

local function from_file(file)
  local obj = {file = file}
  setmetatable(obj, {__index = FileReader})
  return obj
end

local function to_string(data)
  local obj = {data = data}
  setmetatable(obj, {__index = StringWriter})
  return obj
end

local function to_file(file)
  local obj = {file = file}
  setmetatable(obj, {__index = FileWriter})
  return obj
end

return {from_file = from_file, from_string = from_string, to_file = to_file, to_string = to_string}
