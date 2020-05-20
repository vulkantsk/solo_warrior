LinkLuaModifier("modifier_item_mpreg_1", "items/tier1/baseitem/item_mpreg_1", LUA_MODIFIER_MOTION_NONE)

item_mpreg_1 = class({})

function item_mpreg_1:GetIntrinsicModifierName()
	return "modifier_item_mpreg_1"
end

item_mpreg_1_1 = class(item_mpreg_1)
item_mpreg_1_2 = class(item_mpreg_1)
item_mpreg_1_3 = class(item_mpreg_1)

modifier_item_mpreg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}end,
})

function modifier_item_mpreg_1:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end