export Process, Thread

class Process
  @nextpid: 0

  new: =>
    @id = @@nextpid
    @@nextpid += 1
    -- Standalone means that a process has had an exec call after the spawn() syscall that created it
    @standalone = false

  spawn: =>
    Process!

  exec: (sef) =>
    @environment = sef\environment!
    cb = sef\exportForPlatform "main"
    t = Thread cb

  run: =>

class Thread
  new: (callback, @process) =>
    @runnable = true
    @routine = coroutine.create(callback)
    @returnargs = {}

  run: =>
    panic "Trying to resume not runnable thread" unless @runnable

    coroutine.resume(@routine, table.unpack(@returnargs))
