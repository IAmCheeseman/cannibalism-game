local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")

local itemManager = require("itemmanager")
local Inventory = require("inventory")
local BookGui = require("lui.book")

local Book = class(WorldObj)
local inventory = Inventory(4)
inventory:addItem(itemManager.create("sword"))
inventory:addEquipSlot("weapon", function(item)
  return item.isWeapon
end)

inventory:addEquipSlot("tome", function(item)
  return item.isTome
end)

function Book:init()
  self:base("init")

  self.sprite = core.Sprite("assets/book.png")
  self.bookGui = BookGui(false, self.sprite, inventory)
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

core.events.keypressed:connect(world, Book, "onKeyPressed")

return Book
