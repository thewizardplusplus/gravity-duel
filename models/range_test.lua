local luaunit = require("luaunit")
local Range = require("models.range")

-- luacheck: globals TestRange
TestRange = {}

function TestRange.test_tostring()
  local range = Range:new(10, 20)
  local text = tostring(range)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Range\"," ..
    "maximum = 20," ..
    "minimum = 10" ..
  "}")
end
