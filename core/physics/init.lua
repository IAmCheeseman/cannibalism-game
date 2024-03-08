local cwd = (...):gsub("%.physics$", "")
local class = require(cwd .. ".class")

local physics = {}

local Body = class()

function Body:init(world, x, y, shape)
  self.shape = shape
  self.body = love.physics.newBody(world, x, y)
  self.fixture = love.physics.newFixture(self.body, self.shape)
end

local PhysicsWorld = class()
physics.PhysicsWorld = PhysicsWorld

function PhysicsWorld:init(...)
  self.world = love.physics.newWorld(...)
end

function PhysicsWorld:update()
  self.world:update(love.timer.getDelta())
end

function PhysicsWorld:newRectangleBody(x, y, ...)
  local shape = love.physics.newRectangleShape(...)
  return Body(self.world, x, y, shape)
end

function PhysicsWorld:newCircleBody(x, y, ...)
  local shape = love.physics.newCircleShape(...)
  return Body(self.world, x, y, shape)
end

function PhysicsWorld:draw()
  local bodies = self.world:getBodies()

  love.graphics.setColor(1, 0, 0)
  for _, body in ipairs(bodies) do
    local fixtures = body:getFixtures()
    for _, fixture in ipairs(fixtures) do
      if fixture:getShape():type() == 'PolygonShape' then
        love.graphics.polygon('line', body:getWorldPoints(fixture:getShape():getPoints()))
      elseif fixture:getShape():type() == 'EdgeShape' or fixture:getShape():type() == 'ChainShape' then
        local points = {body:getWorldPoints(fixture:getShape():getPoints())}
        for i = 1, #points, 2 do
          if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
        end
      elseif fixture:getShape():type() == 'CircleShape' then
        local body_x, body_y = body:getPosition()
        local shape_x, shape_y = fixture:getShape():getPoint()
        local r = fixture:getShape():getRadius()
        love.graphics.circle('line', body_x + shape_x, body_y + shape_y, r, 360)
      end
    end
  end
end

return physics
