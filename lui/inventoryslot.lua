local kirigami = require("lib.kirigami")
local LUI = require("lib.LUI")
local theme = require("lui.defaulttheme")

local InventorySlot = LUI.Element()

local slotSprite = core.Sprite("assets/slot.png")

function InventorySlot:init(inventory, slotIndex)
  self.inventory = inventory
  self.slotIndex = slotIndex
end

function InventorySlot:onRender(region)
  slotSprite:draw(math.floor(region.x), math.floor(region.y))
  if not self.inventory:isSlotEmpty(self.slotIndex) then
    local item = self.inventory:getItem(self.slotIndex)
    item.slotSprite:draw(math.floor(region.x), math.floor(region.y))
  end
end

return InventorySlot
