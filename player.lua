local Sword = require("sword")

local Player = class(WorldObj)

local ACCEL = 15

function Player:init()
  self:base("init")

  Player.instance = self

  self.sprite = core.Sprite("assets/sam.png", {
    xframes = 3,
    yframes = 2,
    animations = {
      idle = {
        fps = 10,
        start = 1,
        stop = 3,
      },
      walk = {
        fps = 10,
        start = 4,
        stop = 6,
      }
    }
  })
  self.sprite:setOffsetPreset("center", "bottom")
  self.light = core.lighting.PointLight(self.x, self.y, 64, {
    color = {0.9, 0.5, 0.3, 3},
  })
  world:add(self.light)

  self.maxHealth = 100
  self.health = 100

  self.velx = 0
  self.vely = 0
  self.time = 0

  self.stateMachine = core.StateMachine(self)
    :addState("normal", self.normalUpdate, self.normalDraw)
    :setCurrent("normal")

  self.speed = 150
end

function Player:takeDamage(kbDir, amount)
  self.health = self.health - amount
  self.velx = math.cos(kbDir) * 200
  self.vely = math.sin(kbDir) * 200

  if self.health <= 0 then
    world:remove(self)
  end
end

function Player:added()
  local ww, wh = core.viewport.getSize("default")
  core.viewport.setCameraPos(
    "default",
    math.floor(self.x - ww * 0.5 + 0.5),
    math.floor(self.y - wh * 0.5 + 0.5) - 8)

  local swordHitbox = physicsWorld:newRectangleBody {
    type = "dynamic",
    x = self.x,
    y = self.y,
    rotationFixed = true,
    sensor = true,
    shape = {24, 32},
    category = {L_HITBOX},
    mask = {L_ENEMY},
  }
  self.sword = Sword(self, swordHitbox)
  self.sword.damage = 123
  self.sword.x = self.x
  self.sword.y = self.y
  world:add(self.sword)

  self.hurtbox = physicsWorld:newCircleBody {
    type = "dynamic",
    anchor = self,
    rotationFixed = true,
    followAnchor = true,
    sensor = true,
    shape = {0, -4, 4},
    category = {L_PLAYER, L_HURTBOX},
    mask = {},
  }
  self.hurtbox.test = true

  self.collision = physicsWorld:newCircleBody {
    type = "dynamic",
    x = self.x,
    y = self.y,
    rotationFixed = true,
    shape = {0, -4, 4},
    category = {L_ENTITY},
    mask = {L_ENTITY},
  }
end

function Player:removed()
  self.hurtbox:destroy()
  self.collision:destroy()
  world:remove(self.sword)
end

function Player:updateCamera()
  local ww, wh = core.viewport.getSize("default")
  local cx, cy = core.viewport.getCameraPos("default")
  core.viewport.setCameraPos(
    "default",
    core.math.deltaLerp(cx, self.x - ww * 0.5 + 0.5, 24),
    core.math.deltaLerp(cy, (self.y - wh * 0.5 + 0.5) - 8, 20))
end

function Player:update()
  self.zIndex = -self.y

  self:updateChildren()
  self:updateCamera()

  self.light.x = self.x
  self.light.y = self.y

  self.sword.targetx, self.sword.targety = core.viewport.getMousePosition("default")

  if core.input.isPressed("useWeapon") then
    self.sword:attack()
  end
end

function Player:draw()
  self.stateMachine:draw()
end

function Player:normalUpdate(dt)
  self.time = self.time + dt

  local ix, iy = 0, 0

  if core.input.isPressed("up")    then iy = iy - 1 end
  if core.input.isPressed("left")  then ix = ix - 1 end
  if core.input.isPressed("down")  then iy = iy + 1 end
  if core.input.isPressed("right") then ix = ix + 1 end
  ix, iy = core.math.normalize(ix, iy)

  if core.math.length(ix, iy) == 0 then
    self.sprite:play("idle")
  else
    self.sprite:play("walk")
  end

  self.velx = core.math.deltaLerp(self.velx, ix * self.speed, ACCEL)
  self.vely = core.math.deltaLerp(self.vely, iy * self.speed, ACCEL)

  self.collision:setVelocity(self.velx, self.vely)
  self.x, self.y = self.collision:getPosition()
end

function Player:normalDraw()
  local mx, _ = core.viewport.getMousePosition("default")

  love.graphics.setColor(1, 1, 1)

  local scalex = 1
  if mx > self.x then
    scalex = -1
  end

  local skew, scaley = 0, 1
  if self.stateMachine:getCurrent() == "attack" then
    skew = self.sword.cooldown:percentageOver() * 0.25
    scaley = 1 - self.sword.cooldown:percentageOver() * 0.2
  end

  self.sprite:draw(self.x, self.y, 0, scalex, scaley, skew, 0)
  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(self.x, self.y, 0, scalex, -scaley * 0.5, skew, 0)
end

return Player
