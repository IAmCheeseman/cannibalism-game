local Cursor = class(GameObj)

function Cursor:init()
  self:base("init")

  self.sprite = core.Sprite("assets/cursor.png")
  self.sprite:setOffsetPreset("center", "center")

  love.mouse.setVisible(false)
end

function Cursor:draw()
  local mx, my = core.viewport.getMousePosition("default")
  self.sprite:draw(math.floor(mx), math.floor(my))
end

return Cursor
