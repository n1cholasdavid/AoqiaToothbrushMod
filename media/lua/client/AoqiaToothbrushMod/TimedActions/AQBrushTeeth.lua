-- -------------------------------------------------------------------------- --
--            A timed action for brushing teeth using a toothbrush.           --
-- -------------------------------------------------------------------------- --

local math = math

require("TimedActions/ISBaseTimedAction")
local ISBaseTimedAction = ISBaseTimedAction
local ISTakeWaterAction = ISTakeWaterAction
local SandboxVars = SandboxVars

require("MF_ISMoodle")
local MoodleFactory     = MF

local AQConstants       = require("AoqiaToothbrushMod/AQConstants")
local AQLog             = require("AoqiaToothbrushMod/AQLog")
local AQMath            = require("AoqiaToothbrushMod/AQMath")
local AQMoodles         = require("AoqiaToothbrushMod/AQMoodles")

-- ------------------------------ Module Start ------------------------------ --

local AQBrushTeeth      = ISBaseTimedAction:derive("AQBrushTeeth")

---@type IsoPlayer
AQBrushTeeth.character  = nil
---@type IsoObject
AQBrushTeeth.sink       = nil
---@type ComboItem
AQBrushTeeth.toothbrush = nil
---@type number
AQBrushTeeth.time       = nil

function AQBrushTeeth:isValid()
    return self.sink:getObjectIndex() ~= -1 and self.character:getInventory():containsTypeRecurse("Toothbrush")
end

-- ---@param event AnimEvent
-- ---@param parameter any
-- function AQBrushTeeth:animEvent(event, parameter)
--     if event == "BrushTeethSwitch" then
--         AQLog.debug("switch event played")
--         self:setActionAnim("BrushTeeth02")

--         if self.sound then
--             self.character:playSound("BrushTeeth02")
--         end
--     elseif event == "BrushTeethSwitch2" then
--         AQLog.debug("switch event 2 played")
--         self:setActionAnim("BrushTeeth")

--         if self.sound then
--             self.character:playSound("BrushTeeth")
--         end
--     end
-- end

function AQBrushTeeth:update()
    self.character:faceThisObjectAlt(self.sink)
    ---@diagnostic disable-next-line: param-type-mismatch
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
    ---@diagnostic disable-next-line: param-type-mismatch
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
    data.todayBrushCount = data.todayBrushCount + 1
    data.totalBrushCount = data.totalBrushCount + 1
    data.daysNotBrushed = 0
    data.timeLastBrushTenMins = 0

    ---@type AQSandboxVarsStruct
    ---@diagnostic disable-next-line: assign-type-mismatch
    local sandboxVars = SandboxVars[AQConstants.MOD_ID]

    local newMax = AQMoodles.calcMaxValue(sandboxVars, self.character)
    data.brushTeethNewMaxValue = newMax

    -- Update moodle
    local moodle = MoodleFactory.getMoodle("DirtyTeeth", self.character:getPlayerNum())
    moodle:setValue(AQMath.clamp(data.todayBrushCount, 0, newMax) / newMax)

    -- Brush Teeth Effect
    if sandboxVars.DoBrushTeethEffect and data.todayBrushCount <= newMax then
        local effectType = sandboxVars.BrushTeethEffectType
        local unhappyAmount = sandboxVars.BrushTeethEffectAmount
        local stressAmount = sandboxVars.BrushTeethEffectAlternateAmount

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
            AQLog.error("Invalid BrushTeethEffectType enum value")
        end
    end

    ISBaseTimedAction.perform(self)
end

-- ---@param toothpastes table<number, ComboItem>
-- function AQBrushTeeth.getToothpasteRemaining(toothpastes)
--     local total = 0

--     for _, toothpaste in ipairs(toothpastes) do
--         total = total + toothpaste:getUses()
--     end

--     return total
-- end

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
