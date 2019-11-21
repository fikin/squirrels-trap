--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local blinkTimer = require("blink-timer")

local blinkFlag = 4

local NetMgr = {
    state = "none"
}
NetMgr.__index = NetMgr

NetMgr.on_sent = function(con)
    con:close()
end

NetMgr.on_connection = function(con)
    con:on("sent", NetMgr.on_sent)
    con:on(
        "receive",
        function(con2)
            con2:send(
                'HTTP/1.1 200 OK\nContent-Type: application/json\n\n{"trapState":"' ..
                    NetMgr.get_trap_state_fnc() .. '"}'
            )
        end
    )
end

NetMgr.startSrv = function(cntx)
    NetMgr.state = "initializing"
    local srv = net.createServer(net.TCP, 30)
    if srv == nil then
        print("[ERR] : failed to create TCP server")
        blinkTimer:start(blinkTimer)
    end
    assert(cntx.port, "cntx.port must be provided")
    assert(cntx.get_trap_state_fnc, "cntx.get_trap_state_fnc must be provided")
    NetMgr.get_trap_state_fnc = cntx.get_trap_state_fnc
    srv:listen(cntx.port, NetMgr.on_connection)
    NetMgr.state = "listening"
end

return NetMgr
