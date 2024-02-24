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

function Enemy:takeDamage(amount)
  self.health = self.health - amount
  print(self.health, self)
  if self.health <= 0 then
    world:remove(self)
  end
end

function Enemy:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("fill", self.x, self.y, 16, 16)
end

return Enemy
