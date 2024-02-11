local SpeechBubble = class(WorldObj)
local theme = require("lui.defaulttheme")

function SpeechBubble:init(text, anchor, anchorSprite)
  self:base("init")

  self.text = text
  self.anchor = anchor
  self.anchorSprite = anchorSprite
  self.width, self.height = theme.font:getWidth(self.text) + 5, theme.font:getHeight() + 4
end

function SpeechBubble:update()
  local accel = 15
  local spriteHeight = self.anchorSprite:getHeight()
  self.x = core.math.deltaLerp(self.x, self.anchor.x - self.width / 2, accel)
  self.y = core.math.deltaLerp(self.y, self.anchor.y - spriteHeight - self.height - 2, accel)
end

function SpeechBubble:draw()
  local spriteHeight = self.anchorSprite:getHeight()
  local dx, dy = math.floor(self.x), math.floor(self.y)
  theme:rectangle(dx, dy, self.width, self.height)
  theme:text(
    self.text,
    dx, dy + self.height / 2 - theme.font:getHeight() / 2,
    self.width, "center")
  theme:line(
    dx + self.width / 2, dy + self.height,
    self.anchor.x, self.anchor.y - spriteHeight)
end

return SpeechBubble
