local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local applications = require("djor.apps")
local utils = require("djor.utils")

local M = {}

M.awesome_menu = {
  { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
  { "restart", awesome.restart },
  { "quit",    awesome.quit },
}

M.main_menu = awful.menu({
  items = {
    { "awesome",       M.awesome_menu,       beautiful.awesome_icon },
    { "open terminal", applications.terminal }
  }
})

M.launcher = awful.widget.launcher({
  image = utils.config_path() .. "awesome/icons/arch-linux.png",
  menu = M.main_menu
})

menubar.utils.terminal = applications.terminal

local colors = require('djor.style').colors
local date_format = utils.html_text_style("%y/%m/%d %H:%M:%S", colors.gold)
local clock = wibox.widget.textclock(date_format, 1)

local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end)
)

M.init = function(s)
  s.prompt_box = awful.widget.prompt()
  local spotify = require('bar.modules.spotify')
  local spotify_widget = spotify:widget({
    scroll = true,
    formatter = function(str)
      return utils.html_text_style(str, colors.foam, nil, true)
    end
  })

  s.layout_box = awful.widget.layoutbox(s)
  s.layout_box:buttons(gears.table.join(
    awful.button({}, 1, function() awful.layout.inc(1) end),
    awful.button({}, 3, function() awful.layout.inc(-1) end),
    awful.button({}, 4, function() awful.layout.inc(1) end),
    awful.button({}, 5, function() awful.layout.inc(-1) end)
  ))

  s.tag_list = awful.widget.taglist({
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
  })

  s.mywibox = awful.wibar({ position = "top", opacity = 0.8, screen = s })

  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    expand = "none",
    {
      layout = wibox.layout.align.horizontal,
      M.launcher,
      s.tag_list,
      s.prompt_box,
    },
    {
      layout = wibox.layout.align.horizontal,
      clock,
    },
    {
      layout = wibox.layout.align.horizontal,
      spotify_widget,
      wibox.layout.margin(wibox.widget.systray(), 10, 10, 10, 10),
      -- s.layout_box,
    },
  }
end

return M
