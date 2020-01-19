--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local tools = require("tools")
local nodemcu = require("nodemcu")
local ledb = require("led-blinker")

function testRightAfterDefaultInit()
    nodemcu.reset()

    local onOffFnc = ledb({})

    lu.assertEquals(nodemcu.gpio_get_mode(4), gpio.OUTPUT)
end

function testAssignLedPin()
    nodemcu.reset()

    local onOffFnc = ledb({ledPin = 3})

    lu.assertEquals(nodemcu.gpio_get_mode(3), gpio.OUTPUT)
    lu.assertEquals(nodemcu.gpio_get_mode(4), gpio.OPENDRAIN)
end

function testDefaultBlink()
    nodemcu.reset()

    local arr = tools.collectDataToArray()
    nodemcu.gpio_capture(4, arr.putCb)

    local onOffFnc = ledb({})

    nodemcu.advanceTime(1251)

    lu.assertEquals(arr.get(), { {4, 1}, {4, 0}, {4, 0}, {4, 0}, {4, 1} })
end

-- local function newCapture()
--     local arr = tools.collectDataToArray()
--     nodemcu.gpio_capture(4, arr.putCb)
--     return arr
-- end

-- function testInitial()
--     lu.assertEquals(nodemcu.gpio_get_mode(4), gpio.OUTPUT)
--     local arr = newCapture()
--     nodemcu.advanceTime(15)
--     lu.assertEquals(arr.get(), {})
-- end

-- function testStartStopSequence()
--     local arr = newCapture()
--     b:start(1)
--     nodemcu.advanceTime(2200)
--     lu.assertEquals(arr.get(), {{4, 0}, {4, 1}})
--     local arr = newCapture()
--     b:stop(1)
--     nodemcu.advanceTime(2200)
--     lu.assertEquals(arr.get(), {})
-- end

-- function testDifferentFlags()
--     local arr = newCapture()
--     b:start(1)
--     b:start(1)
--     b:start(4)
--     b:start(4)
--     nodemcu.advanceTime(2200)
--     lu.assertEquals(arr.get(), {{4, 0}, {4, 1}})
--     local arr = newCapture()
--     b:stop(1)
--     nodemcu.advanceTime(2200)
--     lu.assertEquals(arr.get(), {{4, 0}, {4, 1}})
--     local arr = newCapture()
--     b:stop(4)
--     nodemcu.advanceTime(2200)
--     lu.assertEquals(arr.get(), {})
-- end

os.exit(lu.run())
