---@diagnostic disable: undefined-global

local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'

local function make_button(color, onclick)
	return function (c)
		local btn = wibox.widget {
			{
				{
					id = 'background_role',
					forced_height = 15,
					forced_width = 15,
					bg = beautiful[color],
					shape = gears.shape.circle,
					widget = wibox.container.background,
				},
				top = 3,
				bottom = 4,
				widget = wibox.container.margin,
			},
			valign = 'center',
			layout = wibox.container.place,
			set_background = function (self, new_bg)
				self:get_children_by_id('background_role')[1].bg = new_bg
			end
		}

		btn:add_button(awful.button({}, 1, function ()
			if onclick then
				onclick(c)
			end
		end))

		btn.background = c.active and beautiful[color] or beautiful.light_black

		client.connect_signal('property::active', function (updated_client)
			if updated_client == c then
				btn.background = updated_client.active and beautiful[color] or beautiful.light_black
			end
		end)

		return btn
	end
end

local close_button = make_button('red', function (c)
	c:kill()
end)

local maximize_button = make_button('green', function (c)
	c.maximized = not c.maximized
end)

local minimize_button = make_button('yellow', function (c)
	-- bypass AwesomeWM issues with `client.minimized`
	gears.timer {
		timeout = 0.05,
		call_now = false,
		autostart = true,
		single_shot = true,
		callback = function ()
			if not c.minimized then
				c.minimized = true
			end
		end
	}
end)

local floating_button = make_button('cyan', function (c)
	c.floating = not c.floating
end)

client.connect_signal('request::titlebars', function (c)
	if c.requests_no_titlebar then
		return
	end

  local titlebar = awful.titlebar(c, {
    position = 'left',
    size = 39
  })

  local titlebars_buttons = {
    awful.button({}, 1, function ()
      c:activate {
        context = 'titlebar',
        action = 'mouse_move',
      }
    end),
    awful.button({}, 3, function ()
      c:activate {
        context = 'titlebar',
        action = 'mouse_resize',
      }
    end)
  }

  local buttons_loader = {
    layout = wibox.layout.fixed.vertical,
    buttons = titlebars_buttons,
  }

  titlebar:setup {
    {
			{
				close_button(c),
				maximize_button(c),
				minimize_button(c),
				layout = wibox.layout.fixed.vertical,
			},
			top = 8,
			widget = wibox.container.margin,
    },
    buttons_loader,
		{
			floating_button(c),
			bottom = 8,
			widget = wibox.container.margin,
		},
    layout = wibox.layout.align.vertical
  }
end)
