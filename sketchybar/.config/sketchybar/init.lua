require("globals")
-- Build the AX menu helper (menus, control center) and the calendar
-- helper: make is a no-op when the binary is up to date.
os.execute('cd "$CONFIG_DIR/helpers/menus" && make >/dev/null 2>&1')
os.execute('cd "$CONFIG_DIR/helpers/events" && make >/dev/null 2>&1')

local separator_module = require("items.separator")

-- Left Side
require("items.menus")
separator_module.create("menu_separator")
require("items.spaces")
separator_module.create("resources_separator")
require("items.resources")

-- Right Side (Order: Right -> Left)
-- An invisible anchor at the right pill's far end for the month view:
-- right items lay out in the order they are added, so it must come
-- first. (A `--move` at load runs before the items exist.)
CAL_VIEW_ANCHOR = SBAR.add("item", "cal.view.anchor", {
	position = "right",
	width = 0,
	padding_left = 0,
	padding_right = 0,
	icon = { drawing = false },
	label = { drawing = false },
})
require("items.theme_picker")
require("items.calendar")
require("items.next_event")
require("items.control_center")
require("items.battery")
require("items.devices")
require("items.volume")
require("items.pomodoro")

SBAR.add("bracket", "right.bracket", { "theme_picker", "pomodoro" }, { background = { drawing = true } })
