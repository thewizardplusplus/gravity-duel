local luaunit = require("luaunit")
local Stats = require("objects.stats")

-- luacheck: globals TestStats
TestStats = {}

function TestStats.test_tostring()
  local stats = Stats:new()
  for _ = 1, 10 do
    stats:add_impulse()
  end
  for _ = 1, 20 do
    stats:hit_target(23)
  end
  for _ = 1, 30 do
    stats:hit_target(0)
  end

  local text = tostring(stats)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Stats\"," ..
    "destroyed_targets = 30," ..
    "hit_targets = 50," ..
    "performed_impulses = 10" ..
  "}")
end
