---@diagnostic disable: undefined-global
local wibox = require 'wibox'
local awful = require 'awful'
local gears = require 'gears'
local beautiful = require 'beautiful'
local helpers = require 'helpers'

local rubato = require 'modules.rubato'

local function simple_button(cb)
  return awful.button({}, 1, function (...)
    if cb then
      cb(...)
    end
  end)
end

local function tags_scroll()
  return {
    awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end),
  }
end

return function (s)
  return awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style = {
      shape = gears.shape.rounded_bar,
    },
    layout = {
      spacing = 12,
      layout = wibox.layout.fixed.horizontal,
    },
    buttons = {
      simple_button(function (t)
        t:view_only()
      end),

      awful.button({ modkey }, 1, function (t)
        if client.focus then
          client.focus:move_to_tag(t)
        end
      end),

      tags_scroll()[1],
      tags_scroll()[2],
    },
    widget_template = {
      { widget = wibox.widget.textbox },
      forced_height = 10,
      forced_width = 20,
      shape = gears.shape.rounded_bar,
      widget = wibox.container.background,
      create_callback = function (self, tag)
        self.animate = rubato.timed { duration = 0.25 }

        self.animate:subscribe(function (pos)
          self.forced_width = pos
        end)

        local urgents = nil

        local _urgents = function ()
          urgents = helpers.filter(tag:clients(), function (_, c)
            return c.urgent == true
          end)
        end

        _urgents()

        ---@diagnostic disable-next-line: undefined-global
        client.connect_signal('property::urgent', _urgents)

        self.update = function ()
          if #urgents > 0 then
            self.bg = beautiful.red
            self.animate.target = 15
          elseif tag.selected then
            self.bg = beautiful.blue
            self.animate.target = 19
          elseif #tag:clients() > 0 then
            self.bg = beautiful.light_black
            self.animate.target = 10
          else
            self.bg = beautiful.black
            self.animate.target = 10
          end
        end

        self.update()
      end,
      update_callback = function (self)
        self.update()
      end
    }
  }
end
