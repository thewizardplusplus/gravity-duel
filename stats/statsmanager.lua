---
-- @classmod StatsManager

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local drawing = require("drawing")
local Rectangle = require("models.rectangle")
local Stats = require("objects.stats")
local StatsStorage = require("stats.statsstorage")

---
-- @table instance
-- @tfield stats.StatsStorage _stats_storage
-- @tfield objects.Stats _stats
-- @tfield objects.BestStats _best_stats

local StatsManager = middleclass("StatsManager")

---
-- @function new
-- @tparam string storage_path
-- @treturn StatsManager
-- @raise error message
function StatsManager:initialize(storage_path)
  assertions.is_string(storage_path)

  self._stats_storage = StatsStorage:new(storage_path)
  self._stats = Stats:new()
  self._best_stats = self._stats_storage:get_stats()
end

---
-- @tparam Rectangle screen
function StatsManager:draw(screen)
  assertions.is_instance(screen, Rectangle)

  drawing.draw_drawables(screen, {self._stats, self._best_stats})
end

---
-- @function update
function StatsManager:update()
  local was_updated = self._best_stats:update(self._stats)
  if was_updated then
    self._stats_storage:store_stats(self._best_stats)
  end
end

---
-- @function add_impulse
function StatsManager:add_impulse()
  self._stats:add_impulse()
end

---
-- @tparam number target_lifes [0, ∞)
function StatsManager:hit_target(target_lifes)
  assertions.is_number(target_lifes)

  self._stats:hit_target(target_lifes)
end

return StatsManager
