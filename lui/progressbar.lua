local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")

local ProgressBar = LUI.Element()

function ProgressBar:init(icon, empty, full)
  self.icon = icon
  self.emptyImage = empty
  self.fullImage = full
  self.emptyModulate = {1, 1, 1}
  self.fullModulate = {1, 1, 1}
  self.value = 0
end

function ProgressBar:onRender(region)
  local barImage = kirigami.Region(0, 0, self.fullImage:getDimensions())
  local icon, bar = region:splitHorizontal(0.25, 0.75)

  bar = barImage:center(bar)

  local w, h = self.fullImage:getDimensions()
  local fill = w * self.value
  local quad = love.graphics.newQuad(
    0, 0,
    fill, h,
    w, h)

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.icon, icon.x, icon.y)
  love.graphics.setColor(unpack(self.emptyModulate))
  love.graphics.draw(self.emptyImage, bar.x, bar.y)
  love.graphics.setColor(unpack(self.fullModulate))
  love.graphics.draw(self.fullImage, quad, bar.x, bar.y)
end

return ProgressBar
