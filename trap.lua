--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
App = {}
App.__index = App

App.new = function(irEmitterPin, latchPin)
    assert(irEmitterPin, "irEmitterPin not given")
    assert(latchPin, "latchPin not given")
    local o = {
        irEmitterPin = irEmitterPin,
        irThreshold = 10,
        latchPin = latchPin,
        latchTripped = 120,
        latchReady = 30,
        trapIsClosed = false,
        signalBits = {1, 1, 0, 1, 0, 1, 0, 1},
        servoOffTimer = tmr.create()
    }
    -- setmetatable(o, self)
    -- self.__index = self
    setmetatable(o, App)
    return o
end

function App:setServoTo(pos)
    assert(pos, "pos not given")
    pwm.setduty(self.latchPin, pos)
    pwm.start(self.latchPin)
    self.servoOffTimer:start()
end

function App:tripTheLatch()
    self:setServoTo(self.latchTripped)
    self.trapIsClosed = true
end

function App:readyTrap()
    pwm.setup(self.latchPin, 50, 0)
    gpio.mode(self.irEmitterPin, gpio.OUTPUT, gpio.PULLUP)
    self.servoOffTimer:register(
        500,
        tmr.ALARM_SEMI,
        function()
            pwm.setduty(self.latchPin, 0)
            pwm.stop(self.latchPin)
        end
    )
    self:setServoTo(self.latchReady)
    self.trapIsClosed = false
end

function App:irTransferBit(bit)
    local v1 = adc.read(0)
    gpio.write(self.irEmitterPin, bit == 1 and gpio.HIGH or gpio.LOW)
    local v2 = adc.read(0)
    gpio.write(self.irEmitterPin, gpio.LOW)
    local v3 = adc.read(0)
    local d1 = v1 - v2
    local d2 = v3 - v2
    print(
        "v1=" ..
            tostring(v1) ..
                " v2=" .. tostring(v2) .. " v3=" .. tostring(v3) .. " d1=" .. tostring(d1) .. " d2=" .. tostring(d2)
    )
    if bit == 1 then
        return d1 > self.irThreshold and d2 > self.irThreshold
    else
        return d1 <= self.irThreshold and d2 <= self.irThreshold
    end
end

function App:isBarrierBroken()
    local okCnt = 0
    for i = 1, #self.signalBits do
        if self:irTransferBit(self.signalBits[i]) then
            okCnt = okCnt + 1
        end
    end
    return okCnt ~= #self.signalBits
end

function App:closeTrapIfAnimalInside()
    if self:isBarrierBroken() then
        self:tripTheLatch()
    end
end

return App