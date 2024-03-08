local itemManager = require("itemmanager")

local Sword = class(WorldObj)

itemManager.define(
  "sword", Sword,
  core.Sprite("assets/sword_slot.png"),
  core.Sprite("assets/sword_slot.png"),
  {isWeapon=true})

function Sword:init(anchor)
  self:base("init")
  self.anchor = anchor

  self.paletteShader = core.shader.new("3colorpalette", "3colorpalette.frag")
  self.sprite = core.Sprite("assets/sword.png")
  self.sprite.offsetx = 8
  self.sprite.offsety = 13

  self.swingAmount = math.pi / 4
  self.swingDir = 1
  self.rot = 0

  self.hitbox = physicsWorld:newRectangleBody {
    type = "dynamic",
    sensor = true,
    x = self.anchor.x,
    y = self.anchor.y,
    rotationFixed = true,
    shape = {24, 32},
    category = {"hitbox"},
    mask = {"player", "env"},
  }
  self.hitbox:setActive(false)

  self.cooldown = core.Timer(0.3)

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

function Sword:update(dt)
  self.zIndex = -self.anchor.y - 1

  for body, _ in pairs(self.hitbox:getCollisions()) do
    if body.anchor.takeDamage then
      body.anchor:takeDamage(self.hitAngle, 50)
    end
  end

  if self.cooldown.justFinished then
    self.hitbox:setActive(false)
  end

  local accel = 50
  self.x = core.math.deltaLerp(self.x, self.anchor.x, accel)
  self.y = core.math.deltaLerp(self.y, self.anchor.y, accel)

  self.rot = core.math.lerpAngle(
    self.rot,
    (self.swingAmount * self.swingDir),
    16 * dt)

  self:updateChildren()
end

function Sword:draw()
  local mx, my = core.viewport.getMousePosition("default")

  love.graphics.setColor(1, 1, 1)

  local angle = core.math.angleBetween(self.x, self.y, mx, my)
  angle = angle + self.rot
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

  self.hitbox:setPosition(self.x + mx * 16, self.y + my * 16)
  self.hitbox:setRotation(core.math.angle(mx, my))
end

function Sword:onMousePressed()
  if core.input.isPressed("useWeapon") and self.cooldown.isOver then
    self.cooldown:start(0.05)
    self.swingDir = -self.swingDir
    self:updateHitbox()

    local mx, my = core.viewport.getMousePosition("default")
    mx, my = core.math.directionTo(self.x, self.y, mx, my)
    self.hitAngle = core.math.angle(mx, my)

    self.hitbox:setActive(true)
  end
end

core.events.mousepressed:connect(world, Sword, "onMousePressed")

return Sword
