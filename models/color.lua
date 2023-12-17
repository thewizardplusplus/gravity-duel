---
-- @classmod Color

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

---
-- @table instance
-- @tfield number red [0, 1]
-- @tfield number green [0, 1]
-- @tfield number blue [0, 1]

local Color = middleclass("Color")

---
-- @function new
-- @tparam number red [0, 1]
-- @tparam number green [0, 1]
-- @tparam number blue [0, 1]
-- @treturn Color
function Color:initialize(red, green, blue)
  assertions.is_number(red)
  assertions.is_number(green)
  assertions.is_number(blue)

  self.red = red
  self.green = green
  self.blue = blue
end

---
-- @treturn {number,number,number}
--   red, green and blue values in the range [0, 1]
function Color:channels()
  return {self.red, self.green, self.blue}
end

return Color
