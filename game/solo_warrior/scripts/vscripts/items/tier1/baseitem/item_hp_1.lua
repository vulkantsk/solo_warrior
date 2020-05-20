LinkLuaModifier("modifier_item_hp_1", "items/tier1/baseitem/item_hp_1", LUA_MODIFIER_MOTION_NONE)

item_hp_1 = class({})

function item_hp_1:GetIntrinsicModifierName()
	return "modifier_item_hp_1"
end

item_hp_1_1 = class(item_hp_1)
item_hp_1_2 = class(item_hp_1)
item_hp_1_3 = class(item_hp_1)

modifier_item_hp_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}end,
})

function modifier_item_hp_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end