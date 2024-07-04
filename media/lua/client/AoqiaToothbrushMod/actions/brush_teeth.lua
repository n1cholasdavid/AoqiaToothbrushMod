-- -------------------------------------------------------------------------- --
--            A timed action for brushing teeth using a toothbrush.           --
-- -------------------------------------------------------------------------- --

require("TimedActions/ISBaseTimedAction")
local ISBaseTimedAction = ISBaseTimedAction
local ISTakeWaterAction = ISTakeWaterAction
local SandboxVars = SandboxVars

require("MF_ISMoodle")
local MoodleFactory    = MF

local mod_constants    = require("AoqiaToothbrushMod/mod_constants")
local moodle_manager   = require("AoqiaToothbrushMod/moodle_manager")

local logger           = mod_constants.LOGGER

-- ------------------------------ Module Start ------------------------------ --

local brush_teeth      = ISBaseTimedAction:derive("brush_teeth")

---@type IsoPlayer
brush_teeth.character  = nil
---@type IsoObject
brush_teeth.sink       = nil
---@type ComboItem
brush_teeth.toothbrush = nil
---@type number
brush_teeth.time       = nil

function brush_teeth:isValid()
    return self.sink:getObjectIndex() ~= -1 and self.character:getInventory():containsTagRecurse("Toothbrush")
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

function brush_teeth:update()
    self.character:faceThisObjectAlt(self.sink)
    ---@diagnostic disable-next-line: param-type-mismatch
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function brush_teeth:waitToStart()
    -- Alt version makes character walk there I believe.
    self.character:faceThisObjectAlt(self.sink)
    return self.character:shouldBeTurning()
end

function brush_teeth:start()
    self:setActionAnim("BrushTeeth")
    self:setOverrideHandModels("Base.Toothbrush", nil)
    self.sound = self.character:playSound("BrushTeeth")
end

function brush_teeth:stopSound()
    ---@diagnostic disable-next-line: param-type-mismatch
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function brush_teeth:stop()
    self:stopSound()
    ISBaseTimedAction.stop(self)
end

function brush_teeth:perform()
    self:stopSound()
    -- TODO: Uncomment this when toothpaste drainable item is handled.
    -- self.toothpastes[0]:Use()
    ISTakeWaterAction.SendTakeWaterCommand(self.character, self.sink, 1)

    ---@type moddata_struct
    local data = self.character:getModData()[mod_constants.MOD_ID]

    -- Brush teeth mod data update
    data.todayBrushCount = data.todayBrushCount + 1
    data.totalBrushCount = data.totalBrushCount + 1
    data.daysNotBrushed = 0
    data.timeLastBrushTenMins = 0

    ---@type sandboxvars_struct
    ---@diagnostic disable-next-line: assign-type-mismatch
    local sandboxVars = SandboxVars[mod_constants.MOD_ID]

    local newMax = moodle_manager.calc_max(sandboxVars, self.character)
    data.brushTeethNewMaxValue = newMax

    -- Update moodle
    local moodle = MoodleFactory.getMoodle("DirtyTeeth", self.character:getPlayerNum())
    moodle:setValue(math.min(math.max(data.todayBrushCount, 0), newMax) / newMax)

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
            logger.error("Invalid BrushTeethEffectType enum value")
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
---@param toothbrush InventoryItem
---@param toothpaste InventoryItem|nil
---@param time number
function brush_teeth:new(character, sink, toothbrush, toothpaste, time)
    local o = {}

    setmetatable(o, self)
    self.__index       = self
    o.character        = character
    o.sink             = sink
    o.toothbrush       = toothbrush
    o.toothpaste       = toothpaste
    o.stopOnWalk       = true
    o.stopOnRun        = true
    o.forceProgressBar = true
    o.maxTime          = time

    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o
end

return brush_teeth
