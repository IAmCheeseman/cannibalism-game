local Player = require("player")

local Corpse = class(WorldObj)

function Corpse:init(x, y, angle, strength, sprite)
  self:base("init")
  self.x = x
  self.y = y
  self.sprite = sprite

  self.outline = core.shader.new("outline", "outline.frag")

  self.vx = math.cos(angle) * strength
  self.vy = math.sin(angle) * strength

  self.canInteract = false

  local offsetx, offsety = self.sprite.offsetx, self.sprite.offsety
  local width, height = self.sprite:getDimensions()
  self.collision = core.physics.SolidBody(
    self, core.physics.makeAabb(offsetx, offsety, width, height), {
      layers = {"corpse"},
      mask = {"env"},
    })
  physicsWorld:addBody(self.collision)
end

function Corpse:update()
  self.zIndex = -self.y

  self.vx = core.math.deltaLerp(self.vx, 0, 10)
  self.vy = core.math.deltaLerp(self.vy, 0, 10)

  self.vx, self.vy = self.collision:moveAndCollide(self.vx, self.vy)

  self.sprite:update()


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
