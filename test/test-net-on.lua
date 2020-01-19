--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local tools = require("tools")
local nodemcu = require("nodemcu")
local netOn = require("net-on")

function testServer()
    nodemcu.reset()

    local cntx = {
        port = 8080,
        getState = function()
            return {trapState = "open"}
        end
    }
    local isOkFnc = netOn(cntx)
    lu.assertTrue(isOkFnc())

    nodemcu.advanceTime(10)
    lu.assertTrue(isOkFnc())
    local con = net.createConnection(net.TCP, false)
    local w = tools.wrapConnection(con)
    con:connect(8080, nodemcu.net_ip_get())

    nodemcu.advanceTime(10)
    -- con:send("GET /state HTTP1.0\n\n")

    nodemcu.advanceTime(10)
    lu.assertEquals(w.sent, 0)
    lu.assertEquals(
        table.concat(w.received, ""),
        [[HTTP/1.0 200 OK
Content-Type: application/json

{"trapState":"open"}]]
    )
    lu.assertEquals(w.connection, 1)
    lu.assertEquals(w.disconnection, 1)
    lu.assertEquals(w.reconnection, 0)
end

os.exit(lu.run())
