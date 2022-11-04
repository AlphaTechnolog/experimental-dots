local awful = require 'awful'

client.connect_signal("manage", function (c)
   if c.floating then
      if c.transient_for == nil then
         awful.placement.centered(c, {honor_workarea = true})
      else
         awful.placement.centered(c, {parent = c.transient_for, honor_workarea = true})
      end
      awful.placement.no_offscreen(c)
   end
end)
