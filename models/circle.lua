---
-- @classmod Circle

local middleclass = require("middleclass")
local typeutils = require("typeutils")

---
-- @table instance
-- @tfield number x
-- @tfield number y
-- @tfield number radius [0, ∞)

local Circle = middleclass("Circle")

---
-- @function new
-- @tparam number x
-- @tparam number y
-- @tparam number radius [0, ∞)
-- @treturn Circle
function Circle:initialize(x, y, radius)
  assert(typeutils.is_number(x))
  assert(typeutils.is_number(y))
  assert(typeutils.is_positive_number(radius))

  self.x = x
  self.y = y
  self.radius = radius
end

return Circle
