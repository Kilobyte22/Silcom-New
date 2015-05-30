import yield from coroutine

_G.panic = (message) ->
  error("Kernel Panic: "..message)
_G.halt = -> while true do yield!
