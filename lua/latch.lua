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

    local function setServoTo(pos)
        assert(pos, "pos not given")
        pwm.setduty(cntx.latchPin, pos)
        pwm.start(cntx.latchPin)
        servoOffTimer:start()
    end

    local function readyTrap()
        info("servo to start position ...")
        pwm.setup(cntx.latchPin, 50, 0)
        servoOffTimer:register(
            servoOffMs,
            tmr.ALARM_SEMI,
            function()
                pwm.setduty(cntx.latchPin, 0)
                pwm.stop(cntx.latchPin)
                info("servo stopped.")
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
        info("servo to close position ...")
        setServoTo(latchTrippedPos)
    end

    readyTrap()
    return tripTheLatch
end

return init
