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
  self.health = 50

  self.velx = 0
  self.vely = 0
  self.time = 0

  self.stateMachine = core.StateMachine(self)
    :addState("normal", self.normalUpdate, self.normalDraw)
    :setCurrent("normal")

  self.sword = Sword(self)
  world:add(self.sword)

  self.speed = 150
end

function Player:added()
  local ww, wh = core.viewport.getSize("default")
  core.viewport.setCameraPos(
    "default",
    math.floor(self.x - ww * 0.5 + 0.5),
    math.floor(self.y - wh * 0.5 + 0.5) - 8)

  self.sword.x = self.x
  self.sword.y = self.y

  self.body = physicsWorld:newCircleBody {
    type = "dynamic",
    category = {"entity"},
    mask = {"entity"},
    x = self.x,
    y = self.y,
    anchor = self,
    rotationFixed = true,
    shape = {0, -4, 4},
  }
end

function Player:removed()
  self.body:destroy()
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

  self.body:setVelocity(self.velx, self.vely)
  self.x, self.y = self.body:getPosition()
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

function Player:gui()
  local w = 40
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 2, 2, w, 5)
  love.graphics.setColor(1, 0, 0)
  local val = w * (self.health / self.maxHealth)
  love.graphics.rectangle("fill", 2, 2, val, 5)
end

core.events.gui:connect(world, Player, "gui")

return Player
