---
-- @classmod Circle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

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
  assertions.is_number(x)
  assertions.is_number(y)
  assertions.is_number(radius)

  self.x = x
  self.y = y
  self.radius = radius
end

return Circle
