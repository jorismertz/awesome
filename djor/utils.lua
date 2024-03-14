local filesystem = require("gears.filesystem")

local M = {}

---@return string
M.config_path = function()
  return filesystem.get_configuration_dir():gsub("awesome/", "")
end

return M
