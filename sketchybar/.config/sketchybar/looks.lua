-- The look: colours and fonts. Global LOOK (alias COLORS).
local colors = {}
local config_dir = os.getenv("CONFIG_DIR")
local theme_file = config_dir .. "/helpers/active_theme.txt"

-- Create the directory once when the script loads if not available yet
os.execute("mkdir -p " .. config_dir .. "/helpers")

-- 1. Define Common Colors
colors.white = 0xffffffff
colors.transparent = 0x00000000
colors.red = 0xffff4444
colors.orange = 0xffffa500
colors.charging = 0xffffd700

-- 2. Define Your Schemes
local schemes = {
	gruvbox = {
		font = "Charter", -- words (numbers and icons stay Hack)
		bar_color = 0x70282828,
		accent_color = 0xffd79921,
		secondary_accent = 0xfffabd2f,
		space_focused_window = 0xff83a598, -- Gruvbox aqua: separates from the yellow accent for red-green colour vision
		disabled_color = 0xffd3d3d3,
		background = 0xfa1e1e2e,
		background_border = 0xff45475a,
		popup_background = 0xff282828,
		popup_border = 0xffd79921,
	},
	teal = {
		font = "PT Sans", -- words (numbers and icons stay Hack)
		bar_color = 0x40001f30,
		accent_color = 0xfa001f30,
		secondary_accent = 0xff397d89,
		space_focused_window = 0xff2cf9ed, -- Cyan/Teal highlight
		disabled_color = 0xff397d89,
		background = 0xff2cf9ed,
		background_border = 0xfa001f30,
		popup_background = 0xff2cf9ed,
		popup_border = 0xfa001f30,
	},
	blacknwhite = {
		font = "Helvetica Neue", -- words (numbers and icons stay Hack)
		bar_color = 0x40000000,
		accent_color = 0xffffffff,
		secondary_accent = 0xffa9cce3,
		space_focused_window = 0xff00d2ff, -- Electric blue highlight
		disabled_color = 0xffb0b0b0,
		background = 0xfa101314,
		background_border = 0xffffffff,
		popup_background = 0xff101314,
		popup_border = 0xffffffff,
	},
	purple = {
		font = "SF Pro Rounded", -- words (numbers and icons stay Hack)
		bar_color = 0x70140c42,
		accent_color = 0xffeb46f9,
		secondary_accent = 0xffa569bd,
		space_focused_window = 0xff00f3ff, -- Neon cyan highlight
		disabled_color = 0xffb8a1d9,
		background = 0xfa140c42,
		background_border = 0xff2e2a5a,
		popup_background = 0xff140c42,
		popup_border = 0xffeb46f9,
	},
	red = {
		font = "Trebuchet MS", -- words (numbers and icons stay Hack)
		bar_color = 0x7023090e,
		accent_color = 0xffff2453,
		secondary_accent = 0xffc0392b,
		space_focused_window = 0xfff7fc17, -- Neon yellow highlight
		disabled_color = 0xffe1a2a6,
		background = 0xfa23090e,
		background_border = 0xff3c1a22,
		popup_background = 0xff23090e,
		popup_border = 0xffff2453,
	},
	blue = {
		font = "Avenir Next", -- words (numbers and icons stay Hack)
		bar_color = 0x70021254,
		accent_color = 0xff15bdf9,
		secondary_accent = 0xff5dade2,
		space_focused_window = 0xffff7f00, -- Neon orange highlight
		disabled_color = 0xffaac5e0,
		background = 0xfa021254,
		background_border = 0xff223973,
		popup_background = 0xff021254,
		popup_border = 0xff15bdf9,
	},
	green = {
		font = "Gill Sans", -- words (numbers and icons stay Hack)
		bar_color = 0x70003315,
		accent_color = 0xff1dfca1,
		secondary_accent = 0xff52be80,
		space_focused_window = 0xff15bdf9, -- Electric blue highlight
		disabled_color = 0xffa1e0c0,
		background = 0xfa003315,
		background_border = 0xff0f4d2b,
		popup_background = 0xff003315,
		popup_border = 0xff1dfca1,
	},
	orange = {
		font = "Proxima Nova", -- words (numbers and icons stay Hack)
		bar_color = 0x70381c02,
		accent_color = 0xfff97716,
		secondary_accent = 0xffeb984e,
		space_focused_window = 0xff15bdf9, -- Electric cyan highlight
		disabled_color = 0xffe0bfa1,
		background = 0xfa381c02,
		background_border = 0xff4f2e11,
		popup_background = 0xff381c02,
		popup_border = 0xfff97716,
	},
	yellow = {
		font = "SF Compact Text", -- words (numbers and icons stay Hack)
		bar_color = 0x702d2b02,
		accent_color = 0xfff7fc17,
		secondary_accent = 0xfff4d03f,
		space_focused_window = 0xffeb46f9, -- Magenta highlight
		disabled_color = 0xffe9dea1,
		background = 0xfa2d2b02,
		background_border = 0xff4e4b13,
		popup_background = 0xff2d2b02,
		popup_border = 0xfff7fc17,
	},
	liquid_glass = {
		font = "SF Pro", -- words (numbers and icons stay Hack)
		bar_color = 0x00000000,
		-- Plain text white; "on" in True Dark's cyan, which reads on the
		-- glass (4.7:1) and stays apart from the orange front-app
		-- highlight and the attention colours for red-green vision.
		text_color = 0xffffffff,
		accent_color = 0xff64d2ff,
		secondary_accent = 0xffd6eaf8,
		space_focused_window = 0xffff9f0a, -- Apple orange: white vs cyan merged for red-green colour vision
		disabled_color = 0xffc7c7cc, -- light enough to read on glass
		background = 0x20ffffff,
		background_border = 0x40ffffff,
		popup_background = 0xee1a1d1e,
		popup_border = 0x80ffffff,
	},
}

local function with_alpha(value, alpha)
	-- Plain arithmetic, not bitwise operators: stylua's parser in the
	-- pre-commit hook only knows Lua 5.1.
	return value % 0x1000000 + alpha * 0x1000000
end
colors.with_alpha = with_alpha

-- 3. Select Active Scheme
local active_name
local first_available = next(schemes)

local f = io.open(theme_file, "r")
if f then
	local content = f:read("*all"):gsub("%s+", "")
	if schemes[content] then
		active_name = content
	end
	f:close()
end

active_name = active_name or (schemes.liquid_glass and "liquid_glass") or first_available
-- 4. Merge. `colors.use` swaps the active scheme IN PLACE (the same
-- table every module holds as COLORS), so a live theme switch needs
-- no reload: helpers/theme.lua re-applies the colours afterwards.
local scheme_keys = {}
function colors.use(name)
	local data = schemes[name]
	if not data then
		return false
	end
	for k in pairs(scheme_keys) do
		colors[k] = nil
	end
	scheme_keys = {}
	for k, v in pairs(data) do
		colors[k] = v
		scheme_keys[k] = true
	end
	-- Labels and icons read text_color; a scheme without one keeps its
	-- accent, as before.
	if not data.text_color then
		colors.text_color = colors.accent_color
		scheme_keys.text_color = true
	end
	colors.active_scheme_name = name
	if colors.resolve_font then
		colors.resolve_font(data.font)
	end
	return true
end

colors.use(active_name)
colors.all_schemes = schemes
colors.theme_file = theme_file

-- Fonts. Words (titles, names, menu rows) wear the scheme's own
-- font; numbers and icons stay
-- Hack Nerd Font, whose equal-width digits keep readouts from
-- jittering and whose glyphs nothing else has.
colors.icon_font = "Hack Nerd Font"
colors.text_font = colors.icon_font
colors.text_style = "Semibold"

-- Style names vary per family (Apple Chancery's only one is
-- "Chancery", Charter's "Roman"), and sketchybar falls back to the
-- system font on a wrong one, so helpers/fontstyle asks macOS.
-- Nothing back = not installed: stay on Hack.
local fontstyle_dir = config_dir .. "/helpers/fontstyle"
os.execute("cd '" .. fontstyle_dir .. "' && make >/dev/null 2>&1")
local style_cache = {}
local function style_of(family)
	if style_cache[family] == nil then
		local handle = io.popen("'" .. fontstyle_dir .. "/bin/fontstyle' '" .. family:gsub("'", "") .. "' 2>/dev/null")
		local style = handle and handle:read("*l") or ""
		if handle then
			handle:close()
		end
		style_cache[family] = style or ""
	end
	return style_cache[family]
end

-- Sets the word font for the active scheme (called by colors.use).
function colors.resolve_font(family)
	local style = family and style_of(family) or ""
	if style ~= "" then
		colors.text_font, colors.text_style = family, style
	else
		colors.text_font, colors.text_style = colors.icon_font, "Semibold"
	end
end
colors.resolve_font(colors.font)

-- A label font table for words; `scale` multiplies the default size.
function colors.word_font(scale)
	return {
		family = colors.text_font,
		style = colors.text_style,
		size = 13.5 * (scale or 1),
	}
end

return colors
