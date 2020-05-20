LinkLuaModifier("modifier_item_as_1", "items/tier1/baseitem/item_as_1", LUA_MODIFIER_MOTION_NONE)

item_as_1 = class({})

function item_as_1:GetIntrinsicModifierName()
	return "modifier_item_as_1"
end

item_as_1_1 = class(item_as_1)
item_as_1_2 = class(item_as_1)
item_as_1_3 = class(item_as_1)

modifier_item_as_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}end,
})

function modifier_item_as_1:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end