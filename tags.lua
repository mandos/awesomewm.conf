local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")

local M = {}

local term_layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.max,
}

local app_layouts = {
	awful.layout.suit.max,
}

M.tags = {
	{ label = "1-app", key = 1, layouts = app_layouts, layout = app_layouts[1] },
	{ label = "2-web", key = 2, layouts = app_layouts, layout = app_layouts[1] },
	{ label = "3-term", key = 3, layouts = term_layouts, layout = term_layouts[1] },
	{ label = "4-term", key = 4, layouts = term_layouts, layout = term_layouts[1] },
	{ label = "6-slack", key = 6, layouts = app_layouts, layout = app_layouts[1] },
	{ label = "5-app", key = 5, layouts = app_layouts, layout = app_layouts[1] },
	{ label = "7-term", key = 7, layouts = term_layouts, layout = term_layouts[1] },
	{ label = "8-term", key = 8, layouts = term_layouts, layout = term_layouts[1] },
	{ label = "9-web", key = 9, layouts = app_layouts, layout = app_layouts[1] },
	{ label = "0-emacs", key = 0, layouts = app_layouts, layout = app_layouts[1] },
}

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
	for _, tag in pairs(M.tags) do
		keys = gears.table.join(
			keys,
			awful.key({ Modkey }, tag.key, function()
				local curr_tag = awful.screen.focused().selected_tag
				local with_tag = awful.tag.find_by_name(nil, tag.label)
				if curr_tag == with_tag then
					return
				end
				-- keep information if with_tag is selected, so I can keep it for current tag after swap
				local selected = with_tag.selected
				with_tag:swap(curr_tag)
				if selected then
					curr_tag:view_only()
				else
					curr_tag.selected = false
				end
				awful.screen.focus(with_tag.screen)
				with_tag:view_only()
			end, { description = "swap tag with " .. tag.label, group = "tag" }),
			awful.key({ Modkey, "Shift" }, tag.key, function()
				if client.focus then
					local tag = awful.tag.find_by_name(nil, tag.label)
					if tag then
						client.focus:move_to_tag(tag)
						tag:view_only()
					end
				end
			end, { description = "move client to " .. tag.label, group = "tag" })
		)
	end
	return keys
end

return M
