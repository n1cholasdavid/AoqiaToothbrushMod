-- -------------------------------------------------------------------------- --
--            A timed action for brushing teeth using a toothbrush.           --
-- -------------------------------------------------------------------------- --

require("TimedActions/ISBaseTimedAction")
local ISBaseTimedAction = ISBaseTimedAction

local AQConstants = require("AQConstants")
local AQModData = require("AQModData")
local AQUtils = require("AQUtils")

-- ------------------------------ Module Start ------------------------------ --

local AQBrushTeeth = ISBaseTimedAction:derive("AQBrushTeeth")

function AQBrushTeeth:isValid()
    return true
end

function AQBrushTeeth:update()
    self.character:faceThisObjectAlt(self.sink)
    self.character:setMetabolicTarget(Metabolics.LightDomestic)
end

function AQBrushTeeth:waitToStart()
    return false
end

function AQBrushTeeth:start()
    self:setActionAnim("WashFace")
    self:setOverrideHandModels(nil, nil)
    self.sound = self.character:playSound("WashYourself")
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
    self.character:resetModelNextFrame()
    sendVisual(self.character)
    ISTakeWaterAction.SendTakeWaterCommand(self.character, self.sink, 1)

    -- Update player mod data

    ---@type AQModDataStruct
    local data = ModData.get(AQConstants.MOD_ID)
    data.daysWithoutBrushingTeeth = 0
    data.timesBrushedTeethToday = data.timesBrushedTeethToday + 1

    if data.timesBrushedTeethToday <= 2 then
        -- Decrease the unhappy
        local bodyDamage = self.character:getBodyDamage()
        bodyDamage:setUnhappynessLevel(AQUtils.clamp(bodyDamage:getUnhappynessLevel() - 10, 0, 100))
    end

    ISBaseTimedAction.perform(self)
end

function AQBrushTeeth.getRequiredToothpaste()
    -- NOTE: Maybe have the toothpaste amount be dynamic based on how dirty your teeth are?
    return 1
end

---@param toothpastes table<number, ComboItem>
function AQBrushTeeth.getToothpasteRemaining(toothpastes)
    local total = 0

    for _, toothpaste in ipairs(toothpastes) do
        total = total + toothpaste:getUses()
    end

    return total
end

function AQBrushTeeth.getRequiredWater()
    -- NOTE: See getRequiredToothpaste()
    return 1
end

---@param character IsoPlayer
function AQBrushTeeth:new(character, sink, toothpastes)
    local o = {}

    setmetatable(o, self)
    self.__index       = self
    o.character        = character
    o.sink             = sink
    o.toothpastes      = toothpastes
    o.stopOnWalk       = true
    o.stopOnRun        = true
    o.forceProgressBar = true
    o.maxTime          = 600

    if AQBrushTeeth.getRequiredToothpaste() > AQBrushTeeth.getToothpasteRemaining(toothpastes) then
        o.maxTime = o.maxTime * 2
    end

    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end

    return o
end

return AQBrushTeeth
