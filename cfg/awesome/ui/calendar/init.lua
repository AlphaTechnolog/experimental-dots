local awful = require 'awful'
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local rubato = require 'modules.rubato'

local dimensions = require 'ui.calendar.dimensions'
local content = require 'ui.calendar.content'

require 'ui.calendar.listener'

awful.screen.connect_for_each_screen(function (s)
	s.calendar = {}

	s.calendar.popup = wibox {
		x = s.geometry.x + beautiful.useless_gap * 2,
		y = s.geometry.y + beautiful.bar_height + beautiful.useless_gap * 2,
		width = dimensions.width,
		height = 1,
		ontop = true,
		visible = false,
	}

	local self = s.calendar.popup

	local hidden_widget = {
		widget = wibox.widget.textbox,
	}

	self:setup(hidden_widget)

	local animate = rubato.timed { duration = 0.25 }

	self.status = 'undefined'

	animate:subscribe(function (h)
		if h == dimensions.height and self.status == 'opening' then
			self:setup(content)
		end

		if h >= 1 then
			self.height = h
		elseif h == 0 and self.status == 'closing' then
			self.visible = false
		end
	end)

	function s.calendar.show ()
		self.status = 'opening'
		self.visible = true
		animate.target = dimensions.height
	end

	function s.calendar.hide ()
		self.status = 'closing'
		self:setup(hidden_widget)
		animate.target = 0
	end

	function s.calendar.toggle ()
		if self.visible then
			s.calendar.hide()
		else
			s.calendar.show()
		end
	end
end)
