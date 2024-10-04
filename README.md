# Biome Modifiers Patch
This mod adds settings to the biome modifiers as well as making it possible to append to biome modifiers.

## What it does
The patch itself modifies the game's `data/scripts/init.lua` in order to make it detect modifications in `data/scripts/biome_modifiers.lua`. You can find the details in the [`patch file`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/init_biome_modifiers_patcher.lua).

## How to apply the patch in your own mod
You can either add this mod as a dependency or apply the patch yourself.  
To apply the patch manually, see the manual below.  
<details>

<summary><b>Manual</b></summary>

You will need to put the patch above in your mods folder and add following code in your `settings.lua`
<details>
<summary>settings.lua</summary>

```lua
local function PatchGamesInitlua() --patching vanilla's init.lua, we are doing it here since this file loads before any mods
	local file = "data/scripts/init.lua"
	local patch = "mods/biome_modifiers_patch/files/init_biome_modifiers_patcher.lua"
	local file_appends = ModLuaFileGetAppends(file)
	local strip_pattern = "[^/]*.lua$"

	for _, append in ipairs(file_appends) do
		if append:match(strip_pattern) == "init_biome_modifiers_patcher.lua" then
			return
		end
	end

	ModLuaFileAppend(file, patch)
end
```
</details>  

Don't forget to change `patch` path.
<br>

And add `if init_scope == 0 or init_scope == 1 then PatchGamesInitlua() end` line in `ModSettingsUpdate` function:

<details>
<summary>settings.lua</summary>

```lua
function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id)
	mod_settings_update(mod_id, mod_settings, init_scope)
	if init_scope == 0 or init_scope == 1 then PatchGamesInitlua() end --this line
end
```
</details>

</details>

## How to append to modifiers
See [`lib file`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/lib.lua) and [`init.lua`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/init.lua) for examples.  
The easiest way is to replace `return init_biome_modifiers` with your code and insert `return init_biome_modifiers` back at the end, which is what my lib file does.  
Appends can be done during init, but not later than `OnMagicNumbersAndWorldSeedInitialized` since the game loads `data/scripts/biome_modifiers.lua` during `OnBiomeConfigLoaded`.