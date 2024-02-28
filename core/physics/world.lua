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

function PhysicsWorld:removeBody(body)
  self.partition:removeBody(body)
end

function PhysicsWorld:draw()
  if not PhysicsWorld.drawShapes then
    return
  end

  for body, _ in pairs(self.partition.bodies) do
    love.graphics.setColor(body:getColor())

    local shape = body.shape
    local x, y = body:getPosition()
    love.graphics.rectangle("fill", x, y, shape.width, shape.height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.partition:findPartitionFor(x, y), x, y)
  end
  love.graphics.setColor(1, 1, 1)
end

return PhysicsWorld
