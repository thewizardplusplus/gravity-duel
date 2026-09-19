local luaunit = require("luaunit")
local Vector2D = require("luamath.vector2d")
local Circle = require("models.circle")

-- luacheck: globals TestCircle
TestCircle = {}

function TestCircle.test_tostring()
  local circle = Circle:new(Vector2D:new(10, 20), 30)
  local text = tostring(circle)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Circle\"," ..
    "center = {" ..
      "__name = \"Vector2D\"," ..
      "x = 10," ..
      "y = 20" ..
    "}," ..
    "radius = 30" ..
  "}")
end
