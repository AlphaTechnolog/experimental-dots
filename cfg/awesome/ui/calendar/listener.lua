local awful = require 'awful'

local _ = function ()
	return awful.screen.focused().calendar
end

-- request for toggling popup
awesome.connect_signal('calendar::toggle', function ()
	_().toggle()
end)
