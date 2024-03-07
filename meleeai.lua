local Ai = require("ai")
local Player = require("player")

local MeleeAi = class(Ai)

function MeleeAi:init(anchor)
  self:base("init", anchor)

  self.player = Player.instance
  self.attackRadius = 28
  self.speed = 80
  self.fleeTime = 1.2

  self.stateMachine = core.StateMachine(self)
    :addState("pursue", self.pursueUpdate)
    :addState("flee", self.fleeUpdate, nil, self.fleeStart)
    :setCurrent("pursue")

  self.fleeTimer = core.Timer(self.fleeTime)
end

function MeleeAi:updateStates()
  self.player = Player.instance
  self.stateMachine:update()
end

function MeleeAi:pursueUpdate(_)
  local dirx, diry = core.math.directionTo(
      self.anchor.x, self.anchor.y,
      self.player.x, self.player.y)
  self.anchor.velx = core.math.deltaLerp(self.anchor.velx, dirx * self.speed, 15)
  self.anchor.vely = core.math.deltaLerp(self.anchor.vely, diry * self.speed, 15)
end

function MeleeAi:fleeStart()
  self.fleeTimer:start(self.fleeTime)
end

function MeleeAi:fleeUpdate(_)
  local dirx, diry = core.math.directionTo(
      self.anchor.x, self.anchor.y,
      self.player.x, self.player.y)
  dirx, diry = core.math.rotated(dirx, diry, math.pi)
  self.anchor.velx = core.math.deltaLerp(self.anchor.velx, dirx * self.speed, 15)
  self.anchor.vely = core.math.deltaLerp(self.anchor.vely, diry * self.speed, 15)

  self.fleeTimer:update()

  if self.fleeTimer.isOver then
    self.stateMachine:setCurrent("pursue")
  end
end

function MeleeAi:shouldDoAction(action)
  if action == "attack" then
    local shouldAttack = core.math.distanceBetween(
      self.anchor.x, self.anchor.y,
      self.player.x, self.player.y) < self.attackRadius
    shouldAttack = shouldAttack and self.stateMachine:getCurrent() ~= "flee"

    if shouldAttack then
      self.stateMachine:setCurrent("flee")
    end

    return shouldAttack
  end
end

return MeleeAi
