LinkLuaModifier("modifier_item_stat_armor_hp_hpreg_1", "items/tier1/craft_2/item_stat_armor_hp_hpreg_1", LUA_MODIFIER_MOTION_NONE)

item_stat_armor_hp_hpreg_1 = class({})

function item_stat_armor_hp_hpreg_1:GetIntrinsicModifierName()
	return "modifier_item_stat_armor_hp_hpreg_1"
end

item_stat_armor_hp_hpreg_1_1 = class(item_stat_armor_hp_hpreg_1)
item_stat_armor_hp_hpreg_1_2 = class(item_stat_armor_hp_hpreg_1)

modifier_item_stat_armor_hp_hpreg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK_UNAVOIDABLE_PRE_ARMOR,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}end,
})

function modifier_item_stat_armor_hp_hpreg_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierPhysical_ConstantBlockUnavoidablePreArmor(data)
	local block_chance = self:GetAbility():GetSpecialValueFor("chance_block_pct") 
	if RollPercentage(block_chance) then
		return data.damage
	end
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hpreg")
end

function modifier_item_stat_armor_hp_hpreg_1:GetModifierExtraHealthPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_health_pct")
end
