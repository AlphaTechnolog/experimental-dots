local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local helpers = require("helpers")

local date = wibox.widget.textbox()

local function update_time()
  date.markup = '<b>' .. os.date('%I:%M %p') .. '</b>'
end

gears.timer {
  timeout = 1,
  call_now = true,
  autostart = true,
  callback = update_time
}

local container = wibox.widget {
	{
		{
			date,
			right = 9,
			left = 7,
			widget = wibox.container.margin,
		},
		id = 'background_role',
		shape = gears.shape.rounded_bar,
		bg = beautiful.bg_normal,
		widget = wibox.container.background,
	},
	top = 6,
	bottom = 6,
	widget = wibox.container.margin,
	set_bg = function (self, bg)
		self.background_role.bg = bg
	end,
}

helpers.add_hover(container, beautiful.bg_normal, beautiful.light_black)

container:add_button(awful.button({}, 1, function ()
	awesome.emit_signal("calendar::toggle")
end))

return container
