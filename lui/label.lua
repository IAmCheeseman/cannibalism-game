local LUI = require("lib.LUI")

local Label = LUI.Element()

function Label:init(text, font, align, centerY)
  self.text = text
  self.font = font or love.graphics.getFont()
  self.align = align or "left"
  self.centerY = centerY
end

function Label:onRender(region)
  if self.font then
    love.graphics.setFont(self.font)
  end
  local dy = region.y
  if self.centerY then
    dy = region.y + region.h / 2
    dy = dy - self.font:getHeight() / 2
  end
  love.graphics.printf(self.text, region.x, dy, region.w, self.align)
end

return Label
