-- Early gpu stuff

import Component from component_access

gpu = Component component.list("gpu")!
screen = Component component.list("screen")!

hpos = 1

getResolution = ->
  gpu\invoke("getResolution")

clear = ->
  hpos = 1 if gpu\invoke "fill", 1, 1, getResolution!, " "

getHeight = ->
  h, w = getResolution!
  h

scroll = (amt = 1) ->
  h, w = getResolution!
  gpu\invoke "copy", 1, 1 + amt, h - amt, w, 0, -1

earlylog = (line) ->
  if gpu and screen
    scroll! if hpos == getHeight!
    gpu\invoke "set", 1, hpos, line
    hpos += 1 unless hpos == getHeight!

clear!

return {:earlylog, :scroll, :clear}
