-- -------------------------------------------------------------------------- --
--             Handles the procedural distributions (loot tables)             --
-- -------------------------------------------------------------------------- --

local table = table

require("Items/ProceduralDistributions")
local ProceduralDistributions = ProceduralDistributions

local AQConstants = require("AoqiaToothbrushMod/AQConstants")
local AQLog = require("AoqiaToothbrushMod/AQLog")

-- ------------------------------ Module Start ------------------------------ --

local AQProceduralDistributions = {}

AQProceduralDistributions.toothpasteContainers = {
    "BathroomCabinet",
    "BathroomCounter",
    "BathroomShelf",
    "PharmacyCosmetics",
    "PrisonCellRandom",
}

AQProceduralDistributions.toothpasteItems = {
    { ["item"] = "AoqiaToothbrushMod.ToothbrushRed",             ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushOrange",          ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushYellow",          ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushGreen",           ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushLightBlue",       ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushDarkBlue",        ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushPurple",          ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushMagenta",         ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushPink",            ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushRosePink",        ["chance"] = 10 },

    { ["item"] = "AoqiaToothbrushMod.ToothbrushTollgateGreen",   ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushTollgateBlue",    ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushTollgatePurple",  ["chance"] = 10 },
    { ["item"] = "AoqiaToothbrushMod.ToothbrushTollgateMagenta", ["chance"] = 10 },
}

function AQProceduralDistributions.init()
    AQLog.debugServer("Adding custom items to loot table...")

    for _, v in pairs(AQProceduralDistributions.toothpasteContainers) do
        for k2, v2 in pairs(AQProceduralDistributions.toothpasteItems) do
            if k2 == "item" then
                v2 = (AQConstants.MOD_ID .. v2)
            end

            table.insert(ProceduralDistributions.list[v].items, v2)
        end
    end
end

return AQProceduralDistributions
