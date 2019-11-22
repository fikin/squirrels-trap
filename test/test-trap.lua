--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local tools = require("tools")
local nodemcu = require("nodemcu")
local trap = require("trap")

function testGettingReady()
    nodemcu.reset()

    local cntx = {
        irEmitterPin = 5,
        latchPin = 6
    }

    local emmiterData = tools.collectDataToArray()
    nodemcu.gpio_capture(cntx.irEmitterPin, emmiterData.putCb)

    local t = trap.new(cntx)

    t:readyTrap()
    nodemcu.advanceTime(1200)

    lu.assertEquals(nodemcu.gpio_get_mode(cntx.irEmitterPin), gpio.OUTPUT)
    lu.assertEquals(
        nodemcu.pwm_get_history(),
        {
            {event = "setup", pin = cntx.latchPin, duty = 0, clock = 50},
            {duty = 120, event = "setduty", pin = cntx.latchPin},
            {event = "start", pin = cntx.latchPin},
            {duty = 0, event = "setduty", pin = cntx.latchPin},
            {event = "stop", pin = cntx.latchPin},
            {duty = 30, event = "setduty", pin = cntx.latchPin},
            {event = "start", pin = cntx.latchPin},
            {duty = 0, event = "setduty", pin = cntx.latchPin},
            {event = "stop", pin = cntx.latchPin}
        }
    )
end

os.exit(lu.run())
