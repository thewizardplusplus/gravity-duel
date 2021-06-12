---
-- @classmod Range

local middleclass = require("middleclass")
local typeutils = require("typeutils")

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
  assert(typeutils.is_number(minimum))
  assert(typeutils.is_number(maximum, minimum))

  self.minimum = minimum
  self.maximum = maximum
end

return Range
