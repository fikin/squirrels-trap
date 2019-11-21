--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local nodemcu = require("nodemcu")
local w = require("wifi-mgr")
local blinkTimer = require("blink-timer")

function testNoSuchSSID()
    nodemcu.reset()
    local cntx = {
        ssid = "mySSID",
        pswd = "myPSWD",
        hostname = "myHN"
    }
    w.startWifi(cntx)
    lu.assertEquals(wifi.getmode(), wifi.STATION)
    lu.assertTrue(blinkTimer.tickets > 0)
end

local function assertIsConnectedOk()
    lu.assertEquals(wifi.getmode(), wifi.STATION)
    lu.assertEquals(blinkTimer.tickets, 0)
    local ip, netmask, gateway = wifi.sta.getip()
    lu.assertEquals(ip, "192.168.255.11")
    lu.assertEquals(netmask, "255.255.255.0")
    lu.assertEquals(gateway, "192.168.255.1")
end

local function configureWifiHostspot()
    nodemcu.wifiSTAsetConfigFnc(
        function(cfg)
            lu.assertEquals(cfg.ssid, "ssid1")
            lu.assertEquals(cfg.pwd, "pswd1")
            lu.assertEquals(wifi.sta.gethostname(), "myHN")
            return true, true, "AA:BB:CC:DD:EE:FF", 11, "192.168.255.11", "255.255.255.0", "192.168.255.1"
        end
    )
end

local function configureWifiScanList()
    nodemcu.wifiSTAsetAP({bssid1 = "ssid1, rssi1, authmode1, channel1", bssid2 = "ssid2, rssi2, authmode2, channel2"})
end

function testConnectOk()
    nodemcu.reset()
    configureWifiScanList()
    configureWifiHostspot()
    local cntx = {
        ssid = "ssid1",
        pswd = "pswd1",
        hostname = "myHN"
    }
    w.startWifi(cntx)
    nodemcu.advanceTime(1000)
    assertIsConnectedOk()
end

function testRetry()
    nodemcu.reset()
    configureWifiHostspot()
    local cntx = {
        ssid = "ssid1",
        pswd = "pswd1",
        hostname = "myHN"
    }
    w.startWifi(cntx)
    lu.assertEquals(w.state, "toberetrying")
    configureWifiScanList()
    nodemcu.advanceTime(6000)
    lu.assertEquals(w.state, "fullyconected")
    assertIsConnectedOk()
end

os.exit(lu.run())
