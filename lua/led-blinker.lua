--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("tmr")
require("gpio")

local function init(cntx)
    local ledPin = (cntx and cntx.ledPin) or 4
    local callCnt = 0
    local onFlg = false
    local timer = tmr.create()
    local function onIntr()
        local f = callCnt % 4
        local v = ((f == 0) or (f == 2 and onFlg)) and gpio.HIGH or gpio.LOW
        gpio.write(ledPin, v)
        callCnt = callCnt + 1
        if callCnt == 4 then
            callCnt = 0
        end
    end
    gpio.mode(ledPin, gpio.OUTPUT)
    timer:register(250, tmr.ALARM_AUTO, onIntr)
    timer:start()
    return function(flg)
        assert(type(flg) == "boolea")
        onFlg = flg
    end
end

return init
