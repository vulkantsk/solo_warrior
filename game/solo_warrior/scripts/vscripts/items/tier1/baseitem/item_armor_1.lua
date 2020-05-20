LinkLuaModifier("modifier_item_armor_1", "items/tier1/baseitem/item_armor_1", LUA_MODIFIER_MOTION_NONE)

item_armor_1 = class({})

function item_armor_1:GetIntrinsicModifierName()
	return "modifier_item_armor_1"
end

item_armor_1_1 = class(item_armor_1)
item_armor_1_2 = class(item_armor_1)
item_armor_1_3 = class(item_armor_1)

modifier_item_armor_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}end,
})

function modifier_item_armor_1:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end