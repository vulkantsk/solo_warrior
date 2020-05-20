LinkLuaModifier("modifier_item_hpreg_1", "items/tier1/baseitem/item_hpreg_1", LUA_MODIFIER_MOTION_NONE)

item_hpreg_1 = class({})

function item_hpreg_1:GetIntrinsicModifierName()
	return "modifier_item_hpreg_1"
end

item_hpreg_1_1 = class(item_hpreg_1)
item_hpreg_1_2 = class(item_hpreg_1)
item_hpreg_1_3 = class(item_hpreg_1)

modifier_item_hpreg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}end,
})

function modifier_item_hpreg_1:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end