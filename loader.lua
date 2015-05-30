-- Silcom Stage 2 bootloader

-- Build script will inject libraries here
-- [[LIBS]]

-- load files

local options = {kernel = "silcom", kparam = {}}

local root = {}
function root.invoke(method, ...)
  return component.invoke(computer.getBootAddress(), method, ...)
end
function root.open(file) return root.invoke("open", file) end
function root.read(handle, amount) return root.invoke("read", handle, amount or math.huge) end
function root.close(handle) return root.invoke("close", handle) end
function root.isDirectory(path) return root.invoke("isDirectory", path) end

-- Small file wrapper

local File = {}
function File:read(len)
  if len == '*a' or len == '*all' then
    return root.read(self.file)
  end
  return root.read(self.file, len)
end
function File:close()
  root.close(self.file)
end
local function open(file)
  local f, err = root.open(file)
  if not f then
    return nil, err
  end
  return setmetatable({file = f}, {__index = File})
end

-- Load kernel into memory
local file, err = open(options.kernel)
if not file then
  error(err)
end
local kernelio = libbinio.from_file(file)
local kernel = libsef.SEFObject.load(kernelio)

kernel:setPlatform(libsef.platforms.oc)

local env = kernel:environment()
setmetatable(env, {__index = _ENV})

-- Boot kernel
local kmain = kernel:exportForPlatform("kmain")
local err_
xpcall(function ()
  kmain(options.kparam)
  error("Kernel Exited")
end, function (err)
  err_ = "Raw kernel error: "..tostring(err).."\n"..debug.traceback()
end)

error(err_ or "WTF THIS SHOULD NEVER HAPPEN AT ALL")
