---
-- @classmod Circle

local middleclass = require("middleclass")
local typeutils = require("typeutils")

---
-- @table instance
-- @tfield number x [0, ∞)
-- @tfield number y [0, ∞)
-- @tfield number radius [0, ∞)

local Circle = middleclass("Circle")

---
-- @function new
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam number radius [0, ∞)
-- @treturn Circle
function Circle:initialize(x, y, radius)
  assert(typeutils.is_positive_number(x))
  assert(typeutils.is_positive_number(y))
  assert(typeutils.is_positive_number(radius))

  self.x = x
  self.y = y
  self.radius = radius
end

return Circle
