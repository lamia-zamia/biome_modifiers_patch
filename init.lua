-- hello

function OnMagicNumbersAndWorldSeedInitialized()
	dofile_once("mods/biome_modifiers_patch/files/biome_modifiers_get_default.lua")
	local Modifiers = dofile_once("mods/biome_modifiers_patch/files/lib.lua")
	Modifiers.AppendFile("mods/biome_modifiers_patch/files/biome_modifiers_append.lua")
end