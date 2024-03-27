-- -------------------------------------------------------------------------- --
--                 Registers tweaks using the ItemTweakerAPI.                 --
-- -------------------------------------------------------------------------- --

local AQUtils = require("AQUtils")

-- ------------------------------ Module Start ------------------------------ --

local AQTweaks = {}

function AQTweaks.apply()
    local activated_mods = getActivatedMods()
    if activated_mods:contains("ItemTweakerAPI") then
        require("ItemTweaker_Core")
    else
        AQUtils.logerror("Failed to find ItemTweakerAPI.")
        return
    end

    do
        local TweakItem = TweakItem
        local tweaks = {
            ["Base.Toothbrush"] = {
                ["DisplayCategory"] = "FirstAid",
                ["Weight"] = "0.05",
                ["Tooltip"] = "Tooltip_AQToothbrush",
            },
            ["Base.Toothpaste"] = {
                ["DisplayCategory"] = "FirstAid",
                -- NOTE: As much as I'd like to do this, I cannot until I figure out how to handle item type change deleting it from world.
                -- ["Type"] = "Drainable",
                ["UseDelta"] = "0.05",
                ["UseWhileEquipped"] = "FALSE",
                ["cantBeConsolidated"] = "TRUE",
                ["Tooltip"] = "Tooltip_AQToothpaste",
            }
        }

        for item, itemData in pairs(tweaks) do
            for tweak, tweakValue in pairs(itemData) do
                TweakItem(item, tweak, tweakValue)
            end
        end
    end
end

return AQTweaks
