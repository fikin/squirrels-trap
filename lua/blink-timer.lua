--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local nodemcu = require("nodemcu")

local blinkTimer =
    (function()
    local o = {
        tickets = 0,
        timer1 = tmr.create(),
        flg = 0
    }
    gpio.mode(4, gpio.OUTPUT)
    o.timer1:register(
        1000,
        tmr.ALARM_AUTO,
        function()
            gpio.write(4, o.flg)
            o.flg = 1 - o.flg
        end
    )
    return o
end)()

blinkTimer.start = function(self, flg)
    self.tickets = bit.bor(self.tickets, flg)
    if self.tickets == 1 then
        self.timer1:start()
    end
end

blinkTimer.stop = function(self, flg)
    if self.tickets > 0 then
        self.tickets = bit.bxor(self.tickets, flg)
        if self.tickets == 0 then
            self.timer1:stop()
        end
    end
end

return blinkTimer
