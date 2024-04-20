-- -------------------------------------------------------------------------- --
--                 Handles the context menu for world objects.                --
-- -------------------------------------------------------------------------- --

local math = math
local string = string

local ipairs = ipairs

require("luautils")
require("TimedActions/ISTimedActionQueue")
require("ISUI/ISInventoryPaneContextMenu")
require("ISUI/ISWorldObjectContextMenu")
local luautils = luautils
local ISInventoryPane = ISInventoryPane
local ISInventoryPaneContextMenu = ISInventoryPaneContextMenu
local ISTimedActionQueue = ISTimedActionQueue
local ISWorldObjectContextMenu = ISWorldObjectContextMenu
local SandboxVars = SandboxVars

local instanceof = instanceof
local getSpecificPlayer = getSpecificPlayer

local AQBrushTeeth = require("AoqiaToothbrushMod/TimedActions/AQBrushTeeth")
local AQConstants = require("AoqiaToothbrushMod/AQConstants")
local AQTranslations = require("AoqiaToothbrushMod/AQTranslations")

-- ------------------------------ Module Start ------------------------------ --

local AQWorldObjectContextMenu = {}

---@param player number
---@param waterObj IsoObject
---@param toothbrush ComboItem
---@param toothpaste ComboItem
function AQWorldObjectContextMenu.onBrushTeeth(waterObj, player, toothbrush, toothpaste)
    local playerObj = getSpecificPlayer(player)

    if not waterObj:getSquare() or not luautils.walkAdj(playerObj, waterObj:getSquare(), true) then
        return
    end

    local time = SandboxVars[AQConstants.MOD_ID].BrushTeethTime
    if AQBrushTeeth.getRequiredToothpaste() > 1 --[[ AQBrushTeeth.getToothpasteRemaining(toothpaste) ]] then
        time = time * 2
    end

    if SandboxVars[AQConstants.MOD_ID].TransferItemsOnUse then
        local items = ISInventoryPane.getActualItems({ toothbrush, toothpaste })
        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, items[1])
        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, items[2])
    end
    ISTimedActionQueue.add(AQBrushTeeth:new(playerObj, waterObj, toothbrush, toothpaste, time))
end

---@param waterObj IsoObject
---@param playerNum number
---@param context ISContextMenu
function AQWorldObjectContextMenu.doBrushTeethMenu(waterObj, playerNum, context)
    local player = getSpecificPlayer(playerNum)
    local playerInv = player:getInventory()

    ---@type AQPlayerModDataStruct
    local data = player:getModData()[AQConstants.MOD_ID]

    if waterObj:getSquare():getBuilding() ~= player:getBuilding() then return end
    if instanceof(waterObj, "IsoClothingDryer") then return end
    if instanceof(waterObj, "IsoClothingWasher") then return end
    if instanceof(waterObj, "IsoCombinationWasherDryer") then return end

    if not playerInv:containsTypeRecurse("Toothbrush") then return end
    local toothbrush = playerInv:getItemFromTypeRecurse("Toothbrush")
    local toothpastes = playerInv:getItemsFromType("Toothpaste")

    -- Context menu shtuff
    local option = context:addOption(AQTranslations.ContextMenu_BrushTeeth, waterObj,
        AQWorldObjectContextMenu.onBrushTeeth, playerNum, toothbrush, toothpastes)
    local tooltip = ISWorldObjectContextMenu.addToolTip()

    local waterRemaining = waterObj:getWaterAmount()
    local waterRequired = AQBrushTeeth.getRequiredWater()
    local toothpasteRemaining = toothpastes:size()
    local toothpasteRequired = AQBrushTeeth.getRequiredToothpaste()

    -- local source = nil
    -- if source == nil then
    --     -- this will always try to call nil. I believe waterObj doesn't have a `getItem()` method.
    --     source = waterObj:getItem():getDisplayName()
    --     if source == nil then
    --         source = getText("ContextMenu_NaturalWaterSource")
    --     end
    -- end

    if toothpasteRemaining < toothpasteRequired then
        tooltip.description = tooltip.description .. AQTranslations.IGUI_WithoutToothpaste
    else
        tooltip.description = tooltip.description ..
            string.format("%s: %d / %d", AQTranslations.IGUI_Toothpaste,
                toothpasteRequired, toothpasteRequired)
    end
    tooltip.description = tooltip.description .. " <LINE> " ..
        string.format("%s: %d / %d", AQTranslations.ContextMenu_WaterName,
            math.min(waterRemaining, waterRequired), waterRequired)

    local unhappyLevel = player:getBodyDamage():getUnhappynessLevel()
    if unhappyLevel > 80 then
        tooltip.description = tooltip.description .. " <LINE> <RGB:1,0,0> " ..
            AQTranslations.ContextMenu_TooDepressed
    end
    option.toolTip = tooltip

    local minBrushTime = (1440 / 10) / data.brushTeethNewMaxValue
    if waterRemaining < 1 or unhappyLevel > 80 or (data.timeLastBrushTenMins < minBrushTime and data.todayBrushCount ~= 0) then
        option.notAvailable = true
    end
end

---@param player number
---@param context ISContextMenu
---@param worldobjects table<number, IsoObject>
---@param test boolean
function AQWorldObjectContextMenu.createMenu(player, context, worldobjects, test)
    local waterObj = nil
    for i, v in ipairs(worldobjects) do
        if v:hasWater() then
            waterObj = v
        end
    end

    if waterObj and not AQConstants.IS_LAST_STAND then
        if test == true then return true end

        if waterObj:hasWater() then
            AQWorldObjectContextMenu.doBrushTeethMenu(waterObj, player, context)
        end
    end
end

return AQWorldObjectContextMenu
