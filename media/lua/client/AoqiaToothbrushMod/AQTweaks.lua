-- -------------------------------------------------------------------------- --
--                 Registers tweaks using the ItemTweakerAPI.                 --
-- -------------------------------------------------------------------------- --

local AQTranslations = require("AoqiaToothbrushMod/AQTranslations")

-- ------------------------------ Module Start ------------------------------ --

local AQTweaks = {}

function AQTweaks.apply()
    do
        local TweakItem = TweakItem
        local tweaks = {
            ["Base.Toothbrush"] = {
                ["DisplayCategory"] = "FirstAid",
                ["Weight"] = "0.05",
                ["Tooltip"] = AQTranslations.Tooltip_Toothbrush,
            },
            ["Base.Toothpaste"] = {
                ["DisplayCategory"] = "FirstAid",
                -- TODO: As much as I'd like to do this, I cannot until I figure out how to handle item type change deleting it from world.
                -- ["Type"] = "Drainable",
                ["UseDelta"] = "0.05",
                ["UseWhileEquipped"] = "FALSE",
                ["cantBeConsolided"] = "TRUE",
                ["Tooltip"] = AQTranslations.Tooltip_Toothpaste,
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
