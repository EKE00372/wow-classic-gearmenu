--[[
  MIT License

  Copyright (c) 2019 Michael Wiesendanger

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--


--[[
  Itemmanager manages all items. All itemslots muss register to work properly
]]--
local mod = rggm
local me = {}
mod.itemManager = me

me.tag = "ItemManager"

local items = {}

--[[
  Retrieve all items from inventory bags matching any type of
    INVTYPE_AMMO
    INVTYPE_HEAD
    INVTYPE_NECK
    INVTYPE_SHOULDER
    INVTYPE_BODY
    INVTYPE_CHEST
    INVTYPE_ROBE
    INVTYPE_WAIST
    INVTYPE_LEGS
    INVTYPE_FEET
    INVTYPE_WRIST
    INVTYPE_HAND
    INVTYPE_FINGER
    INVTYPE_TRINKET
    INVTYPE_CLOAK
    INVTYPE_WEAPON
    INVTYPE_SHIELD
    INVTYPE_2HWEAPON
    INVTYPE_WEAPONMAINHAND
    INVTYPE_WEAPONOFFHAND

  @param {table} inventoryType

  @return {table}
]]--
function me.GetItemsForInventoryType(inventoryType)
  local idx = 1
  local items = {}

  if inventoryType == nil then
    mod.logger.LogError(me.tag, "InventoryType(s) missing")
    return items
  end

  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      local itemId = GetContainerItemID(i, j)

      if itemId then
        local itemName, _, itemRarity, _, _, _, _, _, equipSlot, itemIcon = GetItemInfo(itemId)
        for it = 1, table.getn(inventoryType) do
          if equipSlot == inventoryType[it] then
            if itemRarity >= mod.configuration.GetFilterItemQuality() then
              if not items[idx] then
                items[idx] = {}
              end

              items[idx].bag = i
              items[idx].slot = j
              items[idx].name = itemName
              items[idx].icon = itemIcon
              items[idx].id = itemId
              items[idx].equipSlot = equipSlot
              items[idx].quality = itemRarity

              idx = idx + 1
            else
              mod.logger.LogDebug(me.tag, "Ignoring item because its quality is lower than setting "
                .. mod.configuration.GetFilterItemQuality())
            end
          end
        end
      end
    end
  end

  return items
end

--[[
  Equip an item into a specific slot identified by it's itemId
    INVSLOT_HEAD
    INVSLOT_NECK
    INVSLOT_SHOULDER
    INVSLOT_CHEST
    INVSLOT_WAIST
    INVSLOT_LEGS
    INVSLOT_FEET
    INVSLOT_WRIST
    INVSLOT_HAND
    INVSLOT_FINGER1
    INVSLOT_FINGER2
    INVSLOT_TRINKET1
    INVSLOT_TRINKET2
    INVSLOT_BACK
    INVSLOT_MAINHAND
    INVSLOT_OFFHAND
    INVSLOT_RANGED

  @param {number} itemId
  @param {number} slotId
  @param {string} itemSlotType
]]--
function me.EquipItemById(itemId, slotId, itemSlotType)
  if not itemId or not slotId or not itemSlotType then return end

  mod.logger.LogDebug(me.tag, "EquipItem: " .. itemId .. " in slot: " .. slotId)
  --[[
    if user is in combat or dead and the slot that is affected is not the mainHand
    or offHand always add the item to the combatQueue. If the player is not in combat
    or dead or the slot is mainHand or offHand immediately perform the swap
  ]]--
  if UnitAffectingCombat(RGGM_CONSTANTS.UNIT_ID_PLAYER) or mod.common.IsPlayerReallyDead() or mod.combatQueue.IsEquipChangeBlocked() then
    if slotId ~=  INVSLOT_MAINHAND and slotId ~= INVSLOT_OFFHAND then
      mod.combatQueue.AddToQueue(itemId, slotId)
      -- if type is weapon only add it to queue if the player is dead
    elseif mod.common.IsPlayerReallyDead() then
      mod.combatQueue.AddToQueue(itemId, slotId)
    else
      me.SwitchItems(itemId, slotId, itemSlotType)
    end
  else
    me.SwitchItems(itemId, slotId, itemSlotType)
  end
end

--[[
  Switch to items from itemSlot and a bag position
    INVSLOT_HEAD
    INVSLOT_NECK
    INVSLOT_SHOULDER
    INVSLOT_CHEST
    INVSLOT_WAIST
    INVSLOT_LEGS
    INVSLOT_FEET
    INVSLOT_WRIST
    INVSLOT_HAND
    INVSLOT_FINGER1
    INVSLOT_FINGER2
    INVSLOT_TRINKET1
    INVSLOT_TRINKET2
    INVSLOT_BACK
    INVSLOT_MAINHAND
    INVSLOT_OFFHAND
    INVSLOT_RANGED

  @param {number} itemId
  @param {number} slotId
  @param {string} itemSlotType
]]--
function me.SwitchItems(itemId, slotId, itemSlotType)
  if not CursorHasItem() and not SpellIsTargeting() then
    local _, bagNumber, bagPos = me.FindItemInBag(itemId)

    if bagNumber then
      local _, _, isLocked = GetContainerItemInfo(bagNumber, bagPos)
      if not isLocked and not IsInventoryItemLocked(bagPos) then
        -- neither container item nor inventory item locked, perform swap
        PickupContainerItem(bagNumber, bagPos)
        PickupInventoryItem(slotId)
      end
    end
    -- make sure to clear combatQueue
    mod.combatQueue.RemoveFromQueue(slotId)
  end
end

--[[
  Search for an item in all bags

  @param {number} itemId

  @return {number}, {number}
]]--
function me.FindItemInBag(itemId)
  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      if strfind(GetContainerItemLink(i, j) or "", itemId, 1, 1) then
        return nil, i, j
      end
    end
  end
end

--[[
  Retrieve itemInfo

  @param {number} slotId
  @return {string | nil}, {string | nil}, {string | nil}
]]--
function me.RetrieveItemInfo(slotId)
  local link, id, name, equipSlot, texture = GetInventoryItemLink(RGGM_CONSTANTS.UNIT_ID_PLAYER, slotId)

  if link then
    _, _, id = strfind(link, "item:(%d+)")
    name, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(id)
  end

  return texture, id, equipSlot
end

--[[
  Find items in both bags and worn items that have an onUse effect. Duplicate items are filtered

  @param {table} inventoryType
  @param {boolean} mustHaveOnUse
    true - If the items have to have an onUse effect to be considered
    false - If the items do not have to have an onUse effect to be considered
]]--
function me.FindQuickChangeItems(inventoryType, mustHaveOnUse)
  local items = {}

  if inventoryType == nil then
    mod.logger.LogError(me.tag, "InventoryType(s) missing")
    return items
  end

  for i = 0, 4 do
    for j = 1, GetContainerNumSlots(i) do
      local itemId = GetContainerItemID(i, j)

      if itemId and not me.IsDuplicateItem(items, itemId) then
        local item = me.AddItemsMatchingInventoryType(inventoryType, itemId, mustHaveOnUse)

        if item ~= nil then
          table.insert(items, item)
        end
      end
    end
  end

  local gearSlots = mod.gearManager.GetGearSlots()

  for i = 1, table.getn(gearSlots) do
    local itemId = GetInventoryItemID(RGGM_CONSTANTS.UNIT_ID_PLAYER, gearSlots[i].slotId)

    if itemId and not me.IsDuplicateItem(items, itemId) then
      local item = me.AddItemsMatchingInventoryType(inventoryType, itemId, mustHaveOnUse)

      if item ~= nil then
        table.insert(items, item)
      end
    end
  end

  return items
end

--[[
  @param {table} items
  @param {number} itemId

  @return {boolean}
    true  - If the list already contains an item with the passed itemId
    false - If the list does not contain an item with the passed itemId
]]--
function me.IsDuplicateItem(items, itemId)
  for i = 1, table.getn(items) do
    if items[i].id == itemId then
      mod.logger.LogDebug(me.tag, "Filtered duplicate item - " .. items[i].name .. " - from item list")
      return true
    end
  end

  return false
end

--[[
  Check an item against certain rules
    INVTYPE_AMMO
    INVTYPE_HEAD
    INVTYPE_NECK
    INVTYPE_SHOULDER
    INVTYPE_BODY
    INVTYPE_CHEST
    INVTYPE_ROBE
    INVTYPE_WAIST
    INVTYPE_LEGS
    INVTYPE_FEET
    INVTYPE_WRIST
    INVTYPE_HAND
    INVTYPE_FINGER
    INVTYPE_TRINKET
    INVTYPE_CLOAK
    INVTYPE_WEAPON
    INVTYPE_SHIELD
    INVTYPE_2HWEAPON
    INVTYPE_WEAPONMAINHAND
    INVTYPE_WEAPONOFFHAND


  @param {table} inventoryType
  @param {number} itemId
  @param {boolean} mustHaveOnUse
    true - If the items have to have an onUse effect to be considered
    false - If the items do not have to have an onUse effect to be considered

  @return {table, nil}
    table - If an item could be found
    nil - If no item could be found
]]--
function me.AddItemsMatchingInventoryType(inventoryType, itemId, mustHaveOnUse)
  local item = nil
  local itemName, _, itemRarity, _, _, _, _, _, equipSlot, itemIcon = GetItemInfo(itemId)

  for it = 1, table.getn(inventoryType) do
    if equipSlot == inventoryType[it] then
      local spellName, spellId = GetItemSpell(itemId)

      if spellName ~= nil and spellId ~= nil or not mustHaveOnUse then
        item = {}
        item.name = itemName
        item.id = itemId
        item.texture = itemIcon
      else
        mod.logger.LogDebug(me.tag, "Skipped item: " .. itemName .. " because it has no onUse effect")
        return nil
      end
    end
  end

  return item
end