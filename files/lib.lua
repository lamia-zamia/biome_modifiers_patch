local search = "return init_biome_modifiers"
local modifiers_file = "data/scripts/biome_modifiers.lua"

local function append_file_to_biome_modifiers(file)
	local append_file = ModTextFileGetContent(file)
	local content = ModTextFileGetContent(modifiers_file)
	local new = content:gsub(search, append_file .. "\n" .. search, 1)
	ModTextFileSetContent(modifiers_file, new)
end

local function append_string_to_biome_modifiers(string)
	local content = ModTextFileGetContent(modifiers_file)
	local new = content:gsub(search, string .. "\n" .. search, 1)
	ModTextFileSetContent(modifiers_file, new)
end

return {
	AppendFile = append_file_to_biome_modifiers,
	AppendString = append_string_to_biome_modifiers
}