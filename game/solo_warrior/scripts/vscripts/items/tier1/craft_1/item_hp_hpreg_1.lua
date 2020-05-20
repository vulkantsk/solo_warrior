LinkLuaModifier("modifier_item_hp_hpreg_1", "items/tier1/craft_1/item_hp_hpreg_1", LUA_MODIFIER_MOTION_NONE)

item_hp_hpreg_1 = class({})

function item_hp_hpreg_1:GetIntrinsicModifierName()
	return "modifier_item_hp_hpreg_1"
end

item_hp_hpreg_1_1 = class(item_hp_hpreg_1)
item_hp_hpreg_1_2 = class(item_hp_hpreg_1)

modifier_item_hp_hpreg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
	}end,
})

function modifier_item_hp_hpreg_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_hp_hpreg_1:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hpreg")
end

function modifier_item_hp_hpreg_1:GetModifierExtraHealthPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_health_pct")
end
