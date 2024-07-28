dofile("data/scripts/lib/mod_settings.lua")
local whitebox = "data/debug/whitebox.png"
local virtual_file = "mods/biome_modifiers_patch/defaults.lua"
local patch_needed = true
local settings_needs_to_build = true

local mod_id = "biome_modifiers_patch"
mod_settings_version = 1


local function CheckForPatchGamesInitlua(file, patch) --checking if patch was already applied, file name should be the same between mods
	local file_appends = ModLuaFileGetAppends(file)
	local strip_pattern = "[^/]*.lua$"
	for _, append in ipairs(file_appends) do
		if append:match(strip_pattern) == patch:match(strip_pattern) then
			return false
		end
	end
	return true
end
local function PatchGamesInitlua() --patching vanilla's init.lua, we are doing it here since this file loads before any mods
	if ModIsEnabled(mod_id) then --thats crazy, but it can be used to detect if you are in main menu or not
		local file = "data/scripts/init.lua"
		local patch = "mods/biome_modifiers_patch/files/init_biome_modifiers_patcher.lua"
		if CheckForPatchGamesInitlua(file, patch) then ModLuaFileAppend(file, patch) end
		patch_needed = false
	end
end

local function diplay_text_with_separator(mod_id, gui, in_main_menu, im_id, setting)
	local img_w = GuiGetImageDimensions(gui, whitebox)
	local text_w, text_h = GuiGetTextDimensions(gui, setting.ui_text)
	GuiColorSetForNextWidget(gui, 0.6, 0.6, 0.6, 1)
	GuiImage(gui, im_id, 0, text_h, whitebox, 1, text_w / img_w, 0.04)
	local _, _, _, _, _, _, h = GuiGetPreviousWidgetInfo(gui)
	GuiText(gui, 0, 1 - text_h - h, setting.ui_text)
	GuiText(gui, 0, text_h * -0.75, " ")
end

local function round(value)
	return tonumber(string.format("%.5f", value))
end

local function set_setting(mod_id, setting, value)
	ModSettingSet(mod_setting_get_id(mod_id, setting), value)
	ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), value, false)
end

local function YellowIfHovered(gui, hovered)
	if hovered then GuiColorSetForNextWidget(gui, 1, 1, 0.7, 1) end
end

local function display_toggle_checkbox(mod_id, gui, setting, value, x, y, id)
	local offset_w = GuiGetTextDimensions(gui, "  Disabled  ")
	GuiZSetForNextWidget(gui, -1)
	GuiImageNinePiece(gui, id, x + 2, y + 2, offset_w, 6, 0)
	local clicked, _, hovered = GuiGetPreviousWidgetInfo(gui)
	GuiZSetForNextWidget(gui, 1)
	GuiImageNinePiece(gui, id, x + 2, y + 2, 6, 6)
	if value < 0 then
		GuiColorSetForNextWidget(gui, 0.8, 0, 0, 1)
		GuiText(gui, 0, 0, "X")
		GuiText(gui, 0, 0, " ")
		YellowIfHovered(gui, hovered)
		GuiText(gui, 0, 0, "Disabled")
	else
		GuiColorSetForNextWidget(gui, 0, 0.8, 0, 1)
		GuiText(gui, 0, 0, "V")
		GuiText(gui, 0, 0, " ")
		YellowIfHovered(gui, hovered)
		GuiText(gui, 0, 0, "Enabled")
	end
	if clicked then
		local new_value = value * -1
		if new_value == 0 then new_value = -2 end
		if new_value == 2 then new_value = 0 end
		set_setting(mod_id, setting, new_value)
	end
end

local function display_flag_checkbox(gui, setting, value, id)
	if setting.requires_flag and value > 0 then
		if HasFlagPersistent(setting.requires_flag) then return end
		local _, _, _, x, y, w = GuiGetPreviousWidgetInfo(gui)
		local offset = 4
		x = x + w + offset
		local offset_w = GuiGetTextDimensions(gui, "  Ignore flag  ")
		GuiZSetForNextWidget(gui, -1)
		GuiImageNinePiece(gui, id, x, y + 2, offset_w, 6, 0)
		local clicked, _, hovered = GuiGetPreviousWidgetInfo(gui)
		GuiZSetForNextWidget(gui, 1)
		GuiImageNinePiece(gui, id, x, y + 2, 6, 6)
		local flag_setting = "biome_modifiers_patch.flag_" .. setting.requires_flag
		local flag_setting_value = ModSettingGetNextValue(flag_setting)
		if flag_setting_value then
			GuiColorSetForNextWidget(gui, 0, 0.8, 0, 1)
			GuiText(gui, offset + 1, 0, "V")
			GuiText(gui, 0, 0, " ")
			YellowIfHovered(gui, hovered)
		else
			GuiColorSetForNextWidget(gui, 0.8, 0, 0, 1)
			GuiText(gui, offset + 1, 0, "X")
			GuiText(gui, 0, 0, " ")
			YellowIfHovered(gui, hovered)
			
		end
		GuiText(gui, 0, 0, "Ignore flag")
		if clicked then
			ModSettingSet(flag_setting, not flag_setting_value)
			ModSettingSetNextValue(flag_setting, not flag_setting_value, false)
		end
	end
end

local function display_fake_button(mod_id, gui, id, setting, text, value, set_value)
	local _, _, _, x, y, w = GuiGetPreviousWidgetInfo(gui)
	local width, height = GuiGetTextDimensions(gui, text)
	GuiImageNinePiece(gui, id, x + w, y, width, height, 0)
	local clicked, _, hovered = GuiGetPreviousWidgetInfo(gui)
	if value == set_value then
		GuiColorSetForNextWidget(gui, 0.7, 0.7, 0.7, 1)
	else
		YellowIfHovered(gui, hovered)
		if clicked then
			GamePlaySound("ui", "ui/button_click", 0, 0)
			set_setting(mod_id, setting, round(set_value))
		end
	end
	GuiText(gui, 0, 0, text)
end

local function display_modifiers_fancy(mod_id, gui, in_main_menu, im_id, setting)
	local gui_id = setting.gui_id
	local function id()
		gui_id = gui_id + 1
		return gui_id
	end
	local value = tonumber(ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))) or 0
	local offset_w, offset_h = GuiGetTextDimensions(gui, " 0.00000 ")
	GuiText(gui, mod_setting_group_x_offset, 0, " ")
	GuiLayoutBeginHorizontal(gui, 3, 0, false, 0, 0)
	if value < 0 then GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1) end
	GuiText(gui, 0, 0, setting.ui_description)
	local _, _, _, gui_x, gui_y, gui_w, gui_h = GuiGetPreviousWidgetInfo(gui)
	GuiZSetForNextWidget(gui, 1)
	GuiImageNinePiece(gui, id(), gui_x, gui_y, gui_w, gui_h, 1, setting.graphics)
	GuiText(gui, offset_w / 1.5, 0, " ")
	_, _, _, gui_x = GuiGetPreviousWidgetInfo(gui)
	display_toggle_checkbox(mod_id, gui, setting, value, gui_x, gui_y, id())
	display_flag_checkbox(gui, setting, value, id())
	GuiLayoutEnd(gui)
	if value < 0 then
		GuiText(gui, 0, 0, " ")
		return
	end
	GuiLayoutBeginHorizontal(gui, 0, offset_h, true, 0, 0)
	local value_new = round(GuiSlider(gui, id(), 0, 0, "", value, setting.value_min, setting.value_max,
		setting.value_default,
		100000, " ", 64))
	GuiText(gui, 0, 0, " " .. tostring(round(value)))
	GuiLayoutEnd(gui)
	GuiLayoutBeginHorizontal(gui, offset_w + 64, 0, true, 0, 0)
	GuiText(gui, 0, 0, "")
	display_fake_button(mod_id, gui, id(), setting, "[rare]", value, 0.2)
	display_fake_button(mod_id, gui, id(), setting, "[average]", value, 0.6)
	display_fake_button(mod_id, gui, id(), setting, "[often]", value, 1.0)
	display_fake_button(mod_id, gui, id(), setting, "[default]", value, setting.value_default)
	GuiLayoutEnd(gui)
	if value ~= value_new then
		set_setting(mod_id, setting, value_new)
	end
end

local function display_modifiers_simple(mod_id, gui, in_main_menu, im_id, setting)
	GuiLayoutAddVerticalSpacing(gui, 6)
	local gui_id = setting.gui_id
	local function id()
		gui_id = gui_id + 1
		return gui_id
	end
	local value = tonumber(ModSettingGetNextValue(mod_setting_get_id(mod_id, setting))) or 0
	GuiLayoutBeginHorizontal(gui, mod_setting_group_x_offset, 0, true, 0, 0)
	if value < 0 then GuiColorSetForNextWidget(gui, 0.5, 0.5, 0.5, 1) end
	GuiText(gui, 0, 0, setting.ui_description)
	GuiTooltip(gui, "id: " .. setting.id, "")
	GuiText(gui, 10, 0, " ")
	local _, _, _, gui_x, gui_y = GuiGetPreviousWidgetInfo(gui)
	display_toggle_checkbox(mod_id, gui, setting, value, gui_x, gui_y, id())
	display_flag_checkbox(gui, setting, value, id())
	GuiLayoutEnd(gui)
	if value < 0 then
		return
	end
	GuiLayoutBeginHorizontal(gui, 0, 0, true, 0, 0)
	local value_new = round(GuiSlider(gui, id(), 0, 0, "", value, setting.value_min, setting.value_max,
		setting.value_default,
		100000, " ", 64))
	GuiText(gui, 0, 0, " " .. tostring(round(value)))
	GuiText(gui, 10, 0, " ")
	display_fake_button(mod_id, gui, id(), setting, "[rare]", value, 0.2)
	display_fake_button(mod_id, gui, id(), setting, "[average]", value, 0.6)
	display_fake_button(mod_id, gui, id(), setting, "[often]", value, 1.0)
	display_fake_button(mod_id, gui, id(), setting, "[default]", value, setting.value_default)
	GuiLayoutEnd(gui)
	if value ~= value_new then
		set_setting(mod_id, setting, value_new)
	end
end

local function get_modifiers_id()
	for i, setting in ipairs(mod_settings) do
		if setting.category_id and setting.category_id == "modifiers" then
			return i
		end
	end
end

local function reset_probabilities(mod_id)
	local biome_modifiers = dofile_once(virtual_file)
	for i, modifier in ipairs(biome_modifiers) do
		set_setting(mod_id, modifier, modifier.probability)
	end
end

local function display_reset(mod_id, gui, in_main_menu, im_id, setting)
	if GuiButton(gui, im_id, mod_setting_group_x_offset, 0, setting.ui_text) then
		reset_probabilities(mod_id)
	end
end

local function BuildSettings()
	local settings_id = get_modifiers_id()
	local settings_ui = display_modifiers_simple
	mod_settings[settings_id].settings = {}
	if ModSettingGetNextValue("biome_modifiers_patch.probability") == "-1" then
		mod_settings[settings_id].settings[#mod_settings[settings_id].settings + 1] = {
			ui_fn = diplay_text_with_separator,
			ui_text = "The biome modifier setting is set to never",
			not_setting = true,
		}
		mod_settings[settings_id + 1] = {}
		settings_needs_to_build = false
		return
	end
	if ModSettingGet("biome_modifiers_patch.settings_ui") == "fancy" then settings_ui = display_modifiers_fancy end
	if ModDoesFileExist(virtual_file) then
		mod_settings[settings_id].settings[#mod_settings[settings_id].settings + 1] = {
			ui_fn = diplay_text_with_separator,
			ui_text = "All of the following settings apply only in a new game",
			not_setting = true,
		}
		local biome_modifiers = dofile_once(virtual_file)
		for i, modifier in ipairs(biome_modifiers) do
			local index = #mod_settings[settings_id].settings + 1
			mod_settings[settings_id].settings[index] = {
				id = modifier.id,
				ui_description = modifier.ui_description,
				value_default = modifier.probability,
				value_min = 0,
				value_max = 1,
				graphics = modifier.ui_decoration_file,
				gui_id = 10 * i,
				scope = MOD_SETTING_SCOPE_NEW_GAME,
				ui_fn = settings_ui
			}
			if modifier.requires_flag ~= "nil" then
				mod_settings[settings_id].settings[index].requires_flag = modifier.requires_flag
			end
		end
		mod_settings[settings_id + 1] = {
			category_id = "reset_cat",
			ui_name = "Reset settings",
			foldable = true,
			_folded = true,
			settings =
			{
				{
					id = "reset_setting",
					not_setting = true,
					ui_text = "Reset settings",
					ui_fn = display_reset,
				},
			},
		}
		settings_needs_to_build = false
	else
		mod_settings[settings_id].settings[#mod_settings[settings_id].settings + 1] = {
			ui_fn = diplay_text_with_separator,
			ui_text = "Please load the game to see settings",
			not_setting = true,
		}
		mod_settings[settings_id + 1] = {}
		settings_needs_to_build = false
	end
end

mod_settings =
{
	{
		id = "probability",
		ui_name = "Modifier Probability",
		ui_description = "How often will you see biome modifiers",
		value_default = "0",
		values = { { "0", "Default" }, { "2", "Always" }, { "-1", "Never" } },
		scope = MOD_SETTING_SCOPE_NEW_GAME,
		change_fn = function() settings_needs_to_build = not settings_needs_to_build end,
	},
	{
		id = "settings_ui",
		ui_name = "Settings Style",
		value_default = "true",
		values = { { "fancy", "Fancy" }, { "simple", "Simple" } },
		scope = MOD_SETTING_SCOPE_RUNTIME,
		change_fn = function() settings_needs_to_build = not settings_needs_to_build end,
	},
	{
		category_id = "modifiers",
		ui_name = "Modifiers",
		ui_description = "Individual modifier probabilities",
		foldable = true,
		_folded = true,
		settings = {},
	},
}

function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id)
	mod_settings_update(mod_id, mod_settings, init_scope)
	if patch_needed then PatchGamesInitlua() end
	if settings_needs_to_build then BuildSettings() end
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
