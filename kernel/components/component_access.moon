import invoke from component

class Component
  new: (@address) =>
  invoke: (method, ...) =>
    invoke @address, method, ...

return {:Component}
