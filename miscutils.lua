---
-- @module miscutils

local tick = require("tick")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")

local miscutils = {}

---
-- @tparam number interval [0, ∞)
-- @tparam func handler func(): nil
function miscutils.repeat_at_intervals(interval, handler)
  assertions.is_number(interval)
  assertions.is_function(handler)

  tick.delay(handler, 0)
  tick.recur(handler, interval)
end

---
-- @tparam {tab,...} destroyables group of tables with the destroy() method
-- @tparam func filter func(destroyable: tab): bool
-- @treturn {tab,...}
function miscutils.filter_destroyables(destroyables, filter)
  assertions.is_sequence(destroyables, checks.is_table)
  assertions.is_function(filter)

  return table.accept(destroyables, function(destroyable)
    assertions.is_table(destroyable)

    local ok = filter(destroyable)
    if not ok then
      destroyable:destroy()
    end

    return ok
  end)
end

return miscutils
