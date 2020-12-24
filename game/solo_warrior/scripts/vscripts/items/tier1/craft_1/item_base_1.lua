LinkLuaModifier("modifier_item_base_1", "items/tier1/craft_1/item_base_1", LUA_MODIFIER_MOTION_NONE)

item_base_1 = class({})

function item_base_1:GetIntrinsicModifierName()
	return "modifier_item_base_1"
end

item_base_1_1 = class(item_base_1)
item_base_1_2 = class(item_base_1)
item_base_1_3 = class(item_base_1)

modifier_item_base_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}end,
})

function modifier_item_base_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_base1")
end

function modifier_item_base_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_base2")
end

function modifier_item_base_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_special")
end
