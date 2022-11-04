local wibox = require "wibox"
local gears = require 'gears'
local beautiful = require 'beautiful'
local awful = require 'awful'
local helpers = require 'helpers'

-- making icons
local wifi = wibox.widget.textbox()

wifi.font = beautiful.nerd_font .. ' 19'

wifi:add_button(awful.button({}, 1, function ()
	WifiSignal.toggle()
end))

awesome.connect_signal('network::connected', function (is_connected)
	wifi:set_markup_silently(is_connected and '' or '睊')
end)

local volume = wibox.widget.textbox()

volume.font = beautiful.nerd_font .. ' 19'

volume:add_button(awful.button({}, 1, function ()
	VolumeSignal.toggle_muted()
end))

awesome.connect_signal('volume::muted', function (is_muted)
	volume:set_markup_silently(not is_muted and '' or '婢')
end)

-- container
local container = wibox.widget {
	{
		{
			wifi,
			volume,
			spacing = 12,
			layout = wibox.layout.fixed.horizontal,
		},
		top = 3,
		bottom = 3,
		left = 12,
		right = 12,
		widget = wibox.container.margin,
	},
	bg = beautiful.bg_normal,
	shape = gears.shape.rounded_bar,
	widget = wibox.container.background,
}

helpers.add_hover(container, beautiful.bg_normal, beautiful.black)

return container