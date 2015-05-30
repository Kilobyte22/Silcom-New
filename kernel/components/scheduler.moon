export Scheduler

-- TODO: Optimize performance, as this is critical code section

class Scheduler
  nextPossibleThread: =>
    -- TODO: Grab thread

  run: =>
    while true
      thread = @nextPossibleThread!

      panic "Could not find runnable thread" unless thread

      thread\run!


      if @hasRunnableThread!
        -- TODO: schedule timer to ensure even polling does not block
        -- Otherwise, it may block until an event
        nil

      -- TODO: Poll events
