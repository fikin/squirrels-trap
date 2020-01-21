--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("pwm")
require("gpio")

local function init(cntx)
    assert(cntx)
    assert(cntx.irEmitterPin, "irEmitterPin not given")
    local irThreshold = cntx.irThreshold or 100
    local signalBits = cntx.signalBits or {1, 1}

    local function getBitsList()
        local i = 0
        return function()
            i = i + 1
            if i <= #signalBits then
                return signalBits[i]
            end
        end
    end

    gpio.mode(cntx.irEmitterPin, gpio.OUTPUT, gpio.PULLUP)

    local function irTransferBit(bit)
        local v1 = adc.read(0)
        gpio.write(cntx.irEmitterPin, bit == 1 and gpio.HIGH or gpio.LOW)
        tmr.delay(2000)
        local v2 = adc.read(0)
        gpio.write(cntx.irEmitterPin, gpio.LOW)
        tmr.delay(2000)
        local v3 = adc.read(0)
        local d1 = math.abs(v1 - v2)
        local d2 = math.abs(v3 - v2)
        if bit == 1 then
            return d1 > irThreshold and d2 > irThreshold
        else
            return d1 <= irThreshold and d2 <= irThreshold
        end
    end

    local function isBarrierBroken()
        for i in getBitsList() do
            if not irTransferBit(i) then
                return true
            end
        end
        return false
    end

    return isBarrierBroken
end

return init
