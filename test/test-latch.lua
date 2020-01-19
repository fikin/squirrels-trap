--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local nodemcu = require("nodemcu")
local l = require("latch")

function testLatchInit()
    nodemcu.reset()

    local cntx = {latchPin = 6}

    local tripLatchFnc = l(cntx)
    lu.assertNotNil(l)
    nodemcu.advanceTime(1200)

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

function testTripTheLatch()
    nodemcu.reset()

    local cntx = {latchPin = 6}

    local tripLatchFnc = l(cntx)
    lu.assertNotNil(l)
    nodemcu.advanceTime(1200)
    lu.assertNotNil(nodemcu.pwm_get_history())

    tripLatchFnc()
    lu.assertEquals(
        nodemcu.pwm_get_history(),
        {
            {duty = 120, event = "setduty", pin = cntx.latchPin},
            {event = "start", pin = cntx.latchPin}
        }
    )

    nodemcu.advanceTime(600)
    lu.assertEquals(
        nodemcu.pwm_get_history(),
        {
            {duty = 0, event = "setduty", pin = cntx.latchPin},
            {event = "stop", pin = cntx.latchPin}
        }
    )
end

os.exit(lu.run())
