local Player = require("player")

local Corpse = class(WorldObj)

function Corpse:init(x, y, angle, strength, sprite)
  self:base("init")
  self.x = x
  self.y = y
  self.sprite = sprite

  self.outline = core.shader.new("outline", "outline.frag")

  self.velx = math.cos(angle) * strength
  self.vely = math.sin(angle) * strength

  self.canInteract = false
end

function Corpse:added()
  self.collision = physicsWorld:newCircleBody {
    x = self.x,
    y = self.y,
    type = "dynamic",
    anchor = self,
    shape = {4},
    category = {"entity"},
    mask = {"entity"},
  }
end

function Corpse:removed()
  self.collision:destroy()
end

function Corpse:update()
  self.zIndex = -self.y

  self.velx = core.math.deltaLerp(self.velx, 0, 10)
  self.vely = core.math.deltaLerp(self.vely, 0, 10)

  self.collision:setVelocity(self.velx, self.vely)
  self.x, self.y = self.collision:getPosition()

  local player = Player.instance
  local dist = core.math.distanceBetween(self.x, self.y, player.x, player.y)
  self.canInteract = dist < 48

  self.outline:sendUniform("texSize", {self.sprite.image:getDimensions()})
  self.outline:sendUniform("width", self.canInteract and 1 or 0)
  self.outline:sendUniform("outlineColor", {1, 1, 1, 1})
end

function Corpse:draw()
  local x, y = self.collision:getPosition()

  if self.canInteract then
    self.outline:apply()
  end

  love.graphics.setColor(1, 1, 1)
  self.sprite:draw(x, y)
  self.outline:stop()

  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(x, y, 0, 1, -0.5)
end

return Corpse
