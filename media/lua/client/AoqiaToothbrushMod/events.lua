-- -------------------------------------------------------------------------- --
--            Handles event stuff like registering listeners/hooks.           --
-- -------------------------------------------------------------------------- --

-- STD Lua Global Tables/Variables
local math        = math
-- STD Lua Global Functions
local pairs       = pairs

-- Vanilla Global Tables/Variables
local Events      = Events
local ModData     = ModData
local SandboxVars = SandboxVars
-- Vanilla Global Functions
local getPlayer   = getPlayer

-- Dependency Global Tables/Variables
require("MF_ISMoodle")
local moodle_factory           = MF

-- My Mod Modules
local context_menu             = require("AoqiaToothbrushMod/ui/context_menu")

local mod_constants            = require("AoqiaToothbrushMod/mod_constants")
local moodle_manager           = require("AoqiaToothbrushMod/moodle_manager")
local trait_manager            = require("AoqiaToothbrushMod/trait_manager")
local tweaks                   = require("AoqiaToothbrushMod/tweaks")
local types                    = require("AoqiaToothbrushMod/types")

local logger                   = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local events                   = {}

-- NOTE: Probably move these dummy structs to a more suitable location? Although I can't figure out where.

---@class moddata_struct
---@field _modVersion string Tracks what version of the mod belongs to the mod data.
---@field daysBrushedCount number Tracks the number of days CONSECUTIVELY the player has brushed their teeth at least once.
---@field daysBrushedToMax number Tracks how many times player CONSECUTIVELY brushed teeth >= sandbox Max Value for n days.
---@field todayBrushCount number Tracks how many times player brushed teeth today.
---@field totalBrushCount number Tracks how many times player brushed teeth total.
---@field daysNotBrushed number Tracks how many CONSECUTIVE times player didn't brush teeth total.
---@field brushTeethNewMaxValue number Tracks the sandbox option "Brush Teeth Max Value" based on if the player has one of the traits.
---@field timeLastBrushTenMins number Tracks how much time (in 10 minute intervals) since the last brush.
local moddata_dummy_struct     = {
    _modVersion = mod_constants.MOD_VERSION,
    daysBrushedCount = 0,
    daysBrushedToMax = 0,
    todayBrushCount = 0,
    totalBrushCount = 0,
    daysNotBrushed = 0,
    brushTeethNewMaxValue = 0,
    timeLastBrushTenMins = 0,
}

---@class sandboxvars_struct
---@field DoTransferItemsOnUse boolean
---@field DoDailyEffect boolean
---@field DailyEffectType number
---@field DailyEffectExponent number
---@field DailyEffectAlternateExponent number
---@field DailyEffectMaxValue number
---@field DailyEffectAlternateMaxValue number
---@field DailyEffectGracePeriod number
---@field DoBrushTeethEffect boolean
---@field BrushTeethEffectType number
---@field BrushTeethEffectAmount number
---@field BrushTeethEffectAlternateAmount number
---@field BrushTeethTime number
---@field BrushTeethMaxValue number
---@field BrushTeethRequiredWater number
---@field BrushTeethRequiredToothpaste number
---@field GoodTraitCount number
---@field BadTraitCount number
local sandboxvars_dummy_struct = {
    DoTransferItemsOnUse = true,
    -- Daily Effect
    DoDailyEffect = true,
    DailyEffectType = 1,
    DailyEffectExponent = 0.12,
    DailyEffectAlternateExponent = 0.12,
    DailyEffectMaxValue = 25,
    DailyEffectAlternateMaxValue = 25,
    DailyEffectGracePeriod = 2,
    -- Brush Teeth Effect
    DoBrushTeethEffect = true,
    BrushTeethEffectType = 1,
    BrushTeethEffectAmount = 10,
    BrushTeethEffectAlternateAmount = 10,
    -- Brush Teeth Vars
    BrushTeethTime = 600,
    BrushTeethMaxValue = 2,
    BrushTeethRequiredWater = 1,
    BrushTeethRequiredToothpaste = 1,
    -- Trait Vars
    GoodTraitCount = 10,
    BadTraitCount = 7,
}

function events.every_ten_minutes()
    local player = getPlayer()

    ---@type moddata_struct
    local data = player:getModData()[mod_constants.MOD_ID]

    data.timeLastBrushTenMins = data.timeLastBrushTenMins + 10
end

function events.every_days()
    local player = getPlayer()
    local traits = player:getTraits()
    local stats = player:getStats()
    local bd = player:getBodyDamage()

    ---@type moddata_struct
    local data = player:getModData()[mod_constants.MOD_ID]

    -- Daily mod data update logic
    if data.todayBrushCount == 0 then
        data.daysNotBrushed = data.daysNotBrushed + 1
        data.daysBrushedToMax = 0
        data.daysBrushedCount = 0
    else
        data.daysBrushedCount = data.daysBrushedCount + 1
        data.daysNotBrushed = 0
    end

    -- Trait stuff is below.
    -- Trait logic is calculated daily because it closely relies on the amount of days not brushed.

    ---@type sandboxvars_struct
    ---@diagnostic disable-next-line: assign-type-mismatch
    local sandboxVars = SandboxVars[mod_constants.MOD_ID]
    if not sandboxVars or sandboxVars.DoTransferItemsOnUse == nil then
        logger.error("No sandbox variables found. " ..
            "This should never happen so please make an issue on github or comment on the mod workshop page.")
        return
    end

    -- Assign trait depending on mod data
    if data.daysNotBrushed >= sandboxVars.BadTraitCount and player:HasTrait("FoulBrusher") == false then
        if player:HasTrait("GoldenBrusher") then
            traits:remove("GoldenBrusher")
        end

        traits:add("FoulBrusher")
    elseif data.daysBrushedToMax >= sandboxVars.GoodTraitCount and player:HasTrait("GoldenBrusher") == false then
        if player:HasTrait("FoulBrusher") then
            traits:remove("FoulBrusher")
        end

        traits:add("GoldenBrusher")
    end

    -- Remove GoldenBrusher if we have haven't brushed
    -- Remove FoulBrusher if we have brushed
    if data.daysBrushedToMax == 0 and player:HasTrait("GoldenBrusher") then
        traits:remove("GoldenBrusher")
    elseif data.daysNotBrushed == 0 and player:HasTrait("FoulBrusher") then
        traits:remove("FoulBrusher")
    end

    -- Calc new brush count influenced by the trait
    local newMax = moodle_manager.calc_max(sandboxVars, player)
    data.brushTeethNewMaxValue = newMax

    -- Reset moodle
    local moodle = moodle_factory.getMoodle("DirtyTeeth", player:getPlayerNum())
    moodle:setValue(0.5)

    -- Using trait logic to update mod data
    if data.todayBrushCount ~= 0 then
        if data.todayBrushCount >= newMax then
            data.daysBrushedToMax = data.daysBrushedToMax + 1
        end

        data.todayBrushCount = 0
    end

    -- Is the daily effect active?
    local doDailyEffect = sandboxVars.DoDailyEffect
    if data.daysNotBrushed <= 0 or doDailyEffect == false then
        return
    end

    local gracePeriod = sandboxVars.DailyEffectGracePeriod
    local unhappyRate = sandboxVars.DailyEffectExponent
    local stressRate = sandboxVars.DailyEffectAlternateExponent
    local unhappyMax = sandboxVars.DailyEffectMaxValue
    local stressMax = sandboxVars.DailyEffectAlternateMaxValue

    -- NOTE: For visualisation purposes, see https://www.desmos.com/calculator/awdp9rmxs8
    local unhappyFormula = math.min(
        math.max(
            math.exp(
                unhappyRate * (data.daysNotBrushed - gracePeriod) /
                (types.tonumber(data.daysNotBrushed >= (newMax / 2)) + 1)),
            0),
        unhappyMax)
    local stressFormula = math.min(
        math.max(
            math.exp(
                stressRate * (data.daysNotBrushed - gracePeriod) /
                (types.tonumber(data.daysNotBrushed >= (newMax / 2)) + 1)),
            0),
        stressMax)

    -- Set the daily effect using the formula above.
    local effectType = sandboxVars.DailyEffectType
    if effectType == 1 then
        bd:setUnhappynessLevel(bd:getUnhappynessLevel() + unhappyFormula)
    elseif effectType == 2 then
        bd:setUnhappynessLevel(bd:getUnhappynessLevel() + unhappyFormula)
        stats:setStress(stats:getStress() + stressFormula)
    elseif effectType == 3 then
        stats:setStress(stats:getStress() + stressFormula)
    else
        logger.error("Invalid DailyEffectType enum value")
    end
end

---@param deadPlayer IsoPlayer The player that died to trigger this event.
function events.player_death(deadPlayer)
    local player = getPlayer()

    -- Reset the mod data of the player if they died.
    if deadPlayer == player then
        player:getModData()[mod_constants.MOD_ID] = moddata_dummy_struct
    end
end

---@param playerNum number The player number of the newly-spawned character.
---@param player IsoPlayer The new player object.
function events.create_player(playerNum, player)
    -- Maybe do modData[AQConstants.MOD_ID] = AQPlayerModDataStructDummy?
    -- local modData = player:getModData()

    ---@type moddata_struct
    local data = player:getModData()[mod_constants.MOD_ID]

    ---@type sandboxvars_struct
    ---@diagnostic disable-next-line assign-type-mismatch
    local sandboxVars = SandboxVars[mod_constants.MOD_ID]

    -- Has user created a new character?
    -- Has the user enabled the mod on an existing character?
    local newChar = (data == nil or data._modVersion == nil)
    if newChar then
        player:getModData()[mod_constants.MOD_ID] = moddata_dummy_struct
        return
    end

    -- Outdated mod data check and merge
    -- This keeps the old data values and merges them with the new table
    if data._modVersion ~= mod_constants.MOD_VERSION then
        logger.warn("Mod data version mismatch." ..
            " Expected version=" .. mod_constants.MOD_VERSION ..
            " but got version=" .. data._modVersion ..
            "; Merging old mod data with dummy mod data.")

        local dummy = moddata_dummy_struct
        for k, v in pairs(dummy) do
            if k ~= "modVersion" and data[k] ~= nil then
                dummy[k] = data[k]
            end
        end

        player:getModData()[mod_constants.MOD_ID] = dummy
        return
    end

    -- Lazy nil data check
    -- This compares with the dummy struct for new data keys not in the table
    for k, v in pairs(moddata_dummy_struct) do
        if data[k] == nil then
            logger.info("Found nil value in mod data. Setting to default...")
            data[k] = v
        end
    end

    if data.brushTeethNewMaxValue == 0 then
        -- Do some mod data stuff for cases where
        local newMax = moodle_manager.calc_max(sandboxVars, player)
        data.brushTeethNewMaxValue = newMax
    end
end

---@param newGame boolean
function events.init_global_moddata(newGame)
    -- Remove the accidental addition to the global mod data that I did from 1.0.0 to 1.0.1.
    -- If you're curious, ask me. If you don't care, just know this is fixed.
    -- Clean up your previous mistakes instead of letting the result rot in people's world saves!!!!!
    if ModData.exists(mod_constants.MOD_ID) then
        logger.info("Found old global mod data. Removing...")
        ModData.remove(mod_constants.MOD_ID)
    end
end

function events.game_boot()
    tweaks.init()
    trait_manager.init()
    moodle_manager.init()
end

function events.register()
    logger.debug("Registering events...")

    Events.EveryTenMinutes.Add(events.every_ten_minutes)
    Events.EveryDays.Add(events.every_days)
    Events.OnFillWorldObjectContextMenu.Add(context_menu.create_menu)
    Events.OnPlayerDeath.Add(events.player_death)
    Events.OnCreatePlayer.Add(events.create_player)
    Events.OnInitGlobalModData.Add(events.init_global_moddata)
    Events.OnGameBoot.Add(events.game_boot)
end

return events
