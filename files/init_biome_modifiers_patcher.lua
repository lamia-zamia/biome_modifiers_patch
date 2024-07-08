--[[
Original function is below:

function OnBiomeConfigLoaded()
	init_biome_modifiers()
end

The problem is that data/scripts/init.lua does dofile_once( "data/scripts/biome_modifiers.lua") at the very beginning,
causing the game to not see the modifications to biome_modifiers.lua.
By replacing OnBiomeConfigLoaded and adding loadfile we force the game to update the content of biome_modifiers.lua.

You will need to add this file into your mods folder and the following functions to the settings.lua
(Why settings.lua? Because it's executed before init.lua, and yes, even before the game's data/scripts/init.lua)
Don't forget to change YOUR_PATH_TO_PATCH.

@@
local patch_needed = true
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
		local patch = "mods/YOUR_PATH_TO_PATCH/init_biome_modifiers_patcher.lua"
		if CheckForPatchGamesInitlua(file, patch) then ModLuaFileAppend(file, patch) end
		patch_needed = false
	end
end
@@

Note that this function uses "mod_id", so this function should be put below your "local mod_id = YOUR_MOD_HERE"

And add following line into your "function ModSettingsUpdate(init_scope)":

@@
if patch_needed then PatchGamesInitlua() end
@@

So by default it should look like this:
@@
function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id)
	mod_settings_update(mod_id, mod_settings, init_scope)
	if patch_needed then PatchGamesInitlua() end
end
@@

Please note that the patch file should be named "init_biome_modifiers_patcher.lua" in order to not append it several times if different mods are using it.
It won't break anything, but it's just not nice.
]]
function OnBiomeConfigLoaded()
	local f, err = loadfile("data/scripts/biome_modifiers.lua")
	if not f then
		print("Error during reading data/scripts/biome_modifiers.lua: " .. err)
		return nil
	end
	init_biome_modifiers = f()
	init_biome_modifiers()
end
