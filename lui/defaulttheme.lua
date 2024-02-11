local Theme = require("lui.theme")

local theme = Theme()
theme.font = love.graphics.newImageFont("assets/font.png", " abcdefghijklmnopqrstuvwxyz0123456789.!?'\",")
theme:setColor("bgColor", 1, 1, 1)
theme:setColor("fgColor", 0, 0, 0)
theme.lineStyle = "rough"

return theme
