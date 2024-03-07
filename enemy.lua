local Corpse = require("corpse")
local Player = require("player")
local MeleeAi = require("meleeai")

local Enemy = class(WorldObj)

function Enemy:init()
  self:base("init")

  self.isDead = false
  self.maxHealth = 100
  self.health = self.maxHealth
  self.velx, self.vely = 0, 0

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
    :addState("ai", self.updateAi)
    :addState("attack",
      self.attackUpdate,
      nil,
      self.attackStart,
      self.attackStop)
    :setCurrent("ai")

  self.sword = core.Sprite("assets/sword.png")
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

  self.ai = MeleeAi(self, self.collision)
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

    self.isDead = true

    self.sprite:play("corpse")
    local corpse = Corpse(
      self.x, self.y, kbDir, 500, self.sprite)
    world:add(corpse)
  end
end

function Enemy:update()
  self.zIndex = -self.y
  self:updateChildren()
end

function Enemy:attackStart()
  self.attackCharge:start()
end

function Enemy:attackUpdate(dt)
  self.sprite:play("idle")

  self.velx = core.math.deltaLerp(self.velx, 0, 15)
  self.vely = core.math.deltaLerp(self.vely, 0, 15)
  self.velx, self.vely = self.collision:moveAndCollide(self.velx, self.vely)

  if self.attackCharge.isOver then
    self.stateMachine:setCurrent("ai")
  end
end

function Enemy:attackStop()
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

function Enemy:updateAi(_)
  self.sprite:play("walk")

  self.ai:updateStates()

  self.velx, self.vely = self.collision:moveAndCollide(self.velx, self.vely)

  if self.ai:shouldDoAction("attack") then
    self.stateMachine:setCurrent("attack")
  end
end

function Enemy:draw()
  local brightness = self.stateMachine:getCurrent() == "ai"
      and 0
  or self.attackCharge:percentageOver()
  self.whitenShader:sendUniform("whiteness", brightness)

  self.whitenShader:apply()
  self.sprite:draw(self.x, self.y, 0, self.scalex, 1)
  self.whitenShader:stop()
  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(self.x, self.y, 0, self.scalex, -0.5)

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
