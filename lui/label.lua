local LUI = require("lib.LUI")

local Label = LUI.Element()

function Label:init(text, font, align)
  self.text = text
  self.font = font
  self.align = align or "left"
end

function Label:onRender(region)
  if self.font then
    love.graphics.setFont(self.font)
  end
  love.graphics.printf(self.text, region.x, region.y, region.w, self.align)
end

return Label
