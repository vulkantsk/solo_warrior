LinkLuaModifier("modifier_item_resist_1", "items/tier1/baseitem/item_resist_1", LUA_MODIFIER_MOTION_NONE)

item_resist_1 = class({})

function item_resist_1:GetIntrinsicModifierName()
	return "modifier_item_resist_1"
end

item_resist_1_1 = class(item_resist_1)
item_resist_1_2 = class(item_resist_1)
item_resist_1_3 = class(item_resist_1)

modifier_item_resist_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}end,
})

function modifier_item_resist_1:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end