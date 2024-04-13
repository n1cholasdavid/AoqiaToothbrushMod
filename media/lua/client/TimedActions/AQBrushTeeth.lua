-- -------------------------------------------------------------------------- --
--            A timed action for brushing teeth using a toothbrush.           --
-- -------------------------------------------------------------------------- --

require("TimedActions/ISBaseTimedAction")
local ISBaseTimedAction = ISBaseTimedAction
local ISTakeWaterAction = ISTakeWaterAction
local SandboxVars = SandboxVars

local AQConstants = require("AQConstants")
local AQUtils = require("AQUtils")

-- ------------------------------ Module Start ------------------------------ --

local AQBrushTeeth = ISBaseTimedAction:derive("AQBrushTeeth")

---@type IsoPlayer
AQBrushTeeth.character = nil
---@type IsoObject
AQBrushTeeth.sink = nil
---@type ComboItem
AQBrushTeeth.toothbrush = nil
---@type number
AQBrushTeeth.time = nil

function AQBrushTeeth:isValid()
    return self.sink:getObjectIndex() ~= -1 and self.character:getInventory():containsTypeRecurse("Toothbrush")
end

-- ---@param event AnimEvent
-- ---@param parameter any
-- function AQBrushTeeth:animEvent(event, parameter)
--     if event == "BrushTeethSwitch" then
--         AQUtils.logdebug("switch event played")
--         self:setActionAnim("BrushTeeth02")

--         if self.sound then
--             self.character:playSound("BrushTeeth02")
--         end
--     elseif event == "BrushTeethSwitch2" then
--         AQUtils.logdebug("switch event 2 played")
--         self:setActionAnim("BrushTeeth")

--         if self.sound then
--             self.character:playSound("BrushTeeth")
--         end
--     end
-- end

function AQBrushTeeth:update()
    self.character:faceThisObjectAlt(self.sink)
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function AQBrushTeeth:waitToStart()
    -- Alt version makes character walk there I believe.
    self.character:faceThisObjectAlt(self.sink)
    return self.character:shouldBeTurning()
end

function AQBrushTeeth:start()
    self:setActionAnim("BrushTeeth")
    self:setOverrideHandModels("Base.Toothbrush", nil)
    self.sound = self.character:playSound("BrushTeeth")
end

function AQBrushTeeth:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function AQBrushTeeth:stop()
    self:stopSound()
    ISBaseTimedAction.stop(self)
end

function AQBrushTeeth:perform()
    self:stopSound()
    -- TODO: Uncomment this when toothpaste drainable item is handled.
    -- self.toothpastes[0]:Use()
    ISTakeWaterAction.SendTakeWaterCommand(self.character, self.sink, 1)

    ---@type AQPlayerModDataStruct
    local data = self.character:getModData()[AQConstants.MOD_ID]

    -- Brush teeth mod data update
    data.statTeethDirt = 0
    data.todayBrushCount = data.todayBrushCount + 1
    data.totalBrushCount = data.totalBrushCount + 1
    data.totalDaysNotBrushed = 0

    ---@type AQSandboxVarsStruct
    local sandboxVars = SandboxVars[AQConstants.MOD_ID]

    -- newMax is maxValue influenced by current trait
    local newMax = sandboxVars.BrushTeethMaxValue
    if self.character:HasTrait("GoldenBrusher") then
        newMax = newMax / 2
    elseif self.character:HasTrait("FoulBrusher") then
        newMax = newMax * 2
    end

    -- Brush Teeth Effect
    if sandboxVars.DoBrushTeethEffect and data.todayBrushCount <= newMax then
        ---@type number
        local effectType = SandboxVars[AQConstants.MOD_ID].BrushTeethEffectType
        ---@type number
        local unhappyAmount = SandboxVars[AQConstants.MOD_ID].BrushTeethEffectAmount
        ---@type number
        local stressAmount = SandboxVars[AQConstants.MOD_ID].BrushTeethEffectAlternateAmount

        ---@type Stats
        local stats = self.character:getStats()
        ---@type BodyDamage
        local bd = self.character:getBodyDamage()
        local unhappiness = bd:getUnhappynessLevel()
        local stress = stats:getStress()

        if effectType == 1 then
            bd:setUnhappynessLevel(unhappiness - unhappyAmount)
        elseif effectType == 2 then
            bd:setUnhappynessLevel(unhappiness - unhappyAmount)
            stats:setStress(stress - stressAmount)
        elseif effectType == 3 then
            stats:setStress(stress - stressAmount)
        else
            AQUtils.logerror("Invalid BrushTeethEffectType enum value")
        end
    end

    ISBaseTimedAction.perform(self)
end

function AQBrushTeeth.getRequiredToothpaste()
    -- NOTE: Maybe have the toothpaste amount be dynamic based on how dirty your teeth are?
    local requiredToothpaste = SandboxVars[AQConstants.MOD_ID].BrushTeethRequiredToothpaste
    if requiredToothpaste == nil then
        return 1
    end

    return requiredToothpaste
end

-- ---@param toothpastes table<number, ComboItem>
-- function AQBrushTeeth.getToothpasteRemaining(toothpastes)
--     local total = 0

--     for _, toothpaste in ipairs(toothpastes) do
--         total = total + toothpaste:getUses()
--     end

--     return total
-- end

---@return number
function AQBrushTeeth.getRequiredWater()
    local requiredWater = SandboxVars[AQConstants.MOD_ID].BrushTeethRequiredWater
    if requiredWater == nil then
        return 1
    end

    return requiredWater
end

---@param character IsoPlayer
---@param sink IsoObject
---@param toothbrush ComboItem
---@param time number
function AQBrushTeeth:new(character, sink, toothbrush, toothpastes, time)
    local o = {}

    setmetatable(o, self)
    self.__index       = self
    o.character        = character
    o.sink             = sink
    o.toothbrush       = toothbrush
    o.toothpastes      = toothpastes
    o.stopOnWalk       = true
    o.stopOnRun        = true
    o.forceProgressBar = true
    o.maxTime          = time

    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o
end

return AQBrushTeeth
