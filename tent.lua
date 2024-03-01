local Player = require("player")
local Enemy = require("enemy")

local Tent = class(WorldObj)

local tentSprite = core.Sprite("assets/tent.png")
tentSprite:setOffsetPreset("center", "bottom")

function Tent:init(x, y)
  self:base("init")
  self.x = x
  self.y = y

  self.zIndex = -y

  self.timer = core.Timer(3)
  self.timer:start()

  self.count = 0
end

function Tent:update()
  local player = Player.instance
  local dist = core.math.distanceBetween(self.x, self.y, player.x, player.y)
  if dist < 128 then
    self:updateChildren()

    local isEnemySpawned = not self.spawned or self.spawned.isDead
    local hasEnemies = self.count < 3
    if self.timer.justFinished and isEnemySpawned and hasEnemies then
      self.spawned = Enemy()

      self.spawned.x = self.x
      self.spawned.y = self.y

      world:add(self.spawned)

      self.timer:start()

      self.count = self.count + 1
    end
  end
end

function Tent:draw()
  love.graphics.setColor(0, 0, 0, 0.5)
  tentSprite:draw(self.x, self.y - 1, 0, 1, -0.5)
  love.graphics.setColor(1, 1, 1)
  tentSprite:draw(self.x, self.y, 0, 1, 1)
end

return Tent
