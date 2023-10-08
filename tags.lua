local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")

local M = {}

local screen_1 = 1
local screen_2 = 2
local screen_3 = 3
local custom_tags = {
	{ label = "1-app", key = 1, screen = screen_1 },
	{ label = "2-term", key = 2, screen = screen_1 },
	{ label = "3-term", key = 3, screen = screen_1 },
	{ label = "4-app", key = 4, screen = screen_1 },
	{ label = "6-slack", key = 6, screen = screen_3 },
	{ label = "5-app", key = 5, screen = screen_3 },
	{ label = "7-web", key = 7, screen = screen_2 },
	{ label = "8-term", key = 8, screen = screen_2 },
	{ label = "9-term", key = 9, screen = screen_2 },
	{ label = "0-emacs", key = 0, screen = screen_2 },
}

M.tags = function() end

M.get_screen_tags = function(screen_nr)
	local tags = {}
	for _, v in pairs(custom_tags) do
		if v.screen == screen_nr then
			table.insert(tags, #tags + 1, v.label)
		end
	end
	return tags
end

M.get_all_tags = function()
	local tags = {}
	for _, v in pairs(custom_tags) do
		tags[v.key] = v.label
	end
	return tags
end

M.global_mapping = function()
	local keys = {}

	keys = gears.table.join(
		awful.key({ Modkey, "Control" }, "p", function()
			local src_screen = awful.screen.focused()
			local src_tag = src_screen.selected_tag
			awful.screen.focus_relative(-1)
			local dst_screen = awful.screen.focused()
			local dst_tag = dst_screen.tags[1]
			dst_tag:swap(src_tag)
			dst_tag:view_only()
			src_tag:view_only()
		end, { description = "Move tag to previous screen", group = "tag" }),
		awful.key({ Modkey, "Control" }, "n", function()
			local src_screen = awful.screen.focused()
			local src_tag = src_screen.selected_tag
			awful.screen.focus_relative(1)
			local dst_screen = awful.screen.focused()
			local dst_tag = dst_screen.tags[1]
			dst_tag:swap(src_tag)
			dst_tag:view_only()
			src_tag:view_only()
		end, { description = "Move tag to next screen", group = "tag" }),
		awful.key({ Modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" })
	)

	return keys
end

M.mapping = function()
	local keys = {}
	for key, label in pairs(M.get_all_tags()) do
		keys = gears.table.join(
			keys,
			awful.key({ Modkey }, key, function()
				local from_tag = awful.screen.focused().selected_tag
				local to_tag = awful.tag.find_by_name(nil, label)
				if from_tag == to_tag then
					return
				end

				if from_tag and to_tag then
					-- Move slack to the beginning of the last monitor
					if from_tag.name == "6-slack" then
						local last_tag = screen[3].tags[1]
						from_tag:swap(last_tag)
						from_tag:view_only()
						from_tag = last_tag
					end
					from_tag:swap(to_tag)
					if from_tag.index == 1 then
						from_tag:view_only()
					else
						-- Swap leave selection so I need to manually unselected the tag
						from_tag.selected = false
					end
					to_tag:view_only()
					-- naughty.notify({ text = "Swapped " .. from_tag.index .. " with " .. to_tag.index })
				end
			end, { description = "swap tag with " .. label, group = "tag" }),
			awful.key({ Modkey, "Shift" }, key, function()
				if client.focus then
					local tag = awful.tag.find_by_name(nil, label)
					if tag then
						client.focus:move_to_tag(tag)
						tag:view_only()
					end
				end
			end, { description = "move client to" .. label, group = "tag" })
		)
	end
	return keys
end

return M
