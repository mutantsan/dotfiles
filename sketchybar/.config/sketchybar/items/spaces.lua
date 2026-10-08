local icon_map = require("helpers.icon_map")

-- ==========================================================
-- AEROSPACE WORKSPACES
-- Every workspace, then the focused app. AeroSpace never triggers sketchybar events on its own: the
-- exec-on-workspace-change and on-focus-changed hooks in
-- aerospace.toml run `sketchybar --trigger aerospace_...`.
-- ==========================================================
-- ==========================================================
-- STATE
-- ==========================================================
local spaces_store = {}
local space_item_list = {}
local workspace_names = {}
local current_focused_workspace = nil
local is_app_focused = false

do
	local handle = io.popen("aerospace list-workspaces --all 2>/dev/null")
	if handle then
		for name in handle:lines() do
			if name ~= "" then
				table.insert(workspace_names, name)
			end
		end
		handle:close()
	end
end

-- Self-heal: on a cold start sketchybar can load before AeroSpace
-- answers, so there are no workspaces to draw. Poll until it does,
-- then reload once.
if #workspace_names == 0 then
	local watchdog = SBAR.add("item", { drawing = false, updates = true, update_freq = 2 })
	watchdog:subscribe("routine", function()
		SBAR.exec("aerospace list-workspaces --all >/dev/null 2>&1 && sketchybar --reload")
	end)
	SBAR.add("event", "fade_in_spaces")
	SBAR.add("event", "fade_out_spaces")
	return
end

-- ==========================================================
-- INITIALIZE SPACES VISUALLY
-- ==========================================================
for _, workspace_id in ipairs(workspace_names) do
	local space = SBAR.add("item", "space." .. workspace_id, {
		position = "left",
		icon = { string = workspace_id, color = COLORS.disabled_color },
		label = { drawing = false },
		drawing = true,
	})

	table.insert(space_item_list, space.name)

	spaces_store[workspace_id] = { item = space }

	local function on_click()
		SBAR.exec("aerospace workspace '" .. workspace_id .. "'")
	end

	space:subscribe("mouse.clicked", on_click)

	local function on_hover(env)
		if not APPLICATION_MENU_COLLAPSED then
			return
		end
		local is_entering = (env.SENDER == "mouse.entered")
		local is_this_focused = (workspace_id == current_focused_workspace)
		if not is_this_focused then
			local color = is_entering and COLORS.accent_color or COLORS.disabled_color
			space:set({
				icon = { color = color },
			})
		end
	end

	space:subscribe({ "mouse.entered", "mouse.exited" }, on_hover)

end

-- ==========================================================
-- SPACE SEPARATOR
-- ==========================================================
local space_separator = SBAR.add("item", "space_separator", {
	position = "left",
	label = { drawing = false },
	icon = {
		string = "|",
		padding_left = 0,
		padding_right = DEFAULT_ITEM.icon.padding_right,
	},
})

table.insert(space_item_list, space_separator.name)

-- ==========================================================
-- FRONT APP
-- ==========================================================
local front_app = SBAR.add("item", "front_app", {
	position = "left",
	icon = {
		font = { family = "sketchybar-app-font", style = "Regular", size = DEFAULT_ITEM.icon.font.size * 1.1 },
		padding_right = DEFAULT_ITEM.icon.padding_right * 0.5,
		padding_left = DEFAULT_ITEM.icon.padding_left * 0.5,
	},
	label = { font = { size = DEFAULT_ITEM.label.font.size * 1.1 } },
	drawing = false,
})

table.insert(space_item_list, front_app.name)

-- ==========================================================
-- BRACKET CREATION
-- ==========================================================
local spaces_bracket = SBAR.add("bracket", "spaces.bracket", space_item_list, {
	background = { drawing = true },
})

-- ==========================================================
-- UPDATE MANAGEMENT
-- ==========================================================
-- One read of the whole state: the focused workspace, then the
-- focused window's app.
local state_command = "aerospace list-workspaces --focused 2>/dev/null; echo '---'; "
	.. "aerospace list-windows --focused --format '%{app-name}' 2>/dev/null"

local function render(result)
	if type(result) ~= "string" then
		return
	end
	local active_space, active_app_name = result:match("^%s*([^\n]*)\n%-%-%-\n?([^\n]*)")
	if not active_space or active_space == "" then
		return
	end

	current_focused_workspace = active_space
	for _, ws_name in ipairs(workspace_names) do
		local is_focused = (ws_name == active_space)
		spaces_store[ws_name].item:set({
			icon = { color = is_focused and COLORS.accent_color or COLORS.disabled_color },
		})
	end

	-- Update front focused app
	is_app_focused = (active_app_name ~= "")
	if is_app_focused then
		front_app:set({
			drawing = APPLICATION_MENU_COLLAPSED,
			icon = { string = icon_map[active_app_name] or icon_map["Default"] or ":default:" },
			label = { string = active_app_name },
		})
		if APPLICATION_MENU_COLLAPSED then
			space_separator:set({ drawing = true })
		end
	else
		front_app:set({ drawing = false })
		space_separator:set({ drawing = false })
	end
end

-- Events arrive in bursts (a workspace switch also moves the focus):
-- one read at a time, and one more afterwards if anything came in
-- meanwhile, so the bar always ends on the latest state.
local busy, again = false, false
local function update_spaces()
	if busy then
		again = true
		return
	end
	busy = true
	SBAR.exec(state_command, function(result)
		busy = false
		render(result)
		if again then
			again = false
			update_spaces()
		end
	end)
end

SBAR.add("event", "aerospace_workspace_change")
SBAR.add("event", "aerospace_focus_change")

local event_item = SBAR.add("item", { drawing = false, updates = true })
event_item:subscribe({
	"aerospace_workspace_change",
	"aerospace_focus_change",
	"front_app_switched",
	"space_windows_change",
	"system_woke",
}, function()
	update_spaces()
end)

-- Initial update
update_spaces()

THEME.on_change(update_spaces)

-- ==========================================================
-- SWAP CONTROLLER (Curtain / Fade Effect)
-- ==========================================================
local swap_manager = SBAR.add("item", { drawing = false, updates = true })

SBAR.add("event", "fade_in_spaces")
SBAR.add("event", "fade_out_spaces")

swap_manager:subscribe("fade_in_spaces", function()
	-- Reset widths/colors first to 0
	for _, data in pairs(spaces_store) do
		data.item:set({ width = 0, icon = { color = COLORS.transparent }, label = { color = COLORS.transparent } })
	end
	if is_app_focused then
		front_app:set({ width = 0, icon = { color = COLORS.transparent }, label = { color = COLORS.transparent } })
	end

	-- Animate in
	SBAR.animate("tanh", APPLICATION_MENU_TRANSITION_FRAMES, function()
		spaces_bracket:set({ background = { drawing = true } })

		for id, data in pairs(spaces_store) do
			local color = (id == current_focused_workspace) and COLORS.accent_color or COLORS.disabled_color
			data.item:set({ width = "dynamic", icon = { color = color }, label = { color = color } })
		end

		space_separator:set({ drawing = is_app_focused })

		if is_app_focused then
			front_app:set({
				width = "dynamic",
				icon = { color = COLORS.text_color },
				label = { color = COLORS.text_color },
			})
		end
	end)
end)

swap_manager:subscribe("fade_out_spaces", function()
	SBAR.animate("tanh", APPLICATION_MENU_TRANSITION_FRAMES, function()
		spaces_bracket:set({ background = { drawing = false } })

		for _, data in pairs(spaces_store) do
			data.item:set({
				width = 0,
				icon = { color = COLORS.transparent },
				label = { color = COLORS.transparent },
			})
		end

		space_separator:set({ drawing = false })
		front_app:set({ width = 0, icon = { color = COLORS.transparent }, label = { color = COLORS.transparent } })
	end)
end)
