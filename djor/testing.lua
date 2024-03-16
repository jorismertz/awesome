local utils = require("djor.utils")
local bling = require("plugins.bling")

local playerctl = bling.signal.playerctl.lib()

local M = {}

M.main = function()
  playerctl:connect_signal("metadata",
    function(_, title, artist, album_path, album, new, player_name)
      utils.debug({
        title = title,
        artist = artist,
        album_path = album_path,
        album = album,
        new = new,
        player_name = player_name
      }, "playerctl")
      -- -- Set art widget
      -- art:set_image(gears.surface.load_uncached(album_path))
      --
      -- -- Set player name, title and artist widgets
      -- name_widget:set_markup_silently(player_name)
      -- title_widget:set_markup_silently(title)
      -- artist_widget:set_markup_silently(artist)
    end)
end

return M
