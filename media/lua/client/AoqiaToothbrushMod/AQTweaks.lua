-- -------------------------------------------------------------------------- --
--                 Registers tweaks using the ItemTweakerAPI.                 --
-- -------------------------------------------------------------------------- --

local AQLog = require("AoqiaToothbrushMod/AQLog")
local AQTranslations = require("AoqiaToothbrushMod/AQTranslations")

-- ------------------------------ Module Start ------------------------------ --

local AQTweaks = {}

function AQTweaks.init()
    AQLog.debug("Applying tweaks...")

    local TweakItem = TweakItem
    local tweaks = {
        ["Base.Toothbrush"] = {
            ["DisplayCategory"] = "FirstAid",
            ["Weight"] = "0.05",
            ["Tooltip"] = AQTranslations.Tooltip_Toothbrush_key,
        },
        ["Base.Toothpaste"] = {
            ["DisplayCategory"] = "FirstAid",
            -- TODO: As much as I'd like to do this, I cannot until I figure out how to handle item type change deleting it from world.
            -- ["Type"] = "Drainable",
            ["UseDelta"] = "0.05",
            ["UseWhileEquipped"] = "FALSE",
            ["cantBeConsolided"] = "TRUE",
            ["Tooltip"] = AQTranslations.Tooltip_Toothpaste_key,
        }
    }

    for item, itemData in pairs(tweaks) do
        for tweak, tweakValue in pairs(itemData) do
            TweakItem(item, tweak, tweakValue)
        end
    end
end

return AQTweaks
