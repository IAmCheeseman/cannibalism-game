local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")
local theme = require("lui.defaulttheme")

local Label = require("lui.label")
local InventorySlot = require("lui.inventoryslot")

local InventoryPage = LUI.Element()

function InventoryPage:init(inventory)
  self.leftTitle = Label(self, "items", theme)
  self.rightTitle = Label(self, "equipped", theme)

  self.inventory = inventory

  self.slots = {}

  for i=1, inventory.size do
    table.insert(self.slots, InventorySlot(self, inventory, i))
  end
end

function InventoryPage:onRender(region)
  local left, right = region:splitHorizontal(0.5, 0.5)
  left = left:pad(6)
  right = right:pad(6)
  local leftTitle, leftContent = left:splitVertical(0.15, 0.8)
  local rightTitle, rightContent = right:splitVertical(0.15, 0.8)

  love.graphics.setColor(34/255, 32/255, 52/255)

  self.leftTitle:render(leftTitle)
  self.rightTitle:render(rightTitle)

  leftContent = kirigami.Region(0, 0, leftContent.w, leftContent.w):center(leftContent)

  love.graphics.setColor(1, 1, 1)
  for i, slotRegion in ipairs(leftContent:grid(2, 2)) do
    self.slots[i]:render(slotRegion)
  end

  rightContent = kirigami.Region(0, 0, rightContent.w, 17):center(rightContent)

  for _, slot in ipairs(rightContent:grid(2, 1)) do
    -- slotSprite:draw(math.floor(slot.x), math.floor(slot.y))
  end
end

return InventoryPage
