local GlobalProbability = tonumber(ModSettingGet("biome_modifiers_patch.probability"))
if GlobalProbability ~= 0 then
	CHANCE_OF_MODIFIER_PER_BIOME = GlobalProbability
	CHANCE_OF_MODIFIER_COALMINE = GlobalProbability
	CHANCE_OF_MODIFIER_EXCAVATIONSITE = GlobalProbability
	CHANCE_OF_MOIST_FUNGICAVE = GlobalProbability
	CHANCE_OF_MOIST_LAKE  = GlobalProbability
end

local function biome_modifiers_patch_add_biome_modifiers(modifiers)
	for _, modifier in ipairs(modifiers) do
		local probability = ModSettingGet("biome_modifiers_patch." .. modifier.id)
		if probability >= 0 then
			local index = #biome_modifiers+1
			biome_modifiers[index] = modifier
			biome_modifiers[index].probability = probability
		end
	end
end

local biome_modifiers_old = biome_modifiers
biome_modifiers = {}
biome_modifiers_patch_add_biome_modifiers(biome_modifiers_old)