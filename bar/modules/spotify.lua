-- TODO:
-- Implement dbus for spotify
-- Update widget based on dbus events

local scroller = require("plugins.text-scroller")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local utils = require("djor.utils")
local script_path = utils.config_path() .. "awesome/bar/modules/spotify.sh"

local M = {
  initialized = false,
  timer = nil,
  scroller = nil,
  formatter = nil,
  scroll_enabled = true,
  signals = {
    update = "spotify_widget:redraw",
    markup = "spotify_widget:set_markup"
  },
  state = {
    title = nil,
    artist = nil,
    album = nil,
    playing = nil,
  }
}


-- Gets the current status of the spotify player
-- and calls the callback with the result as first argument
---@param callback function
function M:fetch_status(callback)
  awful.spawn.easy_async_with_shell(script_path, function(out)
    local parsed = utils.split_str(out, "^")
    callback({
      title = utils.trim(parsed[1]),
      artist = utils.trim(parsed[2]),
      album = utils.trim(parsed[3]),
    })
  end)
end

---@param state table
function M:format_status(state)
  if not state.title then
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

---@param opts table|nil
---@return wibox.widget
function M:widget(opts)
  M:apply_config(opts)
  if not M.initialized then
    M:fetch_status(function(_)
      M.initialized = true
      M:update_widget()
      M:_start_polling()
    end)
  end

  local widget = wibox.widget({
    markup = M:format_status({}),
    widget = wibox.widget.textbox
  })

  local function set_markup(markup)
    if self.formatter then
      markup = self.formatter(markup)
    end
    widget:set_markup_silently(markup)
  end

  local function on_song_update(content)
    if #content > 30 and self.scroll_enabled then
      M.scroller = scroller:create({
          str = content,
          max_width = 30,
          speed = 1
        },
        function(str)
          set_markup(str)
        end)
    else
      set_markup(content)
    end
  end

  awesome.connect_signal(M.signals.markup, function(str)
    set_markup(str)
  end)

  -- M:update_widget()
  awesome.connect_signal(M.signals.update, function()
    M:fetch_status(function(state)
      if state.title ~= M.state.title then
        M.state = state
        if M.scroller then
          M.scroller:_stop_scroll()
        end

        local content = M:format_status(state)
        on_song_update(content)
      end
    end)
  end)

  return widget
end

function M:update_widget()
  awesome.emit_signal(M.signals.update)
end

function M:_start_polling()
  local timer = gears.timer({ timeout = 1 })
  timer:connect_signal("timeout", function()
    M:update_widget()
  end)
  timer:start()
  M.timer = timer
end

function M:_stop_polling()
  if M.timer then
    M.timer:stop()
  end
end

return M
