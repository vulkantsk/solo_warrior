LinkLuaModifier("modifier_item_int_1", "items/tier1/baseitem/item_int_1", LUA_MODIFIER_MOTION_NONE)

item_int_1 = class({})

function item_int_1:GetIntrinsicModifierName()
	return "modifier_item_int_1"
end

item_int_1_1 = class(item_int_1)
item_int_1_2 = class(item_int_1)
item_int_1_3 = class(item_int_1)

modifier_item_int_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}end,
})

function modifier_item_int_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end