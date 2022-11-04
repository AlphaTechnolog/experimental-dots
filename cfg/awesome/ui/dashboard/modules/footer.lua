---@diagnostic disable: undefined-global
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local gears = require 'gears'
local awful = require 'awful'
local helpers = require 'helpers'
local screenshot = require 'modules.screenshot'

local function base_button(icon, title)
	local widget = wibox.widget {
		{
			{
				{
					markup = icon,
					font = beautiful.nerd_font .. ' 16',
					valign = 'center',
					widget = wibox.widget.textbox,
				},
				{
					markup = title,
					valign = 'center',
					widget = wibox.widget.textbox,
				},
				spacing = beautiful.useless_gap * 2,
				layout = wibox.layout.fixed.horizontal,
			},
			top = 6,
			bottom = 6,
			left = 13,
			right = 13,
			widget = wibox.container.margin,
		},
		bg = beautiful.bg_lighter,
		shape = gears.shape.rounded_bar,
		widget = wibox.container.background,
	}

	local transition = helpers.add_hover(widget, beautiful.bg_lighter, beautiful.black)

	return {
		transition = transition,
		widget = widget,
	}
end

local area_screenshot = base_button('', 'Area')

area_screenshot.widget:add_button(awful.button({}, 1, function ()
	area_screenshot.transition.off()
	awesome.emit_signal('dashboard::toggle')
	screenshot.area { notify = true }
end))

local full_screenshot = base_button('', 'Full')

full_screenshot.widget:add_button(awful.button({}, 1, function ()
	full_screenshot.transition.off()
	awesome.emit_signal('dashboard::toggle')
	screenshot.full { notify = true }
end))

local poweroff = base_button('', 'Shutdown')

poweroff.widget:add_button(awful.button({}, 1, function ()
	poweroff.transition.off()
	awful.spawn('doas poweroff') -- doas should be right configured
end))

local container = wibox.widget {
	area_screenshot,
	full_screenshot,
	poweroff,
	spacing = beautiful.useless_gap * 2,
	layout = wibox.layout.flex.horizontal,
}

return container
