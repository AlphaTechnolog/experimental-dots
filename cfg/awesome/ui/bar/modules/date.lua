local wibox = require 'wibox'
local gears = require 'gears'

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

return date
