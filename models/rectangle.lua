-- luacheck: no max comment line length

---
-- @classmod Rectangle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

---
-- @table instance
-- @tfield number x [0, ∞)
-- @tfield number y [0, ∞)
-- @tfield number width [0, ∞)
-- @tfield number height [0, ∞)

local Rectangle = middleclass("Rectangle")
Rectangle:include(Nameable)
Rectangle:include(Stringifiable)

---
-- @function new
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam number width [0, ∞)
-- @tparam number height [0, ∞)
-- @treturn Rectangle
function Rectangle:initialize(x, y, width, height)
  assertions.is_number(x)
  assertions.is_number(y)
  assertions.is_number(width)
  assertions.is_number(height)

  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Rectangle:__data()
  return {
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @treturn number x [0, ∞)
-- @treturn number y [0, ∞)
function Rectangle:center()
  return self.x + self.width / 2, self.y + self.height / 2
end

---
-- @treturn number x [0, ∞)
-- @treturn number y [0, ∞)
function Rectangle:maximum()
  return self.x + self.width, self.y + self.height
end

---
-- @treturn number [0, ∞)
function Rectangle:grid_step()
  return self.height / 8
end

---
-- @treturn number [0, ∞)
function Rectangle:ui_grid_step()
  return self.height / 4
end

---
-- @treturn number [0, ∞)
function Rectangle:font_size()
  return self.height / 20
end

return Rectangle
