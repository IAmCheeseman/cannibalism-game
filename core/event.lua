local cwd = (...):gsub("%.event$", "")
local class = require(cwd .. ".class")

local Event = class()

function Event:init()
  self.callbacks = {}
  self.connections = {}
end

function Event:on(fn)
  table.insert(self.callbacks, fn)
end

function Event:connect(world, type, fn)
  table.insert(self.connections, {
    world = world,
    type = type,
    fn = fn
  })
end

function Event:call(...)
  for _, callback in ipairs(self.callbacks) do
    callback(...)
  end

  for _, connection in ipairs(self.connections) do
    for obj in connection.world:iterateType(connection.type) do
      obj[connection.fn](obj, ...)
    end
  end
end

return Event
