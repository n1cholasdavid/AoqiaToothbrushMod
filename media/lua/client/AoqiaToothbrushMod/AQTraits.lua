-- -------------------------------------------------------------------------- --
--                    Defines and adds traits to the game.                    --
-- -------------------------------------------------------------------------- --

local TraitFactory = TraitFactory

local AQLog = require("AoqiaToothbrushMod/AQLog")
local AQTranslations = require("AoqiaToothbrushMod/AQTranslations")

-- ------------------------------ Module Start ------------------------------ --

local AQTraits = {}

function AQTraits.init()
    AQLog.debug("Creating traits...")

    TraitFactory.addTrait("GoldenBrusher",
        AQTranslations.UI_GoldenBrusherTrait, 2,
        AQTranslations.UI_GoldenBrusherTraitDesc, false)
    TraitFactory.addTrait("FoulBrusher",
        AQTranslations.UI_FoulBrusherTrait, -2,
        AQTranslations.UI_FoulBrusherTraitDesc, false)
    TraitFactory.setMutualExclusive("GoldenBrusher", "FoulBrusher")
end

return AQTraits
