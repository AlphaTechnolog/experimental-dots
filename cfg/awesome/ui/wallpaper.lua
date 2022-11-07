---@diagnostic disable: undefined-global
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local awful = require 'awful'
local gears = require 'gears'

local this_screen = function ()
  return awful.screen.focused()
end

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

  local wallpaper = wibox.widget {
    {
      id = 'image_role',
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
    set_with_effect = function (self, v)
      local img = self:get_children_by_id('image_role')[1]
      if v then
        self.top = beautiful.bar_height
        img.forced_height = s.geometry.height - beautiful.bar_height
        img.clip_shape = function (cr, w, h)
          return gears.shape.partially_rounded_rect(cr, w, h, true, true, false, false, 12)
        end
      else
        self.top = 0
        img.forced_height = s.geometry.height
        img.clip_shape = gears.shape.rectangle
      end
    end
  }

  -- caught when bar.visible changes
  awesome.connect_signal('wallpaper::update', function ()
    wallpaper.with_effect = this_screen().bar.visible
  end)

	wallpaper_popup:setup {
    wallpaper,
		bg = beautiful.bg_normal,
		widget = wibox.container.background,
	}
end

screen.connect_signal('request::wallpaper', function (s)
	render_box(s)
end)
