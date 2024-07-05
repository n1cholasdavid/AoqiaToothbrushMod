-- -------------------------------------------------------------------------- --
--                 Registers tweaks using the ItemTweakerAPI.                 --
-- -------------------------------------------------------------------------- --

local getScriptManager = getScriptManager

local mod_constants = require("AoqiaToothbrushMod/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local tweaks = {}

function tweaks.init()
    logger:debug("Applying tweaks...")

    local script_manager = getScriptManager()
    local tweak_table = {
        ["Base.Toothbrush"] = {
            ["DisplayCategory"] = "FirstAid",
            ["Tags"] = "Toothbrush",
            ["Tooltip"] = string.format("Tooltip_%s_Toothbrush", mod_constants.MOD_ID),
            ["Weight"] = 0.05,
        },
        ["Base.Toothpaste"] = {
            ["DisplayCategory"] = "FirstAid",
            ["Tags"] = "Toothpaste",
            ["Tooltip"] = string.format("Tooltip_%s_Toothpaste", mod_constants.MOD_ID),
            ["Weight"] = 0.05,
        }
    }

    for item, data in pairs(tweak_table) do
        for prop, val in pairs(data) do
            local item = script_manager:getItem(item)
            if item ~= nil then
                item:DoParam(prop .. " = " .. val)
            end
        end
    end
end

return tweaks
