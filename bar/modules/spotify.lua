local bling = require("plugins.bling")
local scroller = require("plugins.text-scroller")
local wibox = require("wibox")
local playerctl = bling.signal.playerctl.lib()

local M = {
  initialized = false,
  scroller = nil,
  formatter = nil,
  scroll_enabled = true,
  state = {
    title = nil,
    artist = nil,
    album = nil,
    playing = nil,
  }
}

---@param state table
function M:format_status(state)
  if not state.title or not state.artist then
    return "No song playing"
  end

  return state.title .. " - " .. state.artist
end

---@param opts table|nil
---@return nil
function M:apply_config(opts)
  if not opts then
    return
  end

  if opts.scroll ~= nil then
    self.scroll_enabled = opts.scroll
  end

  if opts.formatter then
    self.formatter = opts.formatter
  end
end

---@param content string
---@param callback function
---@return nil
function M:create_scroller(content, callback)
  if #content > 30 and self.scroll_enabled then
    self.scroller = scroller:create({
      str = content,
      max_width = 30,
      speed = 1,
      callback = function(str)
        callback(str)
      end
    })
  else
    self.scroller = nil
    callback(content)
  end
end

---@param opts table|nil
---@return wibox.widget
function M:widget(opts)
  M:apply_config(opts)

  local widget = wibox.widget({
    markup = M:format_status({}),
    widget = wibox.widget.textbox
  })


  playerctl:connect_signal("metadata",
    function(_, title, artist, _, album, new, _)
      self.state = {
        title = title,
        artist = artist,
        album = album,
        playing = new
      }

      if self.scroller then
        self.scroller:stop()
      end

      self:create_scroller(self:format_status(self.state), function(str)
        if self.formatter then
          str = self.formatter(str)
        end

        widget:set_markup_silently(str)
      end)
    end)

  return widget
end

return M
