--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local blinkTimer = require("blink-timer")
local wifiMgr = require("wifi-mgr")

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

local function startServer(cntx, getTrapStateFnc)
    local srv = net.createServer(net.TCP, 30)
    assert2(srv, "failed to create TCP server", 4)
    sv:listen(
        cntx.port,
        function(conn)
            sck:on(
                "sent",
                function(skt)
                    skt:close()
                end
            )
            conn:send('HTTP/1.1 200 OK\nContent-Type: application/json\n\n{"trapState":"' .. getTrapStateFnc() .. '"}')
        end
    )
end

local function main()
    spawn(wifiMgr.startWifi, envCntx.wifi)
    local trapApp = require("trap")(envCntx)
    spawn(startServer, envCntx.server, trapApp.getTrapState)
    trap.resetLatchPosition()
    spawn(trap.mainLoop)
end
