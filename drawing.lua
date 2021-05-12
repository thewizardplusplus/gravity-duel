---
-- @module drawing

local typeutils = require("typeutils")

local drawing = {}

---
-- @tparam func drawer func(): nil
function drawing.draw_with_transformations(drawer)
  assert(typeutils.is_callable(drawer))

  love.graphics.push()
  drawer()
  love.graphics.pop()
end

return drawing
