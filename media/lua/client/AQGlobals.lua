-- -------------------------------------------------------------------------- --
--                  Stores global information used by the mod                 --
-- -------------------------------------------------------------------------- --

-- ------------------------------ Module Start ------------------------------ --

if AQGlobals then
    print("[aoqia-toothpaste-mod]: AQGlobals already defined.")
    -- return AQGlobals
end

-- Need this to be global for the above to work.
AQGlobals = {
    -- How dirty the player's teeth is. Minimum = 0.0, maximum = 1.0.
    -- teethDirtValue = 0.0,
    -- How fast the player's teeth get dirty over time. Minimum = 0.0, maximum >= 1.0.
    -- dirtyTeethRate = 1.0,
    -- How fast the player's teeth get clean when brushing. Minimum = 0.0, maximum >= 1.0.
    -- cleanTeethRate = 0.01,
    -- How many days the player has not brushed their teeth for.
    daysWithoutBrushingTeeth = 0,
}

return AQGlobals
