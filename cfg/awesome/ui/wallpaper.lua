---@diagnostic disable: undefined-global
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local awful = require 'awful'
local gears = require 'gears'

local render_box = function (s)
	local wallpaper_popup = wibox {
		ontop = false,
		screen = s,
		x = s.geometry.x,
		y = s.geometry.y,
		height = s.geometry.height,
		width = s.geometry.width,
		type = 'dock',
		bg = beautiful.bg_normal,
		visible = true,
		shape = gears.shape.rectangle,
	}

	wallpaper_popup:setup {
		{
			{
				image = beautiful.wallpaper,
				forced_height = s.geometry.height - beautiful.bar_height,
				forced_width = s.geometry.width,
				upscale = true,
				horizontal_fit_policy = 'fit',
				vertical_fit_policy = 'fit',
				widget = wibox.widget.imagebox,
				clip_shape = function (cr, w, h)
					return gears.shape.partially_rounded_rect(cr, w, h, true, true, false, false, 12)
				end
			},
			top = beautiful.bar_height,
			widget = wibox.container.margin,
		},
		bg = beautiful.bg_normal,
		widget = wibox.container.background,
	}
end

screen.connect_signal('request::wallpaper', function (s)
	render_box(s)
end)
