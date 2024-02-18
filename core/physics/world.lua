local cwd = (...):gsub("%.physics.world$", "")
local class = require(cwd .. ".class")
local SpatialPartition = require(cwd .. ".physics.partition")

local PhysicsWorld = class()

PhysicsWorld.drawShapes = false

function PhysicsWorld:init(gridSize, partitionCount)
  gridSize = gridSize or 128
  partitionCount = partitionCount or 64

  self.partition = SpatialPartition(gridSize, partitionCount)
end

function PhysicsWorld:addBody(body)
  body:setWorld(self)
  self.partition:addBody(body)
end

function PhysicsWorld:draw()
  if not PhysicsWorld.drawShapes then
    return
  end

  for body, _ in pairs(self.partition.bodies) do
    love.graphics.setColor(body:getColor())
    local shape = body.shape
    local anchor = body.anchor
    local x, y = anchor.x + shape.offsetx, anchor.y + shape.offsety
    love.graphics.rectangle("fill", x, y, shape.width, shape.height)
  end
  love.graphics.setColor(1, 1, 1)
end

return PhysicsWorld
