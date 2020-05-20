LinkLuaModifier("modifier_item_str_1", "items/tier1/baseitem/item_str_1", LUA_MODIFIER_MOTION_NONE)

item_str_1 = class({})

function item_str_1:GetIntrinsicModifierName()
	return "modifier_item_str_1"
end

item_str_1_1 = class(item_str_1)
item_str_1_2 = class(item_str_1)
item_str_1_3 = class(item_str_1)

modifier_item_str_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}end,
})

function modifier_item_str_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end