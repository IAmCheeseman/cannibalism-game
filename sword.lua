local itemManager = require("itemmanager")

local Sword = class(WorldObj)

itemManager.define(
  "sword", Sword,
  core.Sprite("assets/sword_slot.png"),
  core.Sprite("assets/sword_slot.png"),
  {isWeapon=true})

function Sword:init(anchor)
  self:base("init")

  self.paletteShader = core.shader.new("3colorpalette", "3colorpalette.frag")
  self.sprite = core.Sprite("assets/sword.png")
  self.sprite.offsetx = 8
  self.sprite.offsety = 13

  self.angle = math.pi / 4
  self.swingDir = 1

  self.hitbox = core.physics.AbstractBody(
    self, core.physics.makeAabb(-8, -16, 16, 16), {
      layers = {"weapon"},
      mask = {"enemy"}
    })
  physicsWorld:addBody(self.hitbox)

  self.cooldown = core.Timer(0.3)

  self.anchor = anchor
  self.x = anchor.x
  self.y = anchor.y
end

function Sword:shouldStopPlayer()
  return not self.cooldown.isOver
end

function Sword:getPushVelocity()
  local mx, my = core.viewport.getMousePosition("default")
  local velx, vely = core.math.directionTo(self.x, self.y, mx, my)

  local swingStrength = 100
  velx = velx * swingStrength
  vely = vely * swingStrength

  return velx, vely
end

function Sword:update()
  self.zIndex = -self.y

  local accel = 50
  self.x = core.math.deltaLerp(self.x, self.anchor.x, accel)
  self.y = core.math.deltaLerp(self.y, self.anchor.y, accel)

  self:updateChildren()
end

function Sword:draw()
  local mx, my = core.viewport.getMousePosition("default")

  love.graphics.setColor(1, 1, 1)

  local angle = core.math.angleBetween(self.x, self.y, mx, my)
  local offsetAngle = self.angle
  if self.swingDir == -1 then
    offsetAngle = offsetAngle + math.pi
  end
  angle = angle + offsetAngle
  local dx, dy = self.x + math.cos(angle) * 9, self.y + math.sin(angle) * 8 - 8

  local scaley = -self.swingDir

  self.paletteShader:sendUniform("redChannel", {1, 1, 1, 1})
  self.paletteShader:sendUniform("greenChannel", {0.5, 0.5, 0, 1})
  self.paletteShader:sendUniform("blueChannel", {0.5, 0.5, 0.5, 1})

  -- self.paletteShader:apply()
  self.sprite:draw(dx, dy, angle, 1, scaley)
  -- self.paletteShader:stop()
end

function Sword:updateHitbox()
  local mx, my = core.viewport.getMousePosition("default")
  mx, my = core.math.directionTo(self.x, self.y, mx, my)
  mx = math.floor(mx + 0.5)
  my = math.floor(my + 0.5)
  local w, h = 0, 0

  if my == 0 then
    w = 16
  else
    w = 24
  end
  if mx == 0 then
    h = 16
  else
    h = 24
  end

  self.hitbox.shape.offsetx = -w / 2
  self.hitbox.shape.offsety = -h
  self.hitbox.shape.width = w
  self.hitbox.shape.height = h
end

function Sword:onMousePressed()
  if core.input.isPressed("useWeapon") and self.cooldown.isOver then
    self.cooldown:start(0.3)

    self.swingDir = -self.swingDir

    local mx, my = core.viewport.getMousePosition("default")
    local dirx, diry = core.math.directionTo(self.x, self.y, mx, my)
    self:updateHitbox()
    self.hitbox.shape.offsetx = self.hitbox.shape.offsetx + dirx * 16
    self.hitbox.shape.offsety = self.hitbox.shape.offsety + diry * 16

    for _, body in ipairs(self.hitbox:getColliding()) do
      body.anchor:takeDamage(core.math.angle(dirx, diry), 50)
    end
  end
end

core.events.mousepressed:connect(world, Sword, "onMousePressed")

return Sword
