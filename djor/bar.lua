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

local mykeyboardlayout = awful.widget.keyboardlayout()
local mytextclock = wibox.widget.textclock()

local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end)
)

M.init = function(s)
  s.prompt_box = awful.widget.prompt()

  s.layout_box = awful.widget.layoutbox(s)
  s.layout_box:buttons(gears.table.join(
    awful.button({}, 1, function() awful.layout.inc(1) end),
    awful.button({}, 3, function() awful.layout.inc(-1) end),
    awful.button({}, 4, function() awful.layout.inc(1) end),
    awful.button({}, 5, function() awful.layout.inc(-1) end)))

  s.tag_list = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons
  }

  s.mywibox = awful.wibar({ position = "top", opacity = 0.8, screen = s })

  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    -- Left widgets
    {
      layout = wibox.layout.fixed.horizontal,
      M.launcher,
      s.tag_list,
      s.prompt_box,
    },

    -- Middle widget
    s.mytasklist,

    -- Right widgets
    {
      layout = wibox.layout.fixed.horizontal,
      mykeyboardlayout,
      wibox.widget.systray(),
      mytextclock,
      s.layout_box,
    },
  }
end

return M
