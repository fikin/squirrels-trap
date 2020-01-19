--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local nodemcu = require("nodemcu")
local wifiOn = require("wifi-on")

function testNoSuchSSID()
    nodemcu.reset()
    local cntx = {
        ssid = "mySSID",
        pswd = "myPSWD",
        hostname = "myHN"
    }
    local isOkFnc = wifiOn(cntx)
    lu.assertEquals(wifi.getmode(), wifi.STATION)
    lu.assertFalse(isOkFnc())
end

local function assertIsConnectedOk(isOkFnc)
    lu.assertEquals(wifi.getmode(), wifi.STATION)
    lu.assertTrue(isOkFnc())
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
    local isOkFnc = wifiOn(cntx)
    nodemcu.advanceTime(6000)
    assertIsConnectedOk(isOkFnc)
end

function testRetry()
    nodemcu.reset()
    configureWifiHostspot()
    local cntx = {
        ssid = "ssid1",
        pswd = "pswd1",
        hostname = "myHN"
    }
    local isOkFnc = wifiOn(cntx)
    lu.assertFalse(isOkFnc())
    configureWifiScanList()
    nodemcu.advanceTime(6000)
    assertIsConnectedOk(isOkFnc)
end

os.exit(lu.run())
