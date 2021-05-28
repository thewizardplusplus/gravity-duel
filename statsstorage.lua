---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local flatdb = require("flatdb")

---
-- @table instance
-- @tfield FlatDB _db

local StatsStorage = middleclass("StatsStorage")

---
-- @function new
-- @tparam string path
-- @treturn StatsStorage
function StatsStorage:initialize(path)
  assert(type(path) == "string")

  self._db = flatdb(path)
  if not self._db.stats then
    self._db.stats = {
      best_accuracy = 0,
      best_hit_targets = 0,
    }
  end
end

---
-- @treturn tab
function StatsStorage:get_stats()
  return {
    best_accuracy = self._db.stats.best_accuracy,
    best_hit_targets = self._db.stats.best_hit_targets,
  }
end

---
-- @tparam tab stats
function StatsStorage:store_stats(stats)
  assert(type(stats) == "table")

  self._db.stats = {
    best_accuracy = stats.best_accuracy
      or self._db.stats.best_accuracy,
    best_hit_targets = stats.best_hit_targets
      or self._db.stats.best_hit_targets,
  }

  self._db:save()
end

return StatsStorage
