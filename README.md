# Biome Modifiers Patch
This mod adds settings to the biome modifiers as well as making it possible to append to biome modifiers.

## What it does
The patch itself modifies the game's `data/scripts/init.lua` in order to make it detect modifications in `data/scripts/biome_modifiers.lua`. You can find the details in the [`patch file`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/biome_modifiers_patch/init_biome_modifiers_patcher.lua).

## How to apply the patch in your own mod
You can either add this mod as a dependency or apply the patch yourself.  
To apply the patch manually, see the manual below.  
<details><summary><b>Manual</b></summary>

There are two modules in this patch - one for patching the games `init.lua`, and one is a rewrite to biome modifiers. The rewrite is optional, but it simplifies the work with biome modifiers so it's highly recommended.

<details><summary>init.lua</summary><blockquote>

To patch games `init.lua` you will need to put the [`patch file`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/biome_modifiers_patch/init_biome_modifiers_patcher.lua) in your mods folder and add following code in your `settings.lua`


```lua
local function patch_games_init_lua() --patching vanilla's init.lua, we are doing it here since this file loads before any mods
	local file = "data/scripts/init.lua"
	local patch = "mods/biome_modifiers_patch/files/biome_modifiers_patch/init_biome_modifiers_patcher.lua"
	ModLuaFileAppend(file, patch)
end
```

Don't forget to change `patch` path.
<br>

And add `if init_scope == 0 or init_scope == 1 then patch_games_init_lua() end` line in `ModSettingsUpdate` function:


```lua
function ModSettingsUpdate(init_scope)
	if init_scope == 0 or init_scope == 1 then patch_games_init_lua() end --this line
end
```

</blockquote></details>

<details><summary>biome modifiers rewrite</summary><blockquote>

To add biome modifiers rewrite to your mod - simply put the [`rewrite file`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/biome_modifiers_patch/biome_modifiers_rewrite.lua) in your mods folder and add following code in your `init.lua`

```lua
ModLuaFileAppend("data/scripts/biome_modifiers.lua", "mods/biome_modifiers_patch/files/biome_modifiers_patch/biome_modifiers_rewrite.lua")
```

Don't forget to change path.
</blockquote></details>

## How to append to modifiers
See [`append file`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/biome_modifiers_append.lua) and [`init.lua`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/init.lua) for examples.  
Simply use `ModLuaFileAppend` to append your changes to `data/scripts/biome_modifiers.lua`.

## Biome Modifiers Rewrite
The [`biome modifiers rewrite`](https://github.com/lamia-zamia/biome_modifiers_patch/blob/main/files/biome_modifiers_patch/biome_modifiers_rewrite.lua) rewrites some functions for it to be easily customizable, mainly via table appends.

Changes:

- biomes

	Biome names can now be either a biome name (`data/biomes/BIOME_NAME.xml`) or a fullpath to xml file.
	To be more specific - here is the change:

	```lua
	local biome_filename = biome_name:find("%.xml$") and biome_name or string.format("data/biome/%s.xml", biome_name)
	```

	Examples:

	```lua
	biomes[#biomes + 1] = {"my_cool_biome1"}
	table.insert(biomes, {"mods/files/biomes/my_cool_biome2.xml"})
	```

New tables:

- CHANCES_OF_MODIFIERS_BIOME_SPECIFIC
	```lua
	CHANCES_OF_MODIFIERS_BIOME_SPECIFIC = {
		["coalmine"] = 0.2,
		["excavationsite"] = 0.2,
	}
	```
	Allows to override global probability for specific biomes
	
	Examples:

	```lua
	CHANCES_OF_MODIFIERS_BIOME_SPECIFIC["snowcave"] = 1
	CHANCES_OF_MODIFIERS_BIOME_SPECIFIC["mods/files/biomes/my_cool_biome2.xml"] = 2 -- always
	CHANCES_OF_MODIFIERS_BIOME_SPECIFIC["coalmine"] = -1 -- never
	```

- BIOME_MODIFIERS_STATIC_MAP
	```lua
	BIOME_MODIFIERS_STATIC_MAP = {
		fungicave = { modifier = "MOIST", probability = 0.5 },
		mountain_top = "FREEZING",
		mountain_floating_island = "FREEZING",
		winter = "FREEZING"
	}
	```
	Allows to map modifiers that will always appear in a specific biome.
	Can be either a string of modifier id or a table with `modifier = "MODIFIER_ID", probability = 0.5` format for a chance to apply. It will only be applied if no other modifiers were applied before.

	Examples:
	```lua
	BIOME_MODIFIERS_STATIC_MAP[#BIOME_MODIFIERS_STATIC_MAP + 1] = {
		coalmine = "HOT",
		["mods/files/biomes/my_cool_biome2.xml"] = "MOIST"
	}
	```