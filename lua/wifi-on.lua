--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("wifi")
require("tmr")

local function startWifi(cntx)
    assert(cntx)
    assert(type(cntx.ssid) == "string")
    assert(type(cntx.pswd) == "string")
    assert(type(cntx.hostname) == "string")

    local isOk = false
    local function isOkCb(flg)
        isOk = flg
    end

    cntx.log = cntx.log or function(txt)
            print(txt)
        end
    assert(type(cntx.log) == "function")

    local retryTimer = tmr.create()

    local function _log(lvl, msg)
        cntx.log(string.format("%s %s %s", tostring(tmr.now()), lvl, msg))
    end
    local function info(msg)
        _log("[INFO] ", msg)
    end
    local function warn(msg)
        _log("[WARN] ", msg)
    end

    local function retryFnc(errMsg)
        warn(errMsg)
        isOkCb(false)
        retryTimer:start()
    end

    local function tryConnecting()
        local function connected_cb(T)
            assert(T, "connected_cb(T) -> T is nil")
            info("connected successfully to " .. T.SSID)
        end
        local function disconnected_cb(T)
            assert(T, "disconnected_cb(T) -> T is nil")
            retryFnc("wifi disconnected from " .. T.SSID .. " due to " .. T.reason)
        end
        local function authmode_change_cb(old_auth_mode, new_auth_mode)
            assert(T, "authmode_change_cb(old_auth_mode,new_auth_mode) -> old_auth_mode is nil")
            assert(T, "authmode_change_cb(old_auth_mode,new_auth_mode) -> new_auth_mode is nil")
            retryFnc("wifi authmode changed from " .. old_auth_mode .. " to " .. new_auth_mode)
        end
        local function got_ip_cb(T)
            assert(T, "got_ip_cb(T) -> T is nil")
            info("got IP " .. T.IP)
            isOkCb(true)
        end
        local function dhcp_timeout_cb(...)
            retryFnc("dhcp timeout")
        end

        info("configuring " .. cntx.ssid .. " ..")
        local connectCfg = {
            ssid = cntx.ssid,
            pwd = cntx.pswd,
            save = false,
            auto = true,
            connected_cb = connected_cb,
            disconnected_cb = disconnected_cb,
            authmode_change_cb = authmode_change_cb,
            got_ip_cb = got_ip_cb,
            dhcp_timeout_cb = dhcp_timeout_cb
        }
        if not wifi.sta.config(connectCfg) then
            retryFnc("Failed to configure wifi")
        end
    end

    local function tblHasEntries(tbl)
        for _ in pairs(tbl) do
            return true
        end
        return false
    end

    local function onSSIDScan(tbl)
        if tblHasEntries(tbl) then
            tryConnecting()
        else
            retryFnc("wifi hotspot not found : " .. cntx.ssid)
        end
    end

    local function tryFnc()
        info("looking for ssid " .. cntx.ssid .. " ...")
        wifi.sta.getap({ssid = cntx.ssid}, 1, onSSIDScan)
    end

    local function main()
        info("starting wifi ...")
        wifi.setmode(wifi.STATION)
        wifi.sta.sethostname(cntx.hostname)
        retryTimer:register(5000, tmr.ALARM_SEMI, tryFnc)
        retryTimer:start()
    end

    main()
    return function()
        return isOk
    end
end

return startWifi
