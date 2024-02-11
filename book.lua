local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")

local BookGui = require("lui.book")

local Book = class(WorldObj)

function Book:init()
  self:base("init")

  self.sprite = core.Sprite("assets/book.png")
  self.bookGui = BookGui(false, self.sprite)
  luiScene:addElement(self.bookGui)
end

function Book:update()
  local window = kirigami.Region(0, 0, core.viewport.getSize("gui"))
  local image = kirigami.Region(0, 0, self.sprite.image:getDimensions())
  local book = image:center(window)
  self.bookGui:setView(book)
end

-- function Book:gui()
-- end
--
-- core.event.connect("gui", world, Book, "gui")

return Book
