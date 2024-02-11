local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")

local BookGui = require("lui.book")

local Book = class(WorldObj)

function Book:init()
  self:base("init")

  self.sprite = core.Sprite("assets/book.png")
  self.bookGui = BookGui(false, self.sprite)
  self.bookOpen = false
end

function Book:update()
  local window = kirigami.Region(0, 0, core.viewport.getSize("gui"))
  local image = kirigami.Region(0, 0, self.sprite.image:getDimensions())
  local book = image:center(window)
  self.bookGui:setView(book)
end

function Book:onKeyPressed()
  if core.input.isPressed("toggleBook") then
    self.bookOpen = not self.bookOpen
    if self.bookOpen then
      luiScene:addElement(self.bookGui)
    else
      luiScene:removeElement(self.bookGui)
    end
  end
end

core.event.connect("keypressed", world, Book, "onKeyPressed")

return Book
