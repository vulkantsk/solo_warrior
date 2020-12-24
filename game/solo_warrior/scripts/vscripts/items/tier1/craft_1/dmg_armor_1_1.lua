LinkLuaModifier("modifier_item_dmg_armor_1", "items/tier1/craft_1/item_dmg_armor_1", LUA_MODIFIER_MOTION_NONE)

item_dmg_armor_1 = class({})

function item_dmg_armor_1:GetIntrinsicModifierName()
	return "modifier_item_dmg_armor_1"
end

item_dmg_armor_1_1 = class(item_dmg_armor_1)
item_dmg_armor_1_2 = class(item_dmg_armor_1)
item_dmg_armor_1_3 = class(item_dmg_armor_1)

modifier_item_dmg_armor_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}end,
})

function modifier_item_dmg_armor_1:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_dmg_armor_1:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_dmg_armor_1:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("dmg_return_pct")*(-1)
end
