local awful = require 'awful'
local beautiful = require 'beautiful'

local capi = {
  awesome = awesome,
}

-- @abbrev `awful.screen.focused()`
local s = function ()
  return awful.screen.focused()
end

-- returns the bar object for the actual focused screen
local bar = function ()
  return s().bar
end

capi.awesome.connect_signal('clients::maximize', function ()
  local tags = s().tags
  for _, tag in ipairs(tags) do
    if #tag:clients() == 1 then
      local c = tag:clients()[1]
      c.maximized = not bar().visible
    end
  end
end)

capi.awesome.connect_signal('bar::toggle', function ()
  local sb = bar()
  local v = sb.visible
  sb.visible = not sb.visible
  capi.awesome.emit_signal('wallpaper::update')
  capi.awesome.emit_signal('clients::maximize')
  capi.awesome.emit_signal('dashboard::update_dimensions', not v)
end)
