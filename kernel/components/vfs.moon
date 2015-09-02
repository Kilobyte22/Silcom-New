class FSNode

  -- All FSNode operations are asyncronous. After calling you get some kind of event filter (usually an empty table)
  -- You then register an eventhandler for silcom:fsevent using event.EventSystem#registerHandler, passing it the filter
  -- The respective event will be raised once the operation is complete.
  -- The operation call may immediately raise the event, before returning. This is no issue however, as the event will not get processed immediately,
  -- So you still have time to register the handler
  -- Data: {node: self, op: <operation>, <additional data, depending on call>}

  -- Additional Data: fd: FileDescriptor
  open: (mode) => stub FSNode, "open"

  -- Additional Data: value: bool
  isFile: => stub FSNode, "isFile"

  -- Additional Data: value: bool
  isDirectory: => stub FSNode, "isDirectory"

  -- Additional Data: value: bool
  isLink: => stub FSNode, "isLink"

  -- name may be a path. It must however be on this file system. A safer way to get a file is using VFS#nodeForName as that respects mount points
  -- Additional Data: child: FSNode, error: string, errno: number
  getChild: (name) => stub FSNode, "getChild"

  -- grabs in iterator for a directory.
  -- Additional Data: iter: (name) -> name, node. Iterator itself must be non-blocking
  iterate: => stub FSNode, "iterate"

  -- Additional Data: success: bool, name: string
  createLink: (name, target) => stub FSNode, "createLink"

  -- Additional Data: stat: <table of stat data>
  stat: (name) => stub FSNode, "stat"


class FileDescriptor

  -- Some FileDescriptor operations are asyncronous. After calling you get some kind of event filter (usually an empty table)
  -- You then register an eventhandler for silcom:fdevent using event.EventSystem#registerHandler, passing it the filter
  -- The respective event will be raised once the operation is complete.
  -- The operation call may immediately raise the event, before returning. This is no issue however, as the event will not get processed immediately,
  -- So you still have time to register the handler

  specialMethods: => {}
  -- SYNC
  readable: => stub FileDescriptor, "readable"
  -- SYNC
  writeable: => stub FileDescriptor, "writeable"

  new: (@node) =>

  @defaultMethods: {"close", "canRead", "canWrite", "canIterate", "isDirectory", "isFile", "isLink"}

  -- SYNC
  methods: =>
    @allMethods = table.combine @@defaultMethods, @specialMethods! unless @allMethods
    @allMethods

  -- ASYNC
  invoke: (method, params) =>
    if table.find @methods!, method
      @["m_"..method](@, table.unpack(params))

  m_close: => stub FileDescriptor, "m_close"
  m_canRead: => @node.isFile! and @readable!
  m_canWrite: => @node.isFile! and @writeable!
  m_canIterate: => @node.isDirectory!
  m_isDirectory: => @node.isDirectory!
  m_isFile: => @node.isFile!
  m_isLink: => @node.isLink!


class VFS
  new: (@root) =>

  swapRoot: (newRoot, oldPoint) =>
    -- Requires: newRoot MUST be already mounted
    -- Requires: oldPoint MUST be a valid mount point

    -- Will move the current root to the mountpoint specified by oldPoint
    -- oldPoint is relative to newRoot
    -- Will replace current root with newRoot

  nodeForName: (name) =>
    assert name\sub(1, 1) == '/', "File name not absolute"
    return @root if name == '/'
    tmp = @root
    for element in name\sub(2)\gmatch("[^/]+")
      tmp = tmp\getChild element
    tmp

  mount: (point, node)

return {:VFS, :FileDescriptor, :FSNode}
