local event = {}

local callbacks = {}

local function confirmEventExists(name)
  if event.exists(name) then
    error("Event '" .. name .. "' does not exist")
  end
end

function event.define(name)
  callbacks[name] = {
    callbacks = {},
    connections = {},
  }
end

function event.exists(name)
  return not callbacks[name]
end

function event.on(name, fn)
  confirmEventExists(name)
  table.insert(callbacks[name].callbacks, fn)
end

function event.connect(name, world, type, fn)
  confirmEventExists(name)
  table.insert(callbacks[name].connections, {
    world = world,
    type = type,
    fn = fn
  })
end

function event.call(name, ...)
  confirmEventExists(name)

  for _, callback in ipairs(callbacks[name].callbacks) do
    callback(...)
  end

  for _, connection in ipairs(callbacks[name].connections) do
    for _, obj in connection.world:iterateType(connection.type) do
      obj[connection.fn](obj, ...)
    end
  end
end

function event.defineLoveEvents()
  local loveEvents = {
    "directorydropped", "displayrotated", "filedropped", "focus", "mousefocus",
    "resize", "visible", "keypressed", "keyreleased", "textedited", "textinput",
    "mousemoved", "mousepressed", "mousereleased", "wheelmoved", "gamepadaxis",
    "gamepadpressed", "gamepadreleased", "joystickadded", "joystickaxis",
    "joystickhat", "joystickpressed", "joystickreleased", "joystickremoved",
    "touchmoved", "touchpressed", "touchreleased"
  }

  for _, callback in ipairs(loveEvents) do
    event.define(callback)
    love[callback] = function(...)
      event.call(callback, ...)
    end
  end

  event.call("loveEventsMade")
end

event.define("loveEventsMade")

return event
