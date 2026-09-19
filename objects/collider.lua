---
-- @classmod Collider

local Vector2D = require("luamath.vector2d")

local Collider = {}

---
-- @treturn Vector2D
function Collider:position()
  return Vector2D:new(self._collider:getPosition())
end

---
-- @function destroy
function Collider:destroy()
  self._collider:destroy()
end

return Collider
