function class(name, superclass)
  local klass = setmetatable({}, {__index = superclass})

  function klass.new()
    local obj = setmetatable({}, {__index = klass})
    if obj.init then
      obj:init()
    end
    return obj
  end

  return klass
end
