-- -------------------------------------------------------------------------- --
--   Caches translations so that we don't call `getText()` a billion times.   --
-- -------------------------------------------------------------------------- --

local getText = getText

local AQConstants = require("AQConstants")

-- ------------------------------ Module Start ------------------------------ --

local AQTranslations = {}

-- Only really for autocomplete.
-- Vanilla
AQTranslations.ContextMenu_WaterName = nil
-- Modded
AQTranslations.ContextMenu_BrushTeeth = nil
AQTranslations.ContextMenu_AlreadyBrushed = nil
AQTranslations.ContextMenu_TooDepressed = nil
AQTranslations.IGUI_WithoutToothpaste = nil
AQTranslations.IGUI_Toothpaste = nil
AQTranslations.Sandbox_Test = nil

function AQTranslations.update()
    -- Vanilla
    AQTranslations.ContextMenu_WaterName = getText("ContextMenu_WaterName")
    -- Modded
    AQTranslations.ContextMenu_BrushTeeth = getText("ContextMenu_" .. AQConstants.MOD_ID .. "_BrushTeeth")
    AQTranslations.ContextMenu_AlreadyBrushed = getText("ContextMenu_" .. AQConstants.MOD_ID .. "_AlreadyBrushed")
    AQTranslations.ContextMenu_TooDepressed = getText("ContextMenu_" .. AQConstants.MOD_ID .. "_TooDepressed")
    AQTranslations.IGUI_WithoutToothpaste = getText("IGUI_" .. AQConstants.MOD_ID .. "_WithoutToothpaste")
    AQTranslations.IGUI_Toothpaste = getText("IGUI_" .. AQConstants.MOD_ID .. "_Toothpaste")
    AQTranslations.Sandbox_Test = getText("Sandbox_" .. AQConstants.MOD_ID .. "_Test")
end

return AQTranslations
