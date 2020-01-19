--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local tools = require("tools")
local nodemcu = require("nodemcu")
local b = require("ir-barrier")

local inspect = require("inspect")

function testInit()
    nodemcu.reset()

    local cntx = {irEmitterPin = 5}

    nodemcu.adc_read_cb = function()
        lu.fail("should not have been called")
    end
    local emmiterData = tools.collectDataToArray()
    nodemcu.gpio_capture(cntx.irEmitterPin, emmiterData.putCb)

    local isBrokenFnc = b(cntx)
    nodemcu.advanceTime(1200)

    lu.assertEquals(nodemcu.gpio_get_mode(cntx.irEmitterPin), gpio.OUTPUT)
    lu.assertEquals(emmiterData.get(), {})
end

function testBarrierIsOk()
    nodemcu.reset()

    local cntx = {irEmitterPin = 5}

    local emmiterData = tools.collectDataToArray()
    nodemcu.gpio_capture(cntx.irEmitterPin, emmiterData.putCb)
    nodemcu.adc_read_cb = function()
        local aa = emmiterData.get()
        local function isBitOn()
            if aa[1] then
                lu.assertEquals(aa[1][1], cntx.irEmitterPin)
                if aa[1][2] == 1 then
                    return true
                end
            end
            return false
        end
        return isBitOn() and math.random(630, 639) or math.random(610, 619)
    end

    local isBrokenFnc = b(cntx)
    nodemcu.advanceTime(1200)

    lu.assertFalse(isBrokenFnc())
end

function testBarrierIsBroken()
    nodemcu.reset()

    local cntx = {irEmitterPin = 5}

    nodemcu.adc_read_cb = function()
        return math.random(610, 639)
    end

    local isBrokenFnc = b(cntx)
    nodemcu.advanceTime(1200)

    lu.assertTrue(isBrokenFnc())
end

os.exit(lu.run())
