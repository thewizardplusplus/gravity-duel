---
-- @classmod Collider

local Collider = {}

---
-- @treturn number x
-- @treturn number y
function Collider:position()
  return self._collider:getPosition()
end

---
-- @function destroy
function Collider:destroy()
  self._collider:destroy()
end

return Collider
