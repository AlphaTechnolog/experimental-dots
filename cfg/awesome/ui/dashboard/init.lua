local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dimensions = require("ui.dashboard.dimensions")

local rubato = require("modules.rubato")

require 'ui.dashboard.listener'

awful.screen.connect_for_each_screen(function (s)
  s.dashboard = {}

  local offset = beautiful.useless_gap * 2
  local bar_height = beautiful.bar_height

  awesome.connect_signal('dashboard::update_dimensions', function (v)
    bar_height = v and beautiful.bar_height or 0
  end)

  s.dashboard.popup = wibox {
    visible = false,
    ontop = true,
    x = (s.geometry.width / 2) - (dimensions.width / 2),
    y = s.geometry.y - dimensions.height - offset - bar_height,
    width = dimensions.width,
    height = dimensions.height,
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
    opacity = 0
  }

  local self = s.dashboard.popup

  local content = require 'ui.dashboard.content'

  self:setup({ widget = wibox.widget.textbox })

  self.transition_animation = rubato.timed {
    duration = 0.45,
    override_dt = true,
    rate = 60,
    pos = 0
  }

  self.transition_animation:subscribe(function (op)
    self.opacity = op
  end)

  self.transition_animation.target = 0

  self.animate = rubato.timed {
    duration = 0.45,
    override_dt = true,
    rate = 60
  }

  self.status = 'undefined'

  self.animate:subscribe(function (pos)
    self.y = pos

    if pos == bar_height + offset and self.status == 'opening' then
      self:setup(content)
    elseif self.status == 'closing' then
      self:setup({ widget = wibox.widget.textbox })
    end

    if pos == s.geometry.y - offset - dimensions.height - bar_height and self.status == 'closing' then
      self.visible = false
    end
  end)

  self.animate.target = s.geometry.y - offset - dimensions.height - bar_height

  function s.dashboard.toggle()
    if self.visible then
      s.dashboard.close()
    else
      s.dashboard.open()
    end
  end

  function s.dashboard.open()
    self.status = 'opening'
    self.visible = true
    self.animate.target = bar_height + offset
    self.transition_animation.target = 1
  end

  function s.dashboard.close()
    self.status = 'closing'
    self.transition_animation.target = 0
    self.animate.target = s.geometry.y - bar_height - offset - dimensions.height
  end
end)
