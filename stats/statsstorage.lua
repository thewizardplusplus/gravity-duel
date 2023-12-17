---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local flatdb = require("flatdb")
local assertions = require("luatypechecks.assertions")
local BestStats = require("objects.beststats")

---
-- @table instance
-- @tfield FlatDB _db

local StatsStorage = middleclass("StatsStorage")

---
-- @function new
-- @tparam string path
-- @treturn StatsStorage
-- @raise error message
function StatsStorage:initialize(path)
  assertions.is_string(path)

  local ok = love.filesystem.createDirectory(path)
  assert(ok, "unable to create the stats DB")

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  self._db = flatdb(full_path)

  if not self._db.stats then
    self._db.stats = {impulse_accuracy = 0, destroyed_targets = 0}
  end
end

---
-- @treturn BestStats
function StatsStorage:get_stats()
  return BestStats:new(
    self._db.stats.impulse_accuracy,
    self._db.stats.destroyed_targets
  )
end

---
-- @tparam BestStats stats
function StatsStorage:store_stats(stats)
  assertions.is_instance(stats, BestStats)

  self._db.stats = {
    impulse_accuracy = stats.impulse_accuracy,
    destroyed_targets = stats.destroyed_targets,
  }
  self._db:save()
end

return StatsStorage
