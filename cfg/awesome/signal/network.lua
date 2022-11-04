---@diagnostic disable:undefined-global

-- just works with NetworkManager

local gears = require 'gears'
local awful = require 'awful'
local helpers = require 'helpers'

local network = {}

local get_ssid = "iwgetid -r"
local configuration_dir = gears.filesystem.get_configuration_dir()

function network.re_emit_connected_signal()
  awful.spawn.easy_async_with_shell(get_ssid, function (out)
    awesome.emit_signal('network::connected', helpers.trim(out) ~= '')
  end)
end

function network.re_emit_ssid_signal()
  awful.spawn.easy_async_with_shell(get_ssid, function (out)
    awesome.emit_signal('network::ssid', out:gsub('\n', ''))
  end)
end

function network.toggle()
  awful.spawn.easy_async('bash ' .. configuration_dir .. 'scripts/toggle-network.sh', function ()
    network.re_emit_connected_signal()
    network.re_emit_ssid_signal()
  end)
end

gears.timer {
  timeout = 2,
  call_now = true,
  autostart = true,
  callback = network.re_emit_connected_signal
}

gears.timer {
  timeout = 2,
  call_now = true,
  autostart = true,
  callback = network.re_emit_ssid_signal
}

return network
