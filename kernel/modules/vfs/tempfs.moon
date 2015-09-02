import FileDescriptor, FSNode from vfs

export init, uninit, metadata

metadata = {
  name: "tempfs"
  authors: {"Kilobyte"}
  version: "0.0.1"
  license: "MIT"
}

nodetype = {
  directory: 1
  file: 2
  symlink: 3
}

class TempNode extends FSNode
  new: (@type, @driver, @parent = self, options) =>
    if @type == 3
      @target = options.target
    @cildren = {"..", "."}

  -- TODO: Make work with symlinks. @target is a string
  isDirectory: => @type == 1 -- or (@type == 3 and @target\isDirectory!)
  isFile: => @type == 2 -- or (@type == 3 and @target\isFile!)
  isSymlink: => @type == 3

  getChild: (name) => @children[name]
  iterate: =>  pairs(@children)

class TempFSDriver
  new: (@vfs) =>
  createMount: (fs, options) ->
    true, TempNode 1, @

init = ->
  registerDriver "filesystem", "tempfs", TempFSDriver
