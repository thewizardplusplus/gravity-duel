---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local flatdb = require("flatdb")
local typeutils = require("typeutils")
local BestStats = require("objects.beststats")

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
-- @treturn BestStats
function StatsStorage:get_stats()
  return BestStats:new(self._db.stats.best_accuracy, self._db.stats.best_hit_targets)
end

---
-- @tparam BestStats stats
function StatsStorage:store_stats(stats)
  assert(typeutils.is_instance(stats, BestStats))

  self._db.stats = {
    best_accuracy = stats.impulse_accuracy,
    best_hit_targets = stats.destroyed_targets,
  }
  self._db:save()
end

return StatsStorage
