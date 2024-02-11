local Sword = require("sword")

local Player = class(WorldObj)

local ACCEL = 15

function Player:init()
  self:base("init")

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

  self.velx = 0
  self.vely = 0
  self.time = 0

  self.stateMachine = core.StateMachine(self)
    :addState("normal", self.normalUpdate, self.normalDraw)
    :addState("attack", self.attackUpdate, self.normalDraw, self.attackStart)
    :setCurrent("normal")

  self.sword = Sword(self)
  world:add(self.sword)

  self.speed = 150

  self.body = core.physics.SolidBody(self, core.physics.makeAabb(-4, -8, 8), {})
  physicsWorld:addBody(self.body)

  self.maxHealth = 100
  self.health = self.maxHealth
end

function Player:updateCamera()
  local ww, wh = core.viewport.getSize("default")
  local cx, cy = core.viewport.getCameraPos("default")
  core.viewport.setCameraPos(
    "default",
    core.math.deltaLerp(cx, math.floor(self.x - ww * 0.5 + 0.5), 25),
    core.math.deltaLerp(cy, math.floor(self.y - wh * 0.5 + 0.5) - 8, 25))
end

function Player:update()
  self.stateMachine:update()
  self.sprite:update()
  self:updateCamera()
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

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  if self.sword:shouldStopPlayer() then
    self.stateMachine:setCurrent("attack")
  end
end

function Player:attackStart()
  local pushx, pushy = self.sword:getPushVelocity()
  self.velx = self.velx + pushx
  self.vely = self.vely + pushy
end

function Player:attackUpdate()
  self.velx = core.math.deltaLerp(self.velx, 0, ACCEL)
  self.vely = core.math.deltaLerp(self.vely, 0, ACCEL)

  self.velx, self.vely = self.body:moveAndCollide(self.velx, self.vely)

  if not self.sword:shouldStopPlayer() then
    self.stateMachine:setCurrent("normal")
  end

  self.sprite:play("idle")
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
end

return Player
