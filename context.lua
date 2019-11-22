--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local blinkTimer = require("blink-timer")
local wifiMgr = require("wifi-mgr")
local netMgr = require("net-mgr")
local trap = require("trap")

local envCntx = {
    wifi = {
        ssid = "FRHOC2",
        pswd = "aa",
        hostname = "trap1"
    },
    server = {
        port = 8080
    },
    trap = {
        latchReleaseServoPin = 1,
        irBarrierEmitterPin = 2
    }
}

local function spawn(fnc, ...)
    local vargs = table.pack(...)
    local t = tmr.create()
    t:register(
        1,
        tmr.ALARM_SINGLE,
        function(t)
            fnc(table.unpack(vargs))
        end
    )
    t:start()
end

local function assert2(boolCondition, errMsg, flg)
    if not boolCondition then
        print("[ERR] : " .. errMsg)
        blinkTimer:start(flg)
    end
end

local function main()
    spawn(wifiMgr.startWifi, envCntx.wifi)
    local trapApp = trap.new(envCntx.trap)
    spawn(netMgr.startSrv, envCntx.server, trapApp.getTrapState)
    trap.resetLatchPosition()
    spawn(trap.mainLoop)
end
