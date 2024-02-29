local Cursor = class(GameObj)

function Cursor:init()
  self:base("init")

  self.sprite = core.Sprite("assets/cursor.png")
  self.sprite:setOffsetPreset("center", "center")

  love.mouse.setVisible(false)
end

function Cursor:gui()
  love.graphics.setColor(1, 1, 1)
  local mx, my = core.viewport.getMousePosition("gui")
  self.sprite:draw(math.floor(mx), math.floor(my))
end

core.events.gui:connect(world, Cursor, "gui")

return Cursor
