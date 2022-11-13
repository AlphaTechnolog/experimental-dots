---@diagnostic disable: undefined-global

local awful = require 'awful'
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'

local function make_button(txt, fg, bg, hfg, hbg, onclick)
	return function (c)
		local btn = wibox.widget {
			{
				{
					markup = txt,
					font = beautiful.nerd_font .. ' 7',
					widget = wibox.widget.textbox,
				},
				left = 8,
				right = 7,
				widget = wibox.container.margin,
			},
			shape = gears.shape.circle,
			fg = beautiful[fg],
			bg = beautiful[bg],
			widget = wibox.container.background,
		}

		local fg_transition = helpers.apply_transition {
			element = btn,
			prop = 'fg',
			bg = beautiful[fg],
			hbg = beautiful[hfg],
		}

		local bg_transition = helpers.apply_transition {
			element = btn,
			prop = 'bg',
			bg = beautiful[bg],
			hbg = beautiful[hbg],
		}

		btn:connect_signal('mouse::enter', function ()
			fg_transition.on()
			bg_transition.on()
		end)

		btn:connect_signal('mouse::leave', function ()
			fg_transition.off()
			bg_transition.off()
		end)

		btn:add_button(awful.button({}, 1, function ()
			if onclick then
				onclick(c)
			end
		end))

		return btn
	end
end

local close_button = make_button('', 'red', 'red', 'bg_normal', 'red', function (c)
	c:kill()
end)

local maximize_button = make_button('', 'yellow', 'yellow', 'bg_normal', 'yellow', function (c)
	c.maximized = not c.maximized
end)

local minimize_button = make_button('', 'green', 'green', 'bg_normal', 'green', function (c)
	gears.timer.delayed_call(function ()
		c.minimized = true
	end)
end)

client.connect_signal('request::titlebars', function (c)
	if c.requests_no_titlebar then
		return
	end

  local titlebar = awful.titlebar(c, {
    position = 'top',
    size = 35
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
    layout = wibox.layout.fixed.horizontal,
    buttons = titlebars_buttons,
  }

  titlebar:setup {
		{
			{
				close_button(c),
				maximize_button(c),
				minimize_button(c),
				layout = wibox.layout.fixed.horizontal,
			},
			left = 10,
			top = 11,
			bottom = 10,
			widget = wibox.container.margin,
		},
		buttons_loader,
    buttons_loader,
    layout = wibox.layout.align.horizontal
  }
end)
