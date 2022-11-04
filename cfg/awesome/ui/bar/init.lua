local awful = require 'awful'
local wibox = require 'wibox'
local beautiful = require 'beautiful'
local gears = require 'gears'

local date = require 'ui.bar.modules.date'
local workspaces = require 'ui.bar.modules.workspaces'
local actions = require 'ui.bar.modules.actions'
local dashboard = require 'ui.bar.modules.dashboard'
local layoutbox = require 'ui.bar.modules.layoutbox'

---@diagnostic disable-next-line: undefined-global
screen.connect_signal('request::desktop_decoration', function (s)
  awful.tag(
		{'1', '2', '3', '4', '5', '6'},
		s, awful.layout.layouts[1]
  )

  local bar = wibox {
    type = 'dock',
    x = s.geometry.x,
    y = s.geometry.y,
    width = s.geometry.width,
    height = beautiful.bar_height,
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
    visible = true,
		shape = gears.shape.rectangle,
  }

  bar:struts { top = beautiful.bar_height }

  bar:setup {
    {
      {
        date,
        nil,
        {
          {
            actions,
            dashboard,
            layoutbox(s),
            spacing = 3,
            layout = wibox.layout.fixed.horizontal,
          },
          margins = 4,
          widget = wibox.container.margin,
        },
        layout = wibox.layout.align.horizontal,
      },
      {
        workspaces(s),
        halign = 'center',
        valign = 'center',
        layout = wibox.container.place,
      },
      layout = wibox.layout.stack,
    },
    left = 10,
    widget = wibox.container.margin,
  }
end)
