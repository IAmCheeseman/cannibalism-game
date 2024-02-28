local cwd = (...):gsub("%.physics.body$", "")
local class = require(cwd .. ".class")
local mathf = require(cwd .. ".mathf")

local function aabbX(x1, w1, x2, w2)
  return x1 + w1 > x2
     and x2 + w2 > x1
end

local function aabbY(y1, h1, y2, h2)
  return y1 + h1 > y2
     and y2 + h2 > y1
end

local function aabb(x1, y1, w1, h1, x2, y2, w2, h2)
  return aabbX(x1, w1, x2, w2) and aabbY(y1, h1, y2, h2)
end

local bodies = {}

local Body = class()
bodies.Body = Body

function Body:init(type, anchor, shape, options)
  self.type = type
  self.anchor = anchor
  self.shape = shape
  local layers = options.layers or {"default"}
  local mask = options.mask or {"default"}

  local addLayerNames = function(l)
    local n = {}
    for _, v in ipairs(l) do
      n[v] = true
    end
    return n
  end

  self.layers = addLayerNames(layers)
  self.mask = addLayerNames(mask)

  self.isOnFloor = false
  self.isOnCeiling = false
  self.isOnWall = false
  self.isOnLeftWall = false
  self.isOnRightWall = false
end

function Body:getPosition()
  return self.anchor.x + self.shape.offsetx, self.anchor.y + self.shape.offsety
end

function Body:setWorld(world)
  self.world = world
end

function Body:getColor()
  return 1, 1, 1, 0.5
end

local SolidBody = class(Body)
bodies.Solid = SolidBody

function SolidBody:init(anchor, shape, options)
  self:base("init", "solid", anchor, shape, options)
end

function SolidBody:resolveAabb(other, velx, vely)
  if other == self then
    return velx, vely
  end

  local dt = love.timer.getDelta()

  local sShape = self.shape
  local oShape = other.shape
  local currentx, currenty = self.anchor.x + sShape.offsetx, self.anchor.y + sShape.offsety
  local ox, oy = other.anchor.x + oShape.offsetx, other.anchor.y + oShape.offsety

  local nextx = currentx + velx * dt
  local nexty = currenty + vely * dt

  if aabb(nextx, nexty, sShape.width, sShape.height,
          ox, oy, oShape.width, oShape.height) then
    if aabbX(currentx, sShape.width, ox, oShape.width) then
      if vely >= 0 then -- Down
        self.isOnFloor = true
        self.anchor.y = oy - sShape.height - sShape.offsety
      else -- Up
        self.isOnCeiling = true
        self.anchor.y = oy + oShape.height - sShape.offsety
      end
      vely = 0
    elseif aabbY(currenty, sShape.height, oy, oShape.height) then
      self.isOnWall = true
      if velx >= 0 then -- Right
        self.isOnRightWall = true
        self.anchor.x = ox - sShape.width - sShape.offsetx
      else -- Left
        self.isOnLeftWall = true
        self.anchor.x = ox + oShape.width - sShape.offsetx
      end
      velx = 0
    end
  end

  return velx, vely
end

function SolidBody:moveAndCollide(velx, vely)
  local dt = love.timer.getDelta()

  self.isOnFloor = false
  self.isOnCeiling = false
  self.isOnWall = false
  self.isOnLeftWall = false
  self.isOnRightWall = false

  local neighbors = self.world.partition:getNeighbors(self)

  for _, neighbor in ipairs(neighbors) do
    for _, body in ipairs(neighbor) do
      -- verify it's in our masks
      for mask, _ in pairs(self.mask) do
        if body.layers[mask] then
          velx, vely = self:resolveAabb(body, velx, vely)
          break
        end
      end
    end
  end

  self.anchor.x = self.anchor.x + velx * dt
  self.anchor.y = self.anchor.y + vely * dt

  self.world.partition:updateBody(self)

  return velx, vely
end

function SolidBody:getColor()
  return 1, 0, 0, 0.5
end

local AbstractBody = class(Body)
bodies.Abstract = AbstractBody

function AbstractBody:init(anchor, shape, options)
  self:base("init", "abstract", anchor, shape, options)
end

function AbstractBody:update()
  self.world.partition:updateBody(self)
end

function AbstractBody:getColliding()
  local colliding = {}

  local neighbors = self.world.partition:getNeighbors(self)

  for _, neighbor in ipairs(neighbors) do
    for _, body in ipairs(neighbor) do
      local sx, sy = self:getPosition()
      local ox, oy = body:getPosition()
      if body ~= self and aabb(
        sx, sy, self.shape.width, self.shape.height,
        ox, oy, body.shape.width, body.shape.height) then

        -- verify it's in our masks
        for mask, _ in pairs(self.mask) do
          if body.layers[mask] then
            table.insert(colliding, body)
            break
          end
        end

      end

    end
  end

  return colliding
end

function AbstractBody:isColliding()
  self.world.partition:updateBody(self)

  local neighbors = self.world.partition:getNeighbors(self)

  for _, neighbor in ipairs(neighbors) do
    for _, body in ipairs(neighbor) do
      -- verify it's in our masks
      local sx, sy = self:getPosition()
      local ox, oy = body:getPosition()
      local isAabb = aabb(
        sx, sy, self.shape.width, self.shape.height,
        ox, oy, body.shape.width, body.shape.height)
      for mask, _ in pairs(self.mask) do
        if body.layers[mask] and isAabb then
          return true
        end
      end
    end
  end

  return false
end

function AbstractBody:getColor()
  return 0, 0, 1, 0.5
end

return bodies
