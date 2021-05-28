---
-- @classmod Stats

local middleclass = require("middleclass")

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

return Stats
