local gears = require("gears")

local M = {
  max_width = 20,
  speed = 1,

  str = nil,
  scroll_pos = 1,
  state = nil,
}

function M:_apply_config(config)
  self.max_width = config.max_width or self.max_width
  self.speed = config.speed or self.speed
  self.str = config.str or self.str
end

function M:_scroll()
  local str = self.str
  local max_width = self.max_width
  local scroll_pos = self.scroll_pos

  if scroll_pos + max_width >= #str then
    self.scroll_pos = 1
    return str:sub(1, max_width)
  end

  local result = str:sub(scroll_pos, scroll_pos + max_width)
  self.scroll_pos = scroll_pos + 1

  return result
end

---@param callback function
function M:_start_scroll(callback)
  local timer = gears.timer({
    call_now = true,
    timeout = self.speed
  })
  timer:connect_signal("timeout", function()
    self.state = self:_scroll()
    callback(self.state)
  end)
  timer:start()
  self.timer = timer
end

function M:_stop_scroll()
  if self.timer then
    self.timer:stop()
  end
end

---@param config table
---@param callback function Function that will be called with the current state of the scroller on each update
function M:create(config)
  self:_apply_config(config)
  self:_start_scroll(config.callback)

  return self
end

return M
