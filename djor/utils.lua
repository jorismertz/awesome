local style = require("djor.style")
local filesystem = require("gears.filesystem")

local M = {}

---@return string
M.config_path = function()
  return filesystem.get_configuration_dir():gsub("awesome/", "")
end


---@param text string
---@param color string|nil
---@param font string|nil
---@return string
M.html_text_style = function(text, color, font)
  color = color or style.colors.text
  font = font or style.theme.font
  return "<span color=\"" .. color .. "\" font=\"" .. font .. "\">" .. text .. "</span>"
end

---@param str string
---@param seperator string
---@return table
M.split_str = function(str, seperator)
  local result = {}
  for part in string.gmatch(str, "([^" .. seperator .. "]+)") do
    table.insert(result, part)
  end

  return result
end

---@param str string
---@return string
M.trim = function(str)
  local result = str:gsub("^%s*(.-)%s*$", "%1")
  return result
end


return M
