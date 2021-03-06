--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local nodemcu = require("nodemcu")
local trap = require("trap")

function testStartup()
  nodemcu.reset()
  trap()
  nodemcu.advanceTime(6000)
end

os.exit(lu.run())
