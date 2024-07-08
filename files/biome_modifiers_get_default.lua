dofile_once("data/scripts/biome_modifiers.lua")

local virtual_file = "mods/biome_modifiers_patch/defaults.lua"
local content = "biome_modifiers_default = {}"

local function add_content(modifier)
	content = content .. "\n" .. 
	"biome_modifiers_default[#biome_modifiers_default+1] = {" ..
	"id = \"" .. modifier.id .. "\", " ..
	"ui_description = \"" .. modifier.ui_description .. "\", " ..
	"ui_decoration_file = \"" .. modifier.ui_decoration_file .. "\", " ..
	"probability = " .. modifier.probability ..
	"}"
end

for i, modifier in ipairs(biome_modifiers) do
	add_content(modifier)
end

content = content .. "\nreturn biome_modifiers_default"

ModTextFileSetContent(virtual_file, content)