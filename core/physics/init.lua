local cwd = (...):gsub("%.physics$", "")
local class = require(cwd .. ".class")
local logging = require(cwd .. ".logging")

local physics = {}

local fixtureToBody = {}

local Body = class()

function Body:init(world, opts, shape)
  self.shape = shape
  self.body = love.physics.newBody(world, opts.x or 0, opts.y or 0, opts.type)
  self.fixture = love.physics.newFixture(self.body, self.shape)

  self.fixture:setRestitution(opts.restitution or self.fixture:getRestitution())
  self.fixture:setDensity(opts.density or self.fixture:getDensity())
  self.fixture:setFriction(opts.friction or self.fixture:getFriction())
  self.fixture:setSensor(opts.sensor or false)

  if opts.mask then
    self.fixture:setMask(unpack(opts.mask))
  end
  if opts.category then
    self.fixture:setCategory(unpack(opts.category))
  end

  -- local category, mask, group = self.fixture:getFilterData()
  -- self.fixture:setFilterData(category, bit.bnot(mask), group)

  self.body:setFixedRotation(opts.rotationFixed or false)

  self.anchor = opts.anchor
  self.followAnchor = opts.followAnchor

  self.collisions = {}

  fixtureToBody[self.fixture] = self
end

function Body:setPosition(x, y)
  self.body:setPosition(x, y)
end

function Body:getX()
  return self.body:getX()
end

function Body:getY()
  return self.body:getY()
end

function Body:update()
  if self.followAnchor then
    self:setPosition(self.anchor.x, self.anchor.y)
  end
end

function Body:getPosition()
  return self:getX(), self:getY()
end

function Body:getCenterOfMass()
  return self.body:getWorldCenter()
end

function Body:setFixedRotation(to)
  self.body:setFixedRotation(to)
end

function Body:isRotationFixed()
  return self.body:isFixedRotation()
end

function Body:setRotation(rot)
  self.body:setAngle(rot)
end

function Body:getRotation()
  return self.body:getAngle()
end

function Body:setVelocity(velx, vely)
  self.body:setLinearVelocity(velx, vely)
end

function Body:getVelocity()
  return self.body:getLinearVelocity()
end

function Body:setActive(active)
  self.body:setActive(active)
end

function Body:getActive()
  return self.body:isActive()
end

function Body:toggleActive()
  self:setActive(not self:getActive())
end

function Body:addCollision(body, coll)
  self.collisions[body] = coll
end

function Body:removeCollision(body)
  self.collisions[body] = nil
end

function Body:getCollisions()
  return self.collisions
end

function Body:destroy()
  if self.body:isDestroyed() then
    logging.warning("Body beloning to '" .. tostring(self.anchor) ..  "' already destroyed.")
    return
  end

  self.body:destroy()
  self.shape:release()

  fixtureToBody[self.fixture] = nil
end

local function onContactBegin(a, b, coll)
  local ab = fixtureToBody[a]
  local bb = fixtureToBody[b]
  ab:addCollision(bb, coll)
  bb:addCollision(ab, coll)
end

local function onContactEnd(a, b, _)
  local ab = fixtureToBody[a]
  local bb = fixtureToBody[b]
  ab:removeCollision(bb)
  bb:removeCollision(ab)
end

local PhysicsWorld = class()
physics.PhysicsWorld = PhysicsWorld
physics.draw = false

function PhysicsWorld:init(...)
  self.world = love.physics.newWorld(...)
  self.world:setCallbacks(onContactBegin, onContactEnd, nil, nil)
end

function PhysicsWorld:update()
  self.world:update(love.timer.getDelta())
end

function PhysicsWorld:newRectangleBody(opts)
  local shape = love.physics.newRectangleShape(unpack(opts.shape))
  return Body(self.world, opts, shape)
end

function PhysicsWorld:newCircleBody(opts)
  local shape = love.physics.newCircleShape(unpack(opts.shape))
  return Body(self.world, opts, shape)
end

function PhysicsWorld:draw()
  if not physics.draw then
    return
  end

  local bodies = self.world:getBodies()

  love.graphics.setLineStyle("rough")
  -- I stole this code from https://github.com/a327ex/windfield/blob/master/windfield/init.lua#L76
  for _, body in ipairs(bodies) do
    local fixtures = body:getFixtures()
    for _, fixture in ipairs(fixtures) do
      if fixture:isSensor() then
        if body:isActive() then
          love.graphics.setColor(0, 0, 1, 0.5)
        else
          love.graphics.setColor(0, 0, 0.5, 0.5)
        end
      else
        if body:isActive() then
          love.graphics.setColor(1, 0, 0, 0.5)
        else
          love.graphics.setColor(0.5, 0, 0, 0.5)
        end
      end

      if fixture:getShape():type() == "PolygonShape" then
        love.graphics.polygon("line", body:getWorldPoints(fixture:getShape():getPoints()))
      elseif fixture:getShape():type() == "EdgeShape" or fixture:getShape():type() == "ChainShape" then
        local points = {body:getWorldPoints(fixture:getShape():getPoints())}
        for i = 1, #points, 2 do
          if i < #points-2 then love.graphics.line(points[i], points[i+1], points[i+2], points[i+3]) end
        end
      elseif fixture:getShape():type() == "CircleShape" then
        local body_x, body_y = body:getPosition()
        local shape_x, shape_y = fixture:getShape():getPoint()
        local r = fixture:getShape():getRadius()
        love.graphics.circle("line", body_x + shape_x, body_y + shape_y, r, 360)
      end
    end
  end
end

return physics
