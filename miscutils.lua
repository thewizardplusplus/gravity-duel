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

return miscutils
