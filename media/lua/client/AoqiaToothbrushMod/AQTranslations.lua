-- -------------------------------------------------------------------------- --
--   Caches translations so that we don't call `getText()` a billion times.   --
-- -------------------------------------------------------------------------- --

local getText                             = getText

local AQConstants                         = require("AoqiaToothbrushMod/AQConstants")
local AQLog = require("AoqiaToothbrushMod/AQLog")

-- ------------------------------ Module Start ------------------------------ --

local AQTranslations                      = {}

-- Only really for autocomplete.
-- Vanilla
AQTranslations.ContextMenu_WaterName      = nil
-- Modded
AQTranslations.ContextMenu_BrushTeeth     = nil
AQTranslations.ContextMenu_AlreadyBrushed = nil
AQTranslations.ContextMenu_TooDepressed   = nil
AQTranslations.IGUI_WithoutToothpaste     = nil
AQTranslations.IGUI_Toothpaste            = nil
AQTranslations.Sandbox_Test               = nil
AQTranslations.Tooltip_Toothbrush         = nil
AQTranslations.Tooltip_Toothpaste         = nil
AQTranslations.UI_GoldenBrusherTrait      = nil
AQTranslations.UI_GoldenBrusherTraitDesc  = nil
AQTranslations.UI_FoulBrusherTrait        = nil
AQTranslations.UI_FoulBrusherTraitDesc    = nil

-- Translation Keys
-- Vanilla
AQTranslations.ContextMenu_WaterName_key      = "ContextMenu_WaterName"
-- Modded
AQTranslations.ContextMenu_BrushTeeth_key     = ("ContextMenu_" .. AQConstants.MOD_ID .. "_BrushTeeth")
AQTranslations.ContextMenu_AlreadyBrushed_key = ("ContextMenu_" .. AQConstants.MOD_ID .. "_AlreadyBrushed")
AQTranslations.ContextMenu_TooDepressed_key   = ("ContextMenu_" .. AQConstants.MOD_ID .. "_TooDepressed")
AQTranslations.IGUI_WithoutToothpaste_key     = ("IGUI_" .. AQConstants.MOD_ID .. "_WithoutToothpaste")
AQTranslations.IGUI_Toothpaste_key            = ("IGUI_" .. AQConstants.MOD_ID .. "_Toothpaste")
AQTranslations.Sandbox_Test_key               = ("Sandbox_" .. AQConstants.MOD_ID .. "_Test")
AQTranslations.Tooltip_Toothbrush_key         = ("Tooltip_" .. AQConstants.MOD_ID .. "_Toothbrush")
AQTranslations.Tooltip_Toothpaste_key         = ("Tooltip_" .. AQConstants.MOD_ID .. "_Toothpaste")
AQTranslations.UI_GoldenBrusherTrait_key      = ("UI_" .. AQConstants.MOD_ID .. "_GoldenBrusherTrait")
AQTranslations.UI_GoldenBrusherTraitDesc_key  = ("UI_" .. AQConstants.MOD_ID .. "_GoldenBrusherTraitDesc")
AQTranslations.UI_FoulBrusherTrait_key        = ("UI_" .. AQConstants.MOD_ID .. "_FoulBrusherTrait")
AQTranslations.UI_FoulBrusherTraitDesc_key    = ("UI_" .. AQConstants.MOD_ID .. "_FoulBrusherTraitDesc")

function AQTranslations.init()
    AQLog.debug("Caching translations...")

    -- Vanilla
    AQTranslations.ContextMenu_WaterName = getText(AQTranslations.ContextMenu_WaterName_key)
    -- Modded
    AQTranslations.ContextMenu_BrushTeeth = getText(AQTranslations.ContextMenu_BrushTeeth_key)
    AQTranslations.ContextMenu_AlreadyBrushed = getText(AQTranslations.ContextMenu_AlreadyBrushed_key)
    AQTranslations.ContextMenu_TooDepressed = getText(AQTranslations.ContextMenu_TooDepressed_key)
    AQTranslations.IGUI_WithoutToothpaste = getText(AQTranslations.IGUI_WithoutToothpaste_key)
    AQTranslations.IGUI_Toothpaste = getText(AQTranslations.IGUI_Toothpaste_key)
    AQTranslations.Sandbox_Test = getText(AQTranslations.Sandbox_Test_key)
    AQTranslations.Tooltip_Toothbrush = getText(AQTranslations.Tooltip_Toothbrush_key)
    AQTranslations.Tooltip_Toothpaste = getText(AQTranslations.Tooltip_Toothpaste_key)
    AQTranslations.UI_GoldenBrusherTrait = getText(AQTranslations.UI_GoldenBrusherTrait_key)
    AQTranslations.UI_GoldenBrusherTraitDesc = getText(AQTranslations.UI_GoldenBrusherTraitDesc_key)
    AQTranslations.UI_FoulBrusherTrait = getText(AQTranslations.UI_FoulBrusherTrait_key)
    AQTranslations.UI_FoulBrusherTraitDesc = getText(AQTranslations.UI_FoulBrusherTraitDesc_key)
end

return AQTranslations
