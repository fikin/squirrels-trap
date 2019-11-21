--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local lu = require("luaunit")
local nodemcu = require("nodemcu")

local app = require("context")

os.exit(lu.run())