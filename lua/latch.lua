--[[
License : GLPv3, see LICENCE in root of repository

Authors : Nikolay Fiykov, v1
--]]
require("pwm")

local function spawn(timeout, fnc, ...)
    local vargs = table.pack(...)
    local t = tmr.create()
    t:register(
        timeout,
        tmr.ALARM_SINGLE,
        function(t)
            fnc(table.unpack(vargs))
        end
    )
    t:start()
end

local function init(cntx)
    assert(cntx)
    assert(cntx.latchPin, "latchPin not given")
    local latchReadyPos = cntx.latchReadyPos or 30
    local latchTrippedPos = cntx.latchTrippedPos or 120
    local servoOffMs = cntx.servoOffMs or 500
    local servoOffTimer = tmr.create()

    local function setServoTo(pos)
        assert(pos, "pos not given")
        pwm.setduty(cntx.latchPin, pos)
        pwm.start(cntx.latchPin)
        servoOffTimer:start()
    end

    local function readyTrap()
        pwm.setup(cntx.latchPin, 50, 0)
        servoOffTimer:register(
            servoOffMs,
            tmr.ALARM_SEMI,
            function()
                pwm.setduty(cntx.latchPin, 0)
                pwm.stop(cntx.latchPin)
            end
        )
        setServoTo(latchTrippedPos)
        spawn(
            servoOffMs + 100,
            function()
                setServoTo(latchReadyPos)
            end
        )
    end

    local function tripTheLatch()
        setServoTo(latchTrippedPos)
    end

    readyTrap()
    return tripTheLatch
end

return init
