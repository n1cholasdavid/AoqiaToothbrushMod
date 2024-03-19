--[[
---@param recipe ItemRecipe
---@param player IsoPlayer
function Recipe.OnCanPerform.ToothbrushBrushTeeth(recipe, player)
    local isDepressed = player:getMoodleLevel(MoodleType.Unhappy) >= 3
    return not isDepressed
end

---@param player IsoPlayer
function Recipe.OnCreate.ToothbrushBrushTeeth(items, result, player)
    player:getInventory():AddItem("Base.ElectronicsScrap")
end
--]]
