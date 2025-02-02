local luaunit = require("luaunit")
local Circle = require("models.circle")

-- luacheck: globals TestCircle
TestCircle = {}

function TestCircle.test_tostring()
  local circle = Circle:new(10, 20, 30)
  local text = tostring(circle)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Circle\"," ..
    "radius = 30," ..
    "x = 10," ..
    "y = 20" ..
  "}")
end
