-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Widget and layout library
local wibox = require("wibox")

local naughty = require("naughty")

local M = {}

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ Modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ Modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)
local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

---Create a configuration for all screens
---@param tags table
M.init = function(tags)
	awful.screen.connect_for_each_screen(function(s)
		-- Wallpaper
		-- set_wallpaper(s)

		-- Each screen has its own tag table.
		-- awful.tag(tags(s.index), s, awful.layout.layouts[1])
		if s.index == 1 then
			for _, tag in ipairs(tags) do
				awful.tag.add(tag.label, {
					screen = s,
					layout = tag.layout,
					layouts = tag.layouts,
				})
			end
			s.tags[1]:view_only()
		elseif s.index == 2 then
			t = awful.tag.find_by_name(nil, "7-term")
			t.screen = s
			t:view_only()
		elseif s.index == 3 then
			t = awful.tag.find_by_name(nil, "6-slack")
			t.screen = s
			t:view_only()
		end

		-- Create a promptbox for each screen
		s.mypromptbox = awful.widget.prompt()
		-- Create an imagebox widget which will contain an icon indicating which layout we're using.
		-- We need one layoutbox per screen.
		s.mylayoutbox = awful.widget.layoutbox(s)
		s.mylayoutbox:buttons(gears.table.join(
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 4, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 5, function()
				awful.layout.inc(-1)
			end)
		))
		-- Create a taglist widget
		s.mytaglist = awful.widget.taglist({
			screen = s,
			filter = awful.widget.taglist.filter.noempty,
			buttons = taglist_buttons,
		})

		-- Create a tasklist widget
		s.mytasklist = awful.widget.tasklist({
			screen = s,
			filter = awful.widget.tasklist.filter.currenttags,
			buttons = tasklist_buttons,
		})

		-- Create the wibox
		s.mywibox = awful.wibar({ position = "top", screen = s })

		-- Add widgets to the wibox
		s.mywibox:setup({
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				mylauncher,
				s.mytaglist,
				s.mypromptbox,
			},
			s.mytasklist, -- Middle widget
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				mykeyboardlayout,
				wibox.widget.systray(),
				mytextclock,
				s.mylayoutbox,
			},
		})
	end)
end

M.global_mapping = function()
	local keys = {}
	-- Move to first tag of specific screen
	for i = 2, 4 do
		keys = gears.table.join(
			keys,
			awful.key({ Modkey, "Control" }, i, function()
				awful.screen.focus(screen[i - 1])
			end, { description = "focus on " .. i - 1 .. " screen", group = "screen" })
		)
	end

	keys = gears.table.join(
		keys,
		awful.key({ Modkey }, "k", function()
			awful.screen.focus_relative(1)
		end, { description = "focus the next screen", group = "screen" }),
		awful.key({ Modkey }, "j", function()
			awful.screen.focus_relative(-1)
		end, { description = "focus the previous screen", group = "screen" })
	)

	return keys
end

return M
