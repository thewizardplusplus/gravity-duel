---
-- @classmod Range

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield number minimum
-- @tfield number maximum [minimum, ∞)

local Range = middleclass("Range")

---
-- @function new
-- @tparam number minimum
-- @tparam number maximum [minimum, ∞)
-- @treturn Range
function Range:initialize(minimum, maximum)
  assertions.is_number(minimum)
  assertions.is_number(maximum)

  self.minimum = minimum
  self.maximum = maximum
end

return Range
