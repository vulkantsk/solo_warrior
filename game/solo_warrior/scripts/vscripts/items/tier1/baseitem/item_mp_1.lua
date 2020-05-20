LinkLuaModifier("modifier_item_mp_1", "items/tier1/baseitem/item_mp_1", LUA_MODIFIER_MOTION_NONE)

item_mp_1 = class({})

function item_mp_1:GetIntrinsicModifierName()
	return "modifier_item_mp_1"
end

item_mp_1_1 = class(item_mp_1)
item_mp_1_2 = class(item_mp_1)
item_mp_1_3 = class(item_mp_1)

modifier_item_mp_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_MANA_BONUS
	}end,
})

function modifier_item_mp_1:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end