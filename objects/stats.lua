---
-- @classmod Stats

local middleclass = require("middleclass")
local typeutils = require("typeutils")

---
-- @table instance
-- @tfield number _performed_impulses
-- @tfield number _hit_targets
-- @tfield number _destroyed_targets

local Stats = middleclass("Stats")

---
-- @function new
-- @treturn Stats
function Stats:initialize()
  self._performed_impulses = 0
  self._hit_targets = 0
  self._destroyed_targets = 0
end

---
-- @function add_impulse
function Stats:add_impulse()
  self._performed_impulses = self._performed_impulses + 1
end

---
-- @tparam number target_lifes [0, ∞)
function Stats:hit_target(target_lifes)
  assert(typeutils.is_positive_number(target_lifes))

  self._hit_targets = self._hit_targets + 1
  if target_lifes == 0 then
    self._destroyed_targets = self._destroyed_targets + 1
  end
end

return Stats
