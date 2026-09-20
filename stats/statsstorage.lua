---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local BestStats = require("objects.beststats")

local StatsStorage = middleclass("StatsStorage")

---
-- @table instance
-- @tfield string _path
-- @tfield BestStats _best_stats

---
-- @function new
-- @tparam string path
-- @treturn StatsStorage
-- @raise error message
function StatsStorage:initialize(path)
  assertions.is_string(path)

  local best_stats, err = json.load_from_json(
    path,
    BestStats.schema(),
    { BestStats = BestStats.from_options },
    function(path) -- luacheck: no redefined
      assertions.is_string(path)

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not best_stats then
    print("unable to load the stats: " .. err)

    best_stats = BestStats:new(0, 0)
  end

  self._path = path
  self._best_stats = best_stats
end

---
-- @treturn BestStats
function StatsStorage:best_stats()
  return self._best_stats
end

---
-- @tparam BestStats best_stats
function StatsStorage:store_best_stats(best_stats)
  assertions.is_instance(best_stats, BestStats)

  self._best_stats = best_stats

  local ok, err =
    json.save_to_json(self._path, best_stats, love.filesystem.write)
  if not ok then
    print("unable to save the stats: " .. err)
  end
end

return StatsStorage
