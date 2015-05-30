export kmain

kernelComponents = nil

kmain = (params) ->
  kernelComponents = require "@components"
  for name, component in pairs kernelComponents
    if component.init
      component.init!
      gpu.earlylog "Initialized#{name}"

    _G[name] = component
  gpu.earlylog "Kernel Loaded successfully"
  core.halt!
