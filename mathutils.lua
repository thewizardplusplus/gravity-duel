---
-- @module mathutils

local typeutils = require("typeutils")
local Range = require("models.range")

local mathutils = {}

---
-- @tparam Range range
-- @treturn number [range.minimum, range.maximum)
function mathutils.random_in_range(range)
  assert(typeutils.is_instance(range, Range))

  return math.random() * (range.maximum - range.minimum) + range.minimum
end

return mathutils
