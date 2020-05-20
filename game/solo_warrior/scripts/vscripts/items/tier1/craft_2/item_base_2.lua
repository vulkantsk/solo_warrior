LinkLuaModifier("modifier_item_base_2", "items/tier1/craft_2/item_base_2", LUA_MODIFIER_MOTION_NONE)

item_base_2 = class({})

function item_base_2:GetIntrinsicModifierName()
	return "modifier_item_base_2"
end

item_base_2_1 = class(item_base_2)
item_base_2_2 = class(item_base_2)

modifier_item_base_2 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}end,
})

function modifier_item_base_2:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_base1")
end

function modifier_item_base_2:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_base2")
end

function modifier_item_base_2:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_base3")
end

function modifier_item_base_2:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_base4")
end

function modifier_item_base_2:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_special_1")
end

function modifier_item_base_2:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_special_2")
end
