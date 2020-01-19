--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("net")
require("tmr")
require("sjson")

local function startSrv(cntx)
    assert(cntx)
    assert(type(cntx.port) == "number")
    assert(type(cntx.getState) == "function")

    local isOk = false
    local function isOkCb(flg)
        isOk = flg
    end

    cntx.log = cntx.log or function(txt)
            print(txt)
        end
    assert(type(cntx.log) == "function")

    local function _log(lvl, msg)
        cntx.log(string.format("%s %s %s", tostring(tmr.now()), lvl, msg))
    end
    local function info(msg)
        _log("[INFO] ", msg)
    end
    local function err(msg)
        _log("[ERR] ", msg)
    end

    local function onNewConnection(con)
        info(string.format("new http connection from-to %s-%s", con:getpeer(), con:getaddr()))
        local encoder = sjson.encoder(cntx.getState())
        local function sendObj(con2)
            local str = encoder:read(512)
            if str then
                con2:send(str)
            else
                con2:close()
            end
        end
        con:on(
            "connection",
            function()
                con:on("sent", sendObj)
                con:send("HTTP/1.0 200 OK\nContent-Type: application/json\n\n")
            end
        )
    end

    local function main()
        info("starting http server ...")
        local srv = net.createServer(net.TCP, 30)
        if srv == nil then
            err("failed to create TCP server")
        else
            srv:listen(cntx.port, onNewConnection)
            info("http server listens on port " .. tostring(cntx.port) .. "...")
            isOkCb(true)
        end
    end

    main()
    return function()
        return isOk
    end
end

return startSrv
