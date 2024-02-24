local Corpse = class(WorldObj)

function Corpse:init(x, y, angle, strength, sprite, aabb)
  self:base("init")
  self.x = x
  self.y = y
  self.sprite = sprite

  self.vx = math.cos(angle) * strength
  self.vy = math.sin(angle) * strength

  self.collision = core.physics.SolidBody(
    self, aabb, {
      layers = {"corpse"},
      mask = {"env"},
    })
  physicsWorld:addBody(self.collision)
end

function Corpse:update()
  self.vx = core.math.deltaLerp(self.vx, 0, 10)
  self.vy = core.math.deltaLerp(self.vy, 0, 10)

  self.vx, self.vy = self.collision:moveAndCollide(self.vx, self.vy)
end

function Corpse:draw()
  local x, y = self.collision:getPosition()
  local w, h = self.collision.shape.width, self.collision.shape.height
  love.graphics.rectangle("fill", x, y, w, h)
end

return Corpse
