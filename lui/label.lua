local LUI = require("lib.LUI")

local Label = LUI.Element()

function Label:init(text, theme, align, centerY)
  self.text = text
  self.theme = theme
  self.align = align or "left"
  self.centerY = centerY
end

function Label:onRender(region)
  local dy = region.y
  if self.centerY then
    dy = region.y + region.h / 2
    dy = dy - self.font:getHeight() / 2
  end
  self.theme:text(self.text, region.x, dy, region.w, self.align)
end

return Label
