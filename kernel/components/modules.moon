-- Module system

class Module
  new: (@name, @env, @callback) =>
    @env.init! if @env.init

  @prepareEnvironment: ->

  unload: =>
    @env.uninit! if @env.uninit

  
