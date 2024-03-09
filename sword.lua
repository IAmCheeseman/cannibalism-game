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

  self.sprite = core.Sprite("assets/sword.png")
  self.sprite.offsetx = 8
  self.sprite.offsety = 13

  self.swing = core.Sprite("assets/swing.png", {
    xframes = 8,
    yframes = 1,
    animations = {
      idle = {
        fps = 0,
        start = 8,
        stop = 8,
      },
      swing = {
        once = true,
        fps = 20,
        start = 1,
        stop = 8,
      }
    }
  })
  self.swing:setOffsetPreset("left", "center")
  self.swing:play("idle")

  self.swingAmount = math.pi / 4
  self.swingDir = 1
  self.rot = 0

  self.cooldown = core.Timer(0.3)

  self.x = anchor.x
  self.y = anchor.y
end

function Sword:added()
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
end

function Sword:removed()
  self.hitbox:destroy()
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
      body.anchor:takeDamage(self.hitAngle, 34)
    end
  end

  if self.cooldown.justFinished then
    self.hitbox:setActive(false)
  end

  self.x = self.anchor.x
  self.y = self.anchor.y

  self.rot = core.math.lerpAngle(
    self.rot,
    (self.swingAmount * self.swingDir),
    16 * dt)

  self:updateChildren()
end

function Sword:draw()
  local mx, my = core.viewport.getMousePosition("default")

  love.graphics.setColor(1, 1, 1)

  local mouseAngle = core.math.angleBetween(self.x, self.y, mx, my)
  local angle = mouseAngle + self.rot
  local dx, dy = self.x + math.cos(angle) * 9, self.y + math.sin(angle) * 8 - 8

  local scaley = -self.swingDir

  self.sprite:draw(dx, dy, angle, 1, scaley)

  local hbx, hby = self.hitbox:getPosition()
  local hbr = self.hitbox:getRotation()
  self.swing:draw(hbx, hby, hbr)
end

function Sword:updateHitbox()
  local mx, my = core.viewport.getMousePosition("default")
  mx, my = core.math.directionTo(self.x, self.y, mx, my)

  self.hitbox:setPosition(self.x + mx * 16, self.y + my * 16 - 8)
  self.hitbox:setRotation(core.math.angle(mx, my))
end

function Sword:onMousePressed()
  if core.input.isPressed("useWeapon") and self.cooldown.isOver then
    self.cooldown:start(0.4)
    self.swingDir = -self.swingDir
    self:updateHitbox()

    local mx, my = core.viewport.getMousePosition("default")
    mx, my = core.math.directionTo(self.x, self.y, mx, my)
    self.hitAngle = core.math.angle(mx, my)

    self.swing:play("swing")

    self.hitbox:setActive(true)
  end
end

core.events.mousepressed:connect(world, Sword, "onMousePressed")

return Sword
