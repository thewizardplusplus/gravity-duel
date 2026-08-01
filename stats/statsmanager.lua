---
-- @classmod StatsManager

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
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
  self._best_stats = self._stats_storage:best_stats()
end

---
-- @treturn Stats
function StatsManager:stats()
  return self._stats
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
function StatsManager:draw(screen, fonts)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)

  drawing.draw_drawables(screen, fonts, {self._stats, self._best_stats})
end

---
-- @function update
function StatsManager:update()
  local was_updated = self._best_stats:update(self._stats)
  if was_updated then
    self._stats_storage:store_best_stats(self._best_stats)
  end
end

return StatsManager
