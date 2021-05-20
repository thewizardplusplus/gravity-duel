---
-- @module mathutils

local mathutils = {}

---
-- @tparam number minimum
-- @tparam number maximum [minimum, ∞)
-- @treturn number [minimum, maximum)
function mathutils.random_in_range(minimum, maximum)
  assert(type(minimum) == "number")
  assert(type(maximum) == "number" and maximum >= minimum)

  return math.random() * (maximum - minimum) + minimum
end

return mathutils
