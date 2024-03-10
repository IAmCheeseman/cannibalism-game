local Corpse = require("corpse")
local Player = require("player")
local MeleeAi = require("meleeai")
local Sword = require("sword")

local Enemy = class(WorldObj)

Enemy.died = core.Event()

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

  self.attackCharge = core.Timer(0.5)

  self.stateMachine = core.StateMachine(self)
    :addState("ai", self.updateAi)
    :addState("attack",
      self.attackUpdate,
      nil,
      self.attackStart,
      self.attackStop)
    :setCurrent("ai")
end

function Enemy:added()
  local w, h = self.sprite:getDimensions()
  local cx, cy, cw, ch = 0, -h/2, w, h

  local swordHitbox = physicsWorld:newRectangleBody {
    type = "dynamic",
    x = self.x,
    y = self.y,
    rotationFixed = true,
    sensor = true,
    shape = {16, 24},
    category = {L_HITBOX},
    mask = {L_ENEMY},
  }
  self.sword = Sword(self, swordHitbox)
  self.sword.x = self.x
  self.sword.y = self.y
  self.sword.damage = 150
  world:add(self.sword)

  self.hurtbox = physicsWorld:newRectangleBody {
    type = "dynamic",
    anchor = self,
    rotationFixed = true,
    followAnchor = true,
    sensor = true,
    shape = {cx, cy, cw, ch},
    category = {L_ENEMY, L_HURTBOX},
    mask = {},
  }

  self.collision = physicsWorld:newCircleBody {
    type = "dynamic",
    x = self.x,
    y = self.y,
    rotationFixed = true,
    shape = {0, -4, 4},
    category = {L_ENTITY},
    mask = {},
  }

  self.iframes = core.Timer(0.1)

  self.ai = MeleeAi(self, self.collision)
end

function Enemy:removed()
  self.hurtbox:destroy()
  self.collision:destroy()
end

function Enemy:takeDamage(kbDir, amount)
  if not self.iframes.isOver then
    return
  end
  self.iframes:start()

  self.health = self.health - amount

  self.velx = math.cos(kbDir) * 250
  self.vely = math.sin(kbDir) * 250

  if self.health <= 0 then
    world:remove(self)
    world:remove(self.sword)

    Enemy.died:call()

    self.isDead = true

    self.sprite:play("corpse")
    self.sprite:update()
    local corpse = Corpse(self.x, self.y, kbDir, 500, self.sprite)
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

function Enemy:attackUpdate()
  self.sprite:play("idle")

  self.velx = core.math.deltaLerp(self.velx, 0, 15)
  self.vely = core.math.deltaLerp(self.vely, 0, 15)

  self.collision:setVelocity(self.velx, self.vely)
  self.x, self.y = self.collision:getPosition()

  if self.attackCharge.isOver then
    self.stateMachine:setCurrent("ai")
  end
end

function Enemy:attackStop()
  self.sword:attack()
end

function Enemy:attackChargeDraw()
  local brightness = self.attackCharge:percentageOver()
  self.whitenShader:sendUniform("whiteness", brightness)

  local scalex = self.velx < 0 and 1 or -1

  self.whitenShader:apply()
  self.sprite:draw(self.x, self.y, 0, scalex, 1)
  self.whitenShader:stop()
  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(self.x, self.y, 0, scalex, -0.5)
end

function Enemy:updateAi(_)
  self.sprite:play("walk")

  self.ai:updateStates()

  self.collision:setVelocity(self.velx, self.vely)
  self.x, self.y = self.collision:getPosition()

  local player = Player.instance

  self.sword.targetx = player.x
  self.sword.targety = player.y

  if self.ai:shouldDoAction("attack") then
    self.stateMachine:setCurrent("attack")
  end
end

function Enemy:draw()
  local brightness = self.stateMachine:getCurrent() == "ai"
      and 0
  or self.attackCharge:percentageOver()
  self.whitenShader:sendUniform("whiteness", brightness)

  local scalex = self.velx < 0 and 1 or -1

  self.whitenShader:apply()
  self.sprite:draw(self.x, self.y, 0, scalex, 1)
  self.whitenShader:stop()
  love.graphics.setColor(0, 0, 0, 0.5)
  self.sprite:draw(self.x, self.y, 0, scalex, -0.5)
end

return Enemy
