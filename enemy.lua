local Corpse = require("corpse")
local Player = require("player")

local Enemy = class(WorldObj)

function Enemy:init()
  self:base("init")

  self.maxHealth = 100
  self.health = self.maxHealth
  self.vx, self.vy = 0, 0
  self.speed = 80
  self.scalex = 1

  self.whitenShader = core.shader.new("whiten", "whiten.frag")

  self.swordSprite = core.Sprite("assets/knightsword.png")
  self.swordSprite:setOffsetPreset("right", "center")

  self.sprite = core.Sprite("assets/knight.png", {
    xframes = 4,
    yframes = 3,
    animations = {
      idle = {
        fps = 10,
        start = 1,
        stop = 4,
      },
      walk = {
        fps = 10,
        start = 5,
        stop = 7,
      },
      corpse = {
        fps = 0,
        start = 9,
        stop = 9,
      }
    }
  })
  self.sprite:setOffsetPreset("center", "bottom")

  self.attackCharge = core.Timer(1)

  self.stateMachine = core.StateMachine(self)
    :addState("pursue", self.pursueUpdate, self.pursueDraw)
    :addState("attackCharge",
      self.attackChargeUpdate,
      self.attackChargeDraw,
      self.attackChargeStart,
      self.attackChargeStop)
    :setCurrent("pursue")

  self.sword = core.Sprite("assets/sword.png", {
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
    }
  })
  self.sword.offsetx = 8
  self.sword.offsety = 13
  self.sword:play("idle")
  self.sword:setAnimOverCallback(self, self.onSwordAnimationFinish)
end

function Enemy:added()
  local w, h = self.sprite:getDimensions()
  local cx, cy, cw, ch = -w/2, -h, w, h

  self.hitbox = core.physics.AbstractBody(
    self, core.physics.makeAabb(cx, cy, cw, ch), {
      layers = {},
      mask = {"player"},
    })
  physicsWorld:addBody(self.hitbox)

  self.hurtbox = core.physics.AbstractBody(
    self, core.physics.makeAabb(cx, cy, cw, ch), {
      layers = {"enemy"},
      mask = {},
    })
  physicsWorld:addBody(self.hurtbox)

  self.collision = core.physics.SolidBody(
    self, core.physics.makeAabb(cx, cy, cw, ch), {
      layers = {},
      mask = {"env"}
    })
  physicsWorld:addBody(self.collision)
end

function Enemy:removed()
  physicsWorld:removeBody(self.hitbox)
  physicsWorld:removeBody(self.hurtbox)
  physicsWorld:removeBody(self.collision)
end

function Enemy:takeDamage(kbDir, amount)
  self.health = self.health - amount

  self.vx = math.cos(kbDir) * 250
  self.vy = math.sin(kbDir) * 250

  if self.health <= 0 then
    world:remove(self)

    self.sprite:play("corpse")
    local corpse = Corpse(
      self.x, self.y, kbDir, 500, self.sprite)
    world:add(corpse)
  end
end

function Enemy:update()
  self.zIndex = self.y
  self:updateChildren()
end

function Enemy:idleUpdate(_)
  self.sprite:play("idle")

  self.vx = core.math.deltaLerp(self.vx, 0, 15)
  self.vy = core.math.deltaLerp(self.vy, 0, 15)

  self.vx, self.vy = self.collision:moveAndCollide(self.vx, self.vy)
end

function Enemy:attackChargeStart()
  self.attackCharge:start()
end

function Enemy:attackChargeUpdate(dt)
  self:idleUpdate(dt)

  if self.attackCharge.isOver then
    self.stateMachine:setCurrent("pursue")
  end
end

function Enemy:attackChargeStop()
  self.sword:play("swing")
end

function Enemy:attackChargeDraw()
  local brightness = self.attackCharge:percentageOver()
  self.whitenShader:sendUniform("whiteness", brightness)

  self.whitenShader:apply()
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
  self.whitenShader:stop()
  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(self.x, self.y, 0, self.scalex, -0.5)
end

function Enemy:pursueUpdate(_)
  self.sprite:play("walk")

  local player = Player.instance
  local dirx, diry = core.math.directionTo(self.x, self.y, player.x, player.y)
  self.vx = core.math.deltaLerp(self.vx, dirx * self.speed, 15)
  self.vy = core.math.deltaLerp(self.vy, diry * self.speed, 15)

  self.scalex = self.x > player.x and 1 or -1

  self.vx, self.vy = self.collision:moveAndCollide(self.vx, self.vy)

  local dist = core.math.distanceBetween(self.x, self.y, player.x, player.y)
  if dist < 28 then
    self.stateMachine:setCurrent("attackCharge")
  end
end

function Enemy:pursueDraw()
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(self.x, self.y, 0, self.scalex, -0.5)
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1)
  self.stateMachine:draw()

  love.graphics.setColor(1, 1, 1)
  local player = Player.instance
  local angle = core.math.angleBetween(self.x, self.y, player.x, player.y)
  local scaley = player.x < self.x and -1 or 1
  local holdOffset = 8
  self.sword:draw(
    self.x + math.cos(angle) * holdOffset,
    self.y + math.sin(angle) * holdOffset - 6,
    angle, 1, scaley)
end

return Enemy
