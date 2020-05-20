LinkLuaModifier("modifier_item_stat_resist_str_hpreg_1", "items/tier1/craft_2/item_stat_resist_str_hpreg_1", LUA_MODIFIER_MOTION_NONE)

item_stat_resist_str_hpreg_1 = class({})

function item_stat_resist_str_hpreg_1:GetIntrinsicModifierName()
	return "modifier_item_stat_resist_str_hpreg_1"
end

item_stat_resist_str_hpreg_1_1 = class(item_stat_resist_str_hpreg_1)
item_stat_resist_str_hpreg_1_2 = class(item_stat_resist_str_hpreg_1)

modifier_item_stat_resist_str_hpreg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}end,
})

function modifier_item_stat_resist_str_hpreg_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")+self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_stat_resist_str_hpreg_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_stat_resist_str_hpreg_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_stat_resist_str_hpreg_1:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_resist")
end

function modifier_item_stat_resist_str_hpreg_1:GetModifierPercentageManacost()
	return self:GetAbility():GetSpecialValueFor("manacost_reduction")
end

function modifier_item_stat_resist_str_hpreg_1:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hpreg")
end

function modifier_item_stat_resist_str_hpreg_1:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("hp_regen_pct")
end