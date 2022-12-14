---@diagnostic disable:undefined-global

local gears = require 'gears'
local wibox = require 'wibox'
local awful = require 'awful'
local beautiful = require 'beautiful'
local naughty = require 'naughty'
local dpi = beautiful.xresources.apply_dpi

local color = require 'modules.color'
local rubato = require 'modules.rubato'

local helpers = {}

-- colorize a text using pango markup
function helpers.get_colorized_markup(content, fg)
    fg = fg or beautiful.blue
    content = content or ''

    return '<span foreground="' .. fg .. '">' .. content .. '</span>'
end

function helpers.apply_transition(opts)
    opts = opts or {}

    local bg = opts.bg or beautiful.bg_lighter
    local hbg = opts.hbg or beautiful.black

    local element, prop = opts.element, opts.prop

    local background = color.color { hex = bg }
    local hover_background = color.color { hex = hbg }

    local transition = color.transition(background, hover_background, color.transition.RGB)

    local fading = rubato.timed { duration = 0.30 }

    fading:subscribe(function (pos)
        element[prop] = transition(pos / 100).hex
    end)

    return {
        on = function ()
            fading.target = 100
        end,
        off = function ()
            fading.target = 0
        end
    }
end

-- add hover support to wibox.container.background-based elements
function helpers.add_hover(element, bg, hbg)
    local transition = helpers.apply_transition {
        element = element,
        prop = 'bg',
        bg = bg,
        hbg = hbg,
    }

    element:connect_signal('mouse::enter', transition.on)
    element:connect_signal('mouse::leave', transition.off)

    return transition
end

-- create a rounded rect using a custom radius
function helpers.mkroundedrect(radius)
    radius = radius or dpi(7)
    return function (cr, w, h)
        return gears.shape.rounded_rect(cr, w, h, radius)
    end
end

-- create a simple rounded-like button with hover support
function helpers.mkbtn(template, bg, hbg, radius)
    local button = wibox.widget {
        {
            template,
            margins = dpi(7),
            widget = wibox.container.margin,
        },
        bg = bg,
        widget = wibox.container.background,
        shape = helpers.mkroundedrect(radius),
    }

    if bg and hbg then
        helpers.add_hover(button, bg, hbg)
    end

    return button
end

-- add a list of buttons using :add_button to `widget`.
function helpers.add_buttons(widget, buttons)
    for _, button in ipairs(buttons) do
        widget:add_button(button)
    end
end

-- trim strings
function helpers.trim(input)
    local result = input:gsub("%s+", "")
    return string.gsub(result, "%s+", "")
end

-- make a rounded container for make work the antialiasing.
function helpers.mkroundedcontainer(template, bg)
    return wibox.widget {
        template,
        shape = helpers.mkroundedrect(),
        bg = bg,
        widget = wibox.container.background,
    }
end

-- make an awful.popup that's used to replace the native AwesomeWM tooltip component
function helpers.make_popup_tooltip(text, placement)
    local ret = {}

    ret.widget = wibox.widget {
        {
            {
                id = 'image',
                image = beautiful.hints_icon,
                forced_height = dpi(12),
                forced_width = dpi(12),
                halign = 'center',
                valign = 'center',
                widget = wibox.widget.imagebox,
            },
            {
                id = 'text',
                markup = text or '',
                align = 'center',
                widget = wibox.widget.textbox,
            },
            spacing = dpi(7),
            layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(12),
        widget = wibox.container.margin,
        set_text = function (self, t)
            self:get_children_by_id('text')[1].markup = t
        end,
        set_image = function (self, i)
            self:get_children_by_id('image')[1].image = i
        end
    }

    ret.popup = awful.popup {
        visible = false,
        shape = helpers.mkroundedrect(),
        bg = beautiful.bg_normal .. '00',
        fg = beautiful.fg_normal,
        ontop = true,
        placement = placement or awful.placement.centered,
        screen = awful.screen.focused(),
        widget = helpers.mkroundedcontainer(ret.widget, beautiful.bg_normal),
    }

    local self = ret.popup

    function ret.show()
        self.screen = awful.screen.focused()
        self.visible = true
    end

    function ret.hide()
        self.visible = false
    end

    function ret.toggle()
        if not self.visible and self.screen ~= awful.screen.focused() then
            self.screen = awful.screen.focused()
        end
        self.visible = not self.visible
    end

    function ret.attach_to_object(object)
        object:connect_signal('mouse::enter', ret.show)
        object:connect_signal('mouse::leave', ret.hide)
    end

    return ret
end

-- capitalize a string
function helpers.capitalize (txt)
    return string.upper(string.sub(txt, 1, 1))
        .. string.sub(txt, 2, #txt)
end

-- a fully capitalizing helper.
function helpers.complex_capitalizing (s)
    local r, i = '', 0
    for w in s:gsub('-', ' '):gmatch('%S+') do
        local cs = helpers.capitalize(w)
        if i == 0 then
            r = cs
        else
            r = r .. ' ' .. cs
        end
        i = i + 1
    end

    return r
end

-- limit a string by a length and put ... at the final if the
-- `max_length` is exceded `str`
function helpers.limit_by_length (str, max_length, use_pango)
    local sufix = ''
    local toput = '...'

    if #str > max_length - #toput then
        str = string.sub(str, 1, max_length - 3)
        sufix = toput
    end

    if use_pango and sufix == toput then
        sufix = helpers.get_colorized_markup(sufix, beautiful.light_black)
    end

    return str .. sufix
end

-- apply a margin container to a given widget
function helpers.apply_margin(widget, margins, top, bottom, right, left)
    return wibox.widget {
        widget,
        margins = margins,
        left = left,
        right = right,
        top = top,
        bottom = bottom,
        widget = wibox.container.margin,
    }
end

-- just a javascript equivalent of Array.filter but for lua.
function helpers.filter(t, iterator)
  local ret = {}
  for index, value in ipairs(t) do
    if iterator(index, value) then
      table.insert(ret, iterator(index, value))
    end
  end

  return ret
end

-- javascript equivalent of Array.find but for lua.
function helpers.find(table, iterator)
  return helpers.filter(table, iterator)[1]
end

function helpers.get_notification_widget(n)
    return {
        {
            {
                {
                    {
                        {
                            image = n.icon or beautiful.fallback_notif_icon,
                            forced_height = 32,
                            forced_width = 32,
                            valign = 'center',
                            align = 'center',
                            clip_shape = gears.shape.circle,
                            widget = wibox.widget.imagebox,
                        },
                        {
                            markup = helpers.complex_capitalizing(n.app_name == '' and 'Cannot detect app' or n.app_name),
                            align = 'left',
                            valign = 'center',
                            widget = wibox.widget.textbox,
                        },
                        spacing = dpi(10),
                        layout = wibox.layout.fixed.horizontal,
                    },
                    margins = dpi(10),
                    widget = wibox.container.margin,
                },
                {
                    {
                        {
                            markup = '',
                            widget = wibox.widget.textbox,
                        },
                        top = 1,
                        widget = wibox.container.margin,
                    },
                    bg = beautiful.light_black,
                    widget = wibox.container.background,
                },
                layout = wibox.layout.fixed.vertical,
            },
            {
                {
                    n.title == '' and nil or {
                        markup = '<b>' .. helpers.complex_capitalizing(n.title) .. '</b>',
                        align = 'center',
                        valign = 'center',
                        widget = wibox.widget.textbox,
                    },
                    {
                        markup = n.title == '' and '<b>' .. n.message .. '</b>' or n.message,
                        align = 'center',
                        valign = 'center',
                        widget = wibox.widget.textbox,
                    },
                    spacing = dpi(5),
                    layout = wibox.layout.fixed.vertical,
                },
                top = dpi(25),
                left = dpi(12),
                right = dpi(12),
                bottom = dpi(15),
                widget = wibox.container.margin,
            },
            {
                {
                    notification = n,
                    base_layout = wibox.widget {
                        spacing = dpi(12),
                        layout = wibox.layout.flex.horizontal,
                    },
                    widget_template = {
                        {
                            {
                                {
                                    id = 'text_role',
                                    widget = wibox.widget.textbox,
                                },
                                widget = wibox.container.place,
                            },
                            top = dpi(7),
                            bottom = dpi(7),
                            left = dpi(4),
                            right = dpi(4),
                            widget = wibox.container.margin,
                        },
                        shape = gears.shape.rounded_bar,
                        bg = beautiful.black,
                        widget = wibox.container.background,
                    },
                    widget = naughty.list.actions,
                },
                margins = dpi(12),
                widget = wibox.container.margin,
            },
            spacing = dpi(7),
            layout = wibox.layout.align.vertical,
        },
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        shape = helpers.mkroundedrect(),
        widget = wibox.container.background,
    }
end

return helpers