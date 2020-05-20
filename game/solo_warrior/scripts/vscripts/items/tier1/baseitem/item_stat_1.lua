LinkLuaModifier("modifier_item_stat_1", "items/tier1/baseitem/item_stat_1", LUA_MODIFIER_MOTION_NONE)

item_stat_1 = class({})

function item_stat_1:GetIntrinsicModifierName()
	return "modifier_item_stat_1"
end

item_stat_1_1 = class(item_stat_1)
item_stat_1_2 = class(item_stat_1)
item_stat_1_3 = class(item_stat_1)

modifier_item_stat_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}end,
})

function modifier_item_stat_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end

function modifier_item_stat_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end

function modifier_item_stat_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end
