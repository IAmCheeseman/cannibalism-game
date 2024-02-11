local cwd = (...):gsub("%.init$", "")

local physics = {}

local bodies = require(cwd .. ".body")

physics.PhysicsWorld = require(cwd .. ".world")
physics.SolidBody = bodies.Solid
physics.AbstractBody = bodies.Abstract

function physics.makeAabb(...)
  local args = {...}
  local offsetx, offsety, width, height = 0, 0, 0, 0
  if #args == 4 then
    offsetx = args[1]
    offsety = args[2]
    width = args[3]
    height = args[4]
  elseif #args == 2 then
    width = args[1]
    height = args[2]
  elseif #args == 1 then
    width = args[1]
    height = args[1]
  elseif #args == 3 then
    offsetx = args[1]
    offsety = args[2]
    width = args[3]
    height = args[3]
  end

  return {
    offsetx = offsetx,
    offsety = offsety,
    width = width,
    height = height,
  }
end

return physics
