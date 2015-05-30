ret = {}
c = (name) ->
  component = require "@components/#{name}"
  _G[name] = component
  ret[name] = component
