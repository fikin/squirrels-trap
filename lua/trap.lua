--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
local function main()
  local cntx = require("cntx")
  local isOpen = true
  local ledb = require("led-blinker")(cntx)
  local latch = require("latch")(cntx)
  local barr = require("ir-barrier")(cntx)
  local net =
    require("net-on")(
    {
      getState = function()
        return {trapState = (isOpen and "open" or "closed")}
      end,
      port = cntx.port
    }
  )
  local wifi = require("wifi-on")(cntx)

  local function mainLoop()
    if isOpen and barr() then
      latch()
      isOpen = false
    end
    ledb(net() or wifi())
  end

  local t = tmr.create()
  t:register(200, tmr.ALARM_AUTO, mainLoop)
  t:start()
end

return main
