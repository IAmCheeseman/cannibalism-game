local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")
local ui = require("lui.ui")

local Label = require("lui.label")

local PauseMenu = LUI.Element()

function PauseMenu:init()
  self.title = Label(self, "paused", ui.font, "center", true)
  self.continue = Label(self, "press esc to continue.", ui.font, "center")
end

function PauseMenu:onRender(region)
  local top, bottom = region:padRatio(0.25):splitVertical(0.5, 0.5)
  self.title:render(top)
  self.continue:render(bottom)
end

return PauseMenu
