local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
package.path = table.concat(require_paths, ";")

local luaunit = require("luaunit")

for _, module in ipairs({
  "models.circle",
  "models.color",
  "models.label",
  "models.range",
  "models.rectangle",
}) do
  require(module .. "_test")
end

os.exit(luaunit.run())
