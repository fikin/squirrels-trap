--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("wifi")
local blinkTimer = require("blink-timer")

local WifiMgr = {
    blinkFlg = 2,
    state = "none",
    retryTimer = tmr.create()
}
WifiMgr.__index = WifiMgr

WifiMgr.retryFnc = function(errMsg)
    WifiMgr.state = "toberetrying"
    blinkTimer:start(WifiMgr.blinkFlg)
    print("[WARN] : " .. errMsg)
    WifiMgr.retryTimer:start()
end

WifiMgr.connected_cb = function(T)
    WifiMgr.state = "connected"
    assert(T, "wifi.connected_cb T is nil")
    print("[INFO] : wifi connected successfully to " .. T.SSID)
end
WifiMgr.disconnected_cb = function(T)
    assert(T, "wifi.disconnected_cb T is nil")
    WifiMgr.retryFnc("wifi disconnected from " .. T.SSID .. " due to " .. T.reason)
end
WifiMgr.authmode_change_cb = function(old_auth_mode, new_auth_mode)
    assert(T, "wifi.authmode_change_cb T is nil")
    WifiMgr.retryFnc("wifi authmode changed from " .. old_auth_mode .. " to " .. new_auth_mode)
end
WifiMgr.got_ip_cb = function(T)
    WifiMgr.state = "fullyconected"
    assert(T, "wifi.got_ip_cb T is nil")
    print("[INFO] : got IP " .. T.IP)
    blinkTimer:stop(WifiMgr.blinkFlg)
end
WifiMgr.dhcp_timeout_cb = function(...)
    WifiMgr.retryFnc("dhcp timeout")
end

WifiMgr.tryFnc = function()
    WifiMgr.state = "probing"
    wifi.sta.getap(
        WifiMgr.searchCfg,
        1,
        function(tbl)
            local function tblHasEntries()
                for _ in pairs(tbl) do
                    return true
                end
                return false
            end
            if tblHasEntries() then
                WifiMgr.state = "configuring"
                if not wifi.sta.config(WifiMgr.connectCfg) then
                    WifiMgr.retryFnc("Failed to configure wifi")
                end
            else
                WifiMgr.retryFnc("wifi hotspot not found : " .. WifiMgr.cntx.ssid)
            end
        end
    )
end

WifiMgr.startWifi = function(cntx)
    WifiMgr.state = "initialized"
    WifiMgr.cntx = cntx
    wifi.setmode(wifi.STATION)
    wifi.sta.sethostname(cntx.hostname)
    WifiMgr.searchCfg = {
        ssid = cntx.ssid
    }
    WifiMgr.connectCfg = {
        ssid = cntx.ssid,
        pwd = cntx.pswd,
        auto = true,
        connected_cb = WifiMgr.connected_cb,
        disconnected_cb = WifiMgr.disconnected_cb,
        authmode_change_cb = WifiMgr.authmode_change_cb,
        got_ip_cb = WifiMgr.got_ip_cb,
        dhcp_timeout_cb = WifiMgr.dhcp_timeout_cb
    }
    WifiMgr.retryTimer:register(5000, tmr.ALARM_SEMI, WifiMgr.tryFnc)
    WifiMgr.tryFnc()
end

return WifiMgr
