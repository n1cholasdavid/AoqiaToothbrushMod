-- -------------------------------------------------------------------------- --
--             Handles the procedural distributions (loot tables)             --
-- -------------------------------------------------------------------------- --

local table = table

require("Items/ProceduralDistributions")
local ProceduralDistributions = ProceduralDistributions

local mod_constants = require("AoqiaToothbrushMod/mod_constants")

local logger = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local distributions = {}
distributions.toothbrush = {}

distributions.toothbrush.containers = {
    "BathroomCabinet",
    "BathroomCounter",
    "BathroomShelf",
    "PharmacyCosmetics",
    "PrisonCellRandom",
}

distributions.toothbrush.items = {
    { ["item"] = "ToothbrushRed",             ["chance"] = 10 },
    { ["item"] = "ToothbrushOrange",          ["chance"] = 10 },
    { ["item"] = "ToothbrushYellow",          ["chance"] = 10 },
    { ["item"] = "ToothbrushGreen",           ["chance"] = 10 },
    { ["item"] = "ToothbrushLightBlue",       ["chance"] = 10 },
    { ["item"] = "ToothbrushDarkBlue",        ["chance"] = 10 },
    { ["item"] = "ToothbrushPurple",          ["chance"] = 10 },
    { ["item"] = "ToothbrushMagenta",         ["chance"] = 10 },
    { ["item"] = "ToothbrushPink",            ["chance"] = 10 },
    { ["item"] = "ToothbrushRosePink",        ["chance"] = 10 },
    { ["item"] = "ToothbrushTollgateGreen",   ["chance"] = 10 },
    { ["item"] = "ToothbrushTollgateBlue",    ["chance"] = 10 },
    { ["item"] = "ToothbrushTollgatePurple",  ["chance"] = 10 },
    { ["item"] = "ToothbrushTollgateMagenta", ["chance"] = 10 },
}

function distributions.register()
    logger:debug_server("Adding custom items to loot table...")

    for _, v in pairs(distributions.toothbrush.containers) do
        for k2, v2 in pairs(distributions.toothbrush.items) do
            if k2 == "item" then
                v2 = (mod_constants.MOD_ID .. v2)
            end

            table.insert(ProceduralDistributions.list[v].items, v2)
        end
    end
end

return distributions
