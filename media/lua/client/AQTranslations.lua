-- -------------------------------------------------------------------------- --
--   Caches translations so that we don't call `getText()` a billion times.   --
-- -------------------------------------------------------------------------- --

local getText = getText

-- ------------------------------ Module Start ------------------------------ --

local AQTranslations = {}

-- Vanilla
AQTranslations.ContextMenu_WaterName = "nil"
-- Modded
AQTranslations.ContextMenu_AQBrushTeeth = "nil"
AQTranslations.IGUI_AQBrushTeeth_WithoutToothpaste = "nil"
AQTranslations.IGUI_AQBrushTeeth_Toothpaste = "nil"

function AQTranslations.update()
    -- Vanilla
    AQTranslations.ContextMenu_WaterName = getText("ContextMenu_WaterName")
    -- Modded
    AQTranslations.ContextMenu_AQBrushTeeth = getText("ContextMenu_AQBrushTeeth")
    AQTranslations.ContextMenu_AQBrushTeeth_AlreadyBrushed = getText("ContextMenu_AQBrushTeeth_AlreadyBrushed")
    AQTranslations.ContextMenu_AQBrushTeeth_TooDepressed = getText("ContextMenu_AQBrushTeeth_TooDepressed")
    AQTranslations.IGUI_AQBrushTeeth_WithoutToothpaste = getText("IGUI_AQBrushTeeth_WithoutToothpaste")
    AQTranslations.IGUI_AQBrushTeeth_Toothpaste = getText("IGUI_AQBrushTeeth_Toothpaste")
end

return AQTranslations
