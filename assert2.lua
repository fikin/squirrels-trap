--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local blinkTimer = require("blink-timer")

local function assert2(boolCondition, errMsg, flg)
    if not boolCondition then
        print("[ERR] : " .. errMsg)
        blinkTimer:start(flg)
    end
end

return assert2
