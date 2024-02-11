local Theme = class()

function Theme:init()
  self.font = love.graphics.getFont()
  self.lineWidth = love.graphics.getLineWidth()
  self.lineStyle = love.graphics.getLineStyle()
  self.bgColor = {0, 0, 0}
  self.outlineColor = {0.5, 0.5, 0.5}
  self.fgColor = {1, 1, 1}
end

function Theme:applyColor(color)
  love.graphics.setColor(self[color])
end

function Theme:setColor(color, r, g, b, a)
  self[color] = {r, g, b, a}
end

function Theme:applyLineTheme()
  love.graphics.setLineWidth(self.lineWidth)
  love.graphics.setLineStyle(self.lineStyle)
end

function Theme:applyFont()
  love.graphics.setFont(self.font)
end

function Theme:rectangle(x, y, w, h)
  self:applyLineTheme()
  self:applyColor("bgColor")
  love.graphics.rectangle("fill", x, y, w, h)
  self:outline(x, y, w ,h)
end

function Theme:outline(x, y, w, h)
  self:applyLineTheme()
  self:applyColor("outlineColor")
  love.graphics.rectangle("line", x, y, w, h)
end

function Theme:line(...)
  self:applyLineTheme()
  self:applyColor("bgColor")
  love.graphics.line(...)
end

function Theme:text(...)
  self:applyColor("fgColor")
  self:applyFont()
  love.graphics.printf(...)
end

return Theme
