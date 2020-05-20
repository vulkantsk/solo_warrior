LinkLuaModifier("modifier_item_str_armor_1", "items/tier1/craft_1/item_str_armor_1", LUA_MODIFIER_MOTION_NONE)

item_str_armor_1 = class({})

function item_str_armor_1:GetIntrinsicModifierName()
	return "modifier_item_str_armor_1"
end

item_str_armor_1_1 = class(item_str_armor_1)
item_str_armor_1_2 = class(item_str_armor_1)

modifier_item_str_armor_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}end,
})

function modifier_item_str_armor_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_str_armor_1:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_str_armor_1:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("dmg_resist_pct")*(-1)
end


