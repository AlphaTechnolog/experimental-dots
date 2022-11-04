local wibox = require 'wibox'
local beautiful = require 'beautiful'

local volume = require 'ui.dashboard.modules.volume-slider'
local music_player = require 'ui.dashboard.modules.music'
local actions = require 'ui.dashboard.modules.actions'
local charts = require 'ui.dashboard.modules.charts'
local footer = require 'ui.dashboard.modules.footer'

return {
  {
    {
			{
				volume,
				music_player,
				actions,
				spacing = beautiful.useless_gap * 4,
				layout = wibox.layout.fixed.vertical,
			},
			charts,
			footer,
			layout = wibox.layout.align.vertical,
    },
    {
      markup = '2',
      align = 'center',
      valign = 'center',
      widget = wibox.widget.textbox,
    },
    spacing = beautiful.useless_gap * 4,
    layout = wibox.layout.flex.horizontal,
  },
  margins = beautiful.useless_gap * 4,
  widget = wibox.container.margin,
}
