import yield from coroutine

_G.panic = (message) ->
  error("Kernel Panic: "..message)
_G.halt = -> while true do yield!
_G.stub = (class, method) ->
  error("Attempt to access stub #{class.__name}\\#{method}")

table.merge = (target, source) ->
  ret = {}
  for k, v in pairs target do ret[k] = v
  for k, v in pairs source do ret[k] = v
  ret

table.combine = (...) ->
  ret = {}
  for tab in ipairs table.unpack ...
    for k, v in ipairs(table1) do table.insert(ret, v)
  ret

table.find = (table, value) ->
  for k, v in pairs(table)
    return k if value == v

_G.b = (value) => not not value
