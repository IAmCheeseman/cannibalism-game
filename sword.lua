local itemManager = require("itemmanager")

local Sword = class(WorldObj)

itemManager.define(
  "sword", Sword,
  core.Sprite("assets/sword_slot.png"),
  core.Sprite("assets/sword_slot.png"))

function Sword:init(anchor)
  self:base("init")

  self.sprite = core.Sprite("assets/sword.png", {
    xframes = 11,
    yframes = 1,
    animations = {
      idle = {
        fps = 1,
        start = 1,
        stop = 1
      },
      swing = {
        once = true,
        fps = 15,
        start = 2,
        stop = 6,
      },
      poke = {
        once = true,
        fps = 15,
        start = 7,
        stop = 11,
      }
    }
  })
  self.sprite.offsetx = 8
  self.sprite.offsety = 13
  self.sprite:play("idle")
  self.sprite:setAnimOverCallback(self, self.onSwordAnimationFinish)

  self.cooldown = core.Timer(0.4)
  self.comboWindow = core.Timer(0.2)

  self.combo = 1

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
  if self.comboWindow.justFinished and self.cooldown.isOver then
    self.combo = 1
  end

  local accel = 50
  self.x = core.math.deltaLerp(self.x, self.anchor.x, accel)
  self.y = core.math.deltaLerp(self.y, self.anchor.y, accel)

  self.sprite:update()
  self.cooldown:update()
  self.comboWindow:update()
end

function Sword:draw()
  local mx, my = core.viewport.getMousePosition("default")

  love.graphics.setColor(1, 1, 1)

  local angle = core.math.angleBetween(self.x, self.y, mx, my)
  local dx, dy = self.x + math.cos(angle) * 9, self.y + math.sin(angle) * 8 - 8
  local swingDir = (self.combo == 1 or self.combo == 3) and 1 or -1
  local scaley = (mx > self.x and 1 or -1) * swingDir

  self.sprite:draw(dx, dy, angle, 1, scaley)
end

function Sword:onSwordAnimationFinish(_, animationName)
  if animationName == "idle" then
    return
  end
  self.combo = self.combo + 1

  if self.combo > 3 then
    self.combo = 1
  end
  self.comboWindow:start()
end

function Sword:onMousePressed()
  local swordAnim = self.sprite:getAnimation(self.sprite.playing)
  if core.input.isPressed("useWeapon")
  and (self.cooldown.isOver or self.sprite.frame >= swordAnim.stop - 2) then
    if self.combo <= 2 then
      self.sprite:play("swing")
    else
      self.sprite:play("poke")
    end
    local animationName = self.combo == 3 and "poke" or "swing"
    self.cooldown:start(self.sprite:getAnimation(animationName).run)
  end
end

core.event.connect("mousepressed", world, Sword, "onMousePressed")

return Sword
