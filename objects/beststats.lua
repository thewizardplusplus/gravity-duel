---
-- @classmod BestStats

local middleclass = require("middleclass")
local typeutils = require("typeutils")

---
-- @table instance
-- @tfield number _impulse_accuracy
-- @tfield number _destroyed_targets

local BestStats = middleclass("BestStats")

---
-- @function new
-- @tfield number impulse_accuracy [0, ∞)
-- @tfield number destroyed_targets [0, ∞)
-- @treturn BestStats
function BestStats:initialize(impulse_accuracy, destroyed_targets)
  assert(typeutils.is_positive_number(impulse_accuracy))
  assert(typeutils.is_positive_number(destroyed_targets))

  self._impulse_accuracy = impulse_accuracy
  self._destroyed_targets = destroyed_targets
end

return BestStats
