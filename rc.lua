pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local bar = require("djor.bar")
local style = require("djor.style")
local keys = require("djor.keys")

require('djor.errors')
require("awful.autofocus")
require("awful.hotkeys_popup.keys")

beautiful.init(style.theme)

awful.layout.layouts = {
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.top,
}

local tag_count = 1
local screen_count = 1

awful.screen.connect_for_each_screen(function(s)
  for _ = 1, 4 do
    local layout = awful.layout.layouts[screen_count]
    awful.tag.add(tostring(tag_count), {
      screen = s,
      layout = layout,
    })

    tag_count = tag_count + 1
  end

  style.wallpaper:init(s)
  bar.init(s)

  screen_count = screen_count + 1
end)

require('djor.keys')

awful.rules.rules = {
  {
    rule = {},
    -- This line makes sure new windows won't replace the current master window
    callback = awful.client.setslave,
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = keys.clientkeys,
      buttons = keys.clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },

  {
    rule_any = {
      instance = {},
      class = {
        "Arandr",
      },
      name = {
        "Event Tester",
      },
      role = {
        "pop-up",
      }
    },
    properties = { floating = true }
  },

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}

-- Mouse follows focus
require("plugins.micky")
-- Focus follows mouse
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Set wallpaper when screen geometry changes
screen.connect_signal("property::geometry", style.wallpaper.init)
