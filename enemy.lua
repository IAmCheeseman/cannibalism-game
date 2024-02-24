local Corpse = require("corpse")

local Enemy = class(WorldObj)

function Enemy:init()
  self:base("init")

  self.maxHealth = 100
  self.health = self.maxHealth

  self.hitbox = core.physics.AbstractBody(
    self, core.physics.makeAabb(0, 0, 16, 16), {
      layers = {},
      mask = {"player"},
    })
  physicsWorld:addBody(self.hitbox)

  self.hurtbox = core.physics.AbstractBody(
    self, core.physics.makeAabb(0, 0, 16, 16), {
      layers = {"enemy"},
      mask = {},
    })
  physicsWorld:addBody(self.hurtbox)
end

function Enemy:removed()
  physicsWorld:removeBody(self.hitbox)
  physicsWorld:removeBody(self.hurtbox)
end

function Enemy:takeDamage(kbDir, amount)
  self.health = self.health - amount
  if self.health <= 0 then
    world:remove(self)

    local corpse = Corpse(self.x, self.y, kbDir, 500, nil, core.physics.makeAabb(-8, -8, 16, 8))
    world:add(corpse)
  end
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", self.x, self.y, 16, 16)
end

return Enemy
