import queueSignal, pullSignal from computer

-- TODO: Tweak performance

class EventSystem
  new: =>
    @handlers = {}
  process: (options = {}) =>
    -- Processes events
    queueSignal "silcom:end_of_event" unless options.block

    if options.block
      -- Only process one event
      handleEvent table.pack(pullSignal)

  handleEvent: (event) =>
    name = event[1]
    local filter, params
    if name:sub(1, 7) == 'silcom:'
      -- Special silcom event
      params = event[3,]
      filter = params[2].filter
    else
      params = event[2,]

    for k, v in ipairs @handlers
      unless filter and v.filter and filter != v.filter
        v.handler {:filter, :name}, table.unpack(params)

  registerHandler: (event, filter, handler) =>
    handler = filter unless handler
    @handlers[event] = @handlers[event] or {}
    table.insert(@handlers[event], :handler, :filter)

  sendEvent: (name, data, options = {}) =>
    if name:sub(1, 7) == 'silcom:'
      queueSignal name, options, data
    else
      queueSignal name, table.unpack data
