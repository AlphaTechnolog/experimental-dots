local awful = require 'awful'
local wibox = require 'wibox'
local helpers = require 'helpers'
local beautiful = require 'beautiful'

local layoutbox = awful.widget.layoutbox()

local function with_layoutbox(layoutbox)
  local base = wibox.widget {
    {
      layoutbox,
      margins = 5,
      widget = wibox.container.margin,
    },
    bg = beautiful.bg_normal,
    shape = helpers.mkroundedrect(7),
    widget = wibox.container.background,
  }

  helpers.add_hover(base, beautiful.bg_normal, beautiful.light_black)

  helpers.add_buttons(base, {
    awful.button({}, 1, function () awful.layout.inc( 1) end),
    awful.button({}, 3, function () awful.layout.inc(-1) end),
    awful.button({}, 4, function () awful.layout.inc(-1) end),
    awful.button({}, 5, function () awful.layout.inc( 1) end),
  })

-- disables layoutbox tooltip
  layoutbox._layoutbox_tooltip:remove_from_object(layoutbox)

  return base
end

return function (s)
  layoutbox.screen = s

  return with_layoutbox(layoutbox)
end
