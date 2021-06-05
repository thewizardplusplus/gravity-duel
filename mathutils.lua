---
-- @module mathutils

local typeutils = require("typeutils")

local mathutils = {}

---
-- @tparam number minimum
-- @tparam number maximum [minimum, ∞)
-- @treturn number [minimum, maximum)
function mathutils.random_in_range(minimum, maximum)
  assert(typeutils.is_number(minimum))
  assert(typeutils.is_number(maximum, minimum))

  return math.random() * (maximum - minimum) + minimum
end

return mathutils
