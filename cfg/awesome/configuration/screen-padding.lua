screen.connect_signal("request::desktop_decoration", function (s)
	screen[s].padding = { left = 0, right = 0, top = 0, bottom = 0 }
end)
