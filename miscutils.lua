---
-- @module miscutils

local tick = require("tick")
local typeutils = require("typeutils")

local miscutils = {}

---
-- @tparam number interval [0, ∞)
-- @tparam func handler func(): nil
function miscutils.repeat_at_intervals(interval, handler)
  assert(typeutils.is_positive_number(interval))
  assert(typeutils.is_callable(handler))

  tick.delay(handler, 0)
  tick.recur(handler, interval)
end

---
-- @tparam {tab,...} destroyables group of tables with the destroy() method
-- @tparam func filter func(destroyable: tab): bool
-- @treturn {tab,...}
function miscutils.filter_destroyables(destroyables, filter)
  assert(type(destroyables) == "table")
  assert(typeutils.is_callable(filter))

  return table.accept(destroyables, function(destroyable)
    assert(type(destroyable) == "table"
      and typeutils.is_callable(destroyable.destroy))

    local ok = filter(destroyable)
    if not ok then
      destroyable:destroy()
    end

    return ok
  end)
end

return miscutils
