LinkLuaModifier("modifier_item_boots_1", "items/tier1/baseitem/item_boots_1", LUA_MODIFIER_MOTION_NONE)

item_boots_1 = class({})

function item_boots_1:GetIntrinsicModifierName()
	return "modifier_item_boots_1"
end

item_boots_1_1 = class(item_boots_1)
item_boots_1_2 = class(item_boots_1)
item_boots_1_3 = class(item_boots_1)

modifier_item_boots_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}end,
})


function modifier_item_boots_1:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end