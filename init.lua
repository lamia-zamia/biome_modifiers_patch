-- hello

ModLuaFileAppend("data/scripts/biome_modifiers.lua", "mods/biome_modifiers_patch/files/biome_modifiers_patch/biome_modifiers_rewrite.lua")

-- blah
function OnMagicNumbersAndWorldSeedInitialized()
	dofile_once("mods/biome_modifiers_patch/files/biome_modifiers_get_default.lua")
	ModLuaFileAppend("data/scripts/biome_modifiers.lua", "mods/biome_modifiers_patch/files/biome_modifiers_append.lua")
end
