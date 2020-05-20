LinkLuaModifier("modifier_item_hp_armor_1", "items/tier1/craft_1/item_hp_armor_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_hp_armor_aura_1", "items/tier1/craft_1/item_hp_armor_1", LUA_MODIFIER_MOTION_NONE)

item_hp_armor_1 = class({})

function item_hp_armor_1:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end

function item_hp_armor_1:GetIntrinsicModifierName()
	return "modifier_item_hp_armor_1"
end

item_hp_armor_1_1 = class(item_hp_armor_1)
item_hp_armor_1_2 = class(item_hp_armor_1)

modifier_item_hp_armor_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_item_hp_armor_aura_1" end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}end,
})

function modifier_item_hp_armor_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_hp_armor_1:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

modifier_item_hp_armor_aura_1 = class({
	IsHidden 		= function(self) return false end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}end,
})

function modifier_item_hp_armor_aura_1:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aura_as_decrease")*(-1)
end

function modifier_item_hp_armor_aura_1:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("aura_ms_decrease")*(-1)
end
