local Tree = class(WorldObj)

local treeSprite = core.Sprite("assets/tree.png")
treeSprite:setOffsetPreset("center", "bottom")

function Tree:init(x, y)
  self:base("init")
  self.x = x
  self.y = y

  self.zIndex = -y

  self.t = love.math.random() * 3
end

function Tree:update(dt)
  self.t = self.t + dt
end

function Tree:draw()
  local sway = math.sin(self.t) * 0.1
  love.graphics.setColor(1, 1, 1)
  treeSprite:draw(self.x, self.y, 0, 1, 1, sway, 0)
  love.graphics.setColor(0, 0, 0, 0.5)
  treeSprite:draw(self.x, self.y, 0, 1, -0.5, sway, 0)
end

return Tree
