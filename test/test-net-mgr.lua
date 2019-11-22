--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local tools = require("tools")
local nodemcu = require("nodemcu")
local n = require("net-mgr")
local blinkTimer = require("blink-timer")

function testServer()
    nodemcu.reset()

    local cntx = {
        port = 8080
    }
    n.startSrv(
        cntx,
        function()
            return "open"
        end
    )
    lu.assertEquals(n.state, "listening")

    nodemcu.advanceTime(10)
    local con = net.createConnection(net.TCP, false)
    local w = tools.wrapConnection(con)
    con:connect(8080, nodemcu.net_ip_get())

    nodemcu.advanceTime(10)
    con:send("GET /state HTTP1.0\n\n")

    nodemcu.advanceTime(10)
    lu.assertEquals(w.sent, 1)
    lu.assertEquals(
        w.received,
        {
            [[HTTP/1.1 200 OK
Content-Type: application/json

{"trapState":"open"}]]
        }
    )
    lu.assertEquals(w.connection, 1)
    lu.assertEquals(w.disconnection, 1)
    lu.assertEquals(w.reconnection, 0)
end

os.exit(lu.run())
