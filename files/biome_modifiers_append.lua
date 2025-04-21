local global_probability = tonumber(ModSettingGet("biome_modifiers_patch.probability"))
if global_probability ~= 0 then
	CHANCE_OF_MODIFIER_PER_BIOME = global_probability
	for k, _ in pairs(CHANCES_OF_MODIFIERS_BIOME_SPECIFIC) do
		CHANCES_OF_MODIFIERS_BIOME_SPECIFIC[k] = global_probability
	end
end

local function biome_modifiers_patch_add_biome_modifiers(modifiers)
	for _, modifier in ipairs(modifiers) do
		local probability = tonumber(ModSettingGet("biome_modifiers_patch." .. modifier.id)) or 0
		if probability >= 0 then
			local index = #biome_modifiers + 1
			local flag = modifier.requires_flag
			biome_modifiers[index] = modifier
			biome_modifiers[index].probability = probability
			if flag and ModSettingGet("biome_modifiers_patch.flag_" .. flag) then biome_modifiers[index].requires_flag = nil end
		end
	end
end

local biome_modifiers_old = biome_modifiers
biome_modifiers = {}
biome_modifiers_patch_add_biome_modifiers(biome_modifiers_old)
