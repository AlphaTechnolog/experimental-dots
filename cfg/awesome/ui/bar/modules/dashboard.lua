local wibox = require('wibox')
local helpers = require 'helpers'
local beautiful = require 'beautiful'
local awful = require 'awful'

local button = wibox.widget {
  {
    {
      markup = '',
      font = beautiful.nerd_font .. ' 16',
      align = 'center',
      valign = 'center',
      widget = wibox.widget.textbox,
    },
    margins = 4,
    widget = wibox.container.margin,
  },
  bg = beautiful.bg_normal,
  shape = helpers.mkroundedrect(7),
  widget = wibox.container.background,
}

helpers.add_hover(button, beautiful.bg_normal, beautiful.light_black)

button:add_button(awful.button({}, 1, function ()
  ---@diagnostic disable-next-line: undefined-global
  awesome.emit_signal('dashboard::toggle')
end))

return button
