local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")
local theme = require("lui.defaulttheme")

local Label = require("lui.label")
local ProgressBar = require("lui.progressbar")
local EmotionsPage = require("lui.bookemotionpage")
local InventoryPage = require("lui.bookinventorypage")

local Book = LUI.Element()

function Book:init(sprite, inventory)
  self.sprite = sprite

  self.pages = {
    InventoryPage(self, inventory),
    EmotionsPage(self),
  }
  self.page = 1
end

function Book:onRender(region)
  local imageScale = region:getScaleToFit(self.sprite.image:getDimensions())
  love.graphics.setColor(1, 1, 1, 1)
  self.sprite:draw(region.x, region.y, 0, imageScale)

  self.pages[self.page]:render(region)
end

return Book
