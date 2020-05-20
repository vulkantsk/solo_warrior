LinkLuaModifier("modifier_item_dmg_1", "items/tier1/baseitem/item_dmg_1", LUA_MODIFIER_MOTION_NONE)

item_dmg_1 = class({})

function item_dmg_1:GetIntrinsicModifierName()
	return "modifier_item_dmg_1"
end

item_dmg_1_1 = class(item_dmg_1)
item_dmg_1_2 = class(item_dmg_1)
item_dmg_1_3 = class(item_dmg_1)

modifier_item_dmg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}end,
})

function modifier_item_dmg_1:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end