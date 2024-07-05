-- -------------------------------------------------------------------------- --
--                 Handles the context menu for world objects.                --
-- -------------------------------------------------------------------------- --

local math = math
local string = string

local ipairs = ipairs

require("TimedActions/ISTimedActionQueue")
require("ISUI/ISInventoryPaneContextMenu")
require("ISUI/ISWorldObjectContextMenu")
require("luautils")

local ISTimedActionQueue = ISTimedActionQueue
local ISInventoryPaneContextMenu = ISInventoryPaneContextMenu
local ISWorldObjectContextMenu = ISWorldObjectContextMenu
local luautils = luautils

local SandboxVars = SandboxVars

local instanceof = instanceof
local getSpecificPlayer = getSpecificPlayer

local constants = require("AoqiaZomboidUtils/constants")

local brush_teeth = require("AoqiaToothbrushMod/actions/brush_teeth")

local mod_constants = require("AoqiaToothbrushMod/mod_constants")

-- ------------------------------ Module Start ------------------------------ --

local context_menu = {}

---@param player number
---@param waterObj IsoObject
---@param toothbrush InventoryItem
---@param toothpaste InventoryItem|nil
function context_menu.on_brush_teeth(waterObj, player, toothbrush, toothpaste)
    local playerObj = getSpecificPlayer(player)

    if not waterObj:getSquare() or not luautils.walkAdj(playerObj, waterObj:getSquare(), true) then
        return
    end

    ---@type sandboxvars_struct
    ---@diagnostic disable-next-line: assign-type-mismatch
    local sandboxVars = SandboxVars[mod_constants.MOD_ID]

    local time = sandboxVars.BrushTeethTime
    if toothpaste == nil --[[or toothpaste < sandboxVars.BrushTeethRequiredToothpaste]] then
        time = time * 2
    end

    if sandboxVars.DoTransferItemsOnUse then
        ISInventoryPaneContextMenu.transferIfNeeded(playerObj, toothbrush)

        if toothpaste ~= nil then
            ISInventoryPaneContextMenu.transferIfNeeded(playerObj, toothpaste)
        end
    end

    ISTimedActionQueue.add(brush_teeth:new(playerObj, waterObj, toothbrush, toothpaste, time))
end

---@param waterObj IsoObject
---@param playerNum number
---@param context ISContextMenu
function context_menu.do_menu(waterObj, playerNum, context)
    local player = getSpecificPlayer(playerNum)
    local playerInv = player:getInventory()

    ---@type moddata_struct
    local data = player:getModData()[mod_constants.MOD_ID]

    ---@type sandboxvars_struct
    ---@diagnostic disable-next-line: assign-type-mismatch
    local sandboxVars = SandboxVars[mod_constants.MOD_ID]

    if waterObj:getSquare():getBuilding() ~= player:getBuilding() then return end
    if instanceof(waterObj, "IsoClothingDryer") then return end
    if instanceof(waterObj, "IsoClothingWasher") then return end
    if instanceof(waterObj, "IsoCombinationWasherDryer") then return end

    local toothbrush = playerInv:getFirstTagRecurse("Toothbrush")
    if toothbrush == nil then return end

    local toothpaste = playerInv:getFirstTagRecurse("Toothpaste")

    -- Context menu shtuff
    local option = context:addOption(getText(string.format("ContextMenu_%s_BrushTeeth", mod_constants.MOD_ID)),
        waterObj, context_menu.on_brush_teeth, playerNum, toothbrush, toothpaste)
    local tooltip = ISWorldObjectContextMenu.addToolTip()

    local waterRemaining = waterObj:getWaterAmount()
    local waterRequired = sandboxVars.BrushTeethRequiredWater
    local toothpasteRequired = sandboxVars.BrushTeethRequiredToothpaste

    -- local source = nil
    -- if source == nil then
    --     -- this will always try to call nil. I believe waterObj doesn't have a `getItem()` method.
    --     source = waterObj:getItem():getDisplayName()
    --     if source == nil then
    --         source = getText("ContextMenu_NaturalWaterSource")
    --     end
    -- end

    if toothpaste == nil then
        tooltip.description = tooltip.description ..
            getText(string.format("IGUI_%s_WithoutToothpaste", mod_constants.MOD_ID))
    else
        tooltip.description = tooltip.description ..
            string.format("%s: %d / %d", getText(string.format("IGUI_%s_Toothpaste", mod_constants.MOD_ID)),
                toothpasteRequired, toothpasteRequired)
    end

    tooltip.description = tooltip.description .. " <LINE> " ..
        string.format("%s: %d / %d", getText("ContextMenu_WaterName"),
            math.min(waterRemaining, waterRequired), waterRequired)

    local unhappyLevel = player:getBodyDamage():getUnhappynessLevel()
    if unhappyLevel > 80 then
        tooltip.description = tooltip.description .. " <LINE><RGB:1,0,0> " ..
            getText(string.format("ContextMenu_%s_TooDepressed", mod_constants.MOD_ID))
    end

    local minBrushTime = (1440 / 10) / data.brushTeethNewMaxValue
    local too_recent = data.timeLastBrushTenMins < minBrushTime and data.todayBrushCount ~= 0
    if too_recent then
        tooltip.description = tooltip.description .. " <LINE><RGB:1,0,0> " ..
            getText(string.format("ContextMenu_%s_TooRecent", mod_constants.MOD_ID))
    end
    
    option.toolTip = tooltip

    if waterRemaining < 1 or unhappyLevel > 80 or too_recent then
        option.notAvailable = true
    end
end

---@param player number
---@param context ISContextMenu
---@param worldobjects table<number, IsoObject>
---@param test boolean
function context_menu.create_menu(player, context, worldobjects, test)
    --- @type IsoObject
    local water_obj = nil
    for _, obj in ipairs(worldobjects) do
        if obj:hasWater() then
            water_obj = obj
        end
    end

    if water_obj and constants.IS_LAST_STAND == false then
        if test then return true end

        if water_obj:hasWater() then
            context_menu.do_menu(water_obj, player, context)
        end
    end
end

return context_menu
