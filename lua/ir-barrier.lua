--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("pwm")
require("gpio")

local function init(cntx)
    assert(cntx)
    assert(cntx.irEmitterPin, "irEmitterPin not given")
    local irThreshold = cntx.irThreshold or 10
    local signalBits = cntx.signalBits or {1, 1, 0, 1, 0, 1, 0, 1}

    gpio.mode(cntx.irEmitterPin, gpio.OUTPUT, gpio.PULLUP)

    local function irTransferBit(bit)
        local v1 = adc.read(0)
        gpio.write(cntx.irEmitterPin, bit == 1 and gpio.HIGH or gpio.LOW)
        local v2 = adc.read(0)
        gpio.write(cntx.irEmitterPin, gpio.LOW)
        local v3 = adc.read(0)
        local d1 = math.abs(v1 - v2)
        local d2 = math.abs(v3 - v2)
        -- print(
        --     "v1=" ..
        --         tostring(v1) ..
        --             " v2=" .. tostring(v2) .. " v3=" .. tostring(v3) .. " d1=" .. tostring(d1) .. " d2=" .. tostring(d2)
        -- )
        if bit == 1 then
            return d1 > irThreshold and d2 > irThreshold
        else
            return d1 <= irThreshold and d2 <= irThreshold
        end
    end

    local function isBarrierBroken()
        local okCnt = 0
        for i = 1, #signalBits do
            if irTransferBit(signalBits[i]) then
                okCnt = okCnt + 1
            end
        end
        return okCnt ~= #signalBits
    end

    return isBarrierBroken
end

return init
