-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Theme handling library
local beautiful = require("beautiful")

local M = {}

mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = mymainmenu,
})

M.global_mapping = function(menubar)
	return gears.table.join(
		awful.key({ Modkey }, "Return", function()
			awful.spawn(terminal)
		end, { description = "open a terminal", group = "launcher" }),
		-- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
		--           {description = "run prompt", group = "launcher"}),
		awful.key({ Modkey }, "r", function()
			awful.util.spawn(
				"rofi -combi-modi run,ssh,drun -terminal alacritty -show-icons -matching fuzzy -show combi -modi combi"
			)
		end, { description = "launcher for programs", group = "launcher" }),
		awful.key({ Modkey }, "w", function()
			awful.util.spawn("rofi -combi-modi window -matching fuzzy -window-match-fields all -show combi -modi combi")
		end, { description = "windows picker", group = "launcher" }),
		awful.key({ Modkey }, "z", function()
			menubar.show()
		end, { description = "show the menubar", group = "launcher" })
	)
end

return M
