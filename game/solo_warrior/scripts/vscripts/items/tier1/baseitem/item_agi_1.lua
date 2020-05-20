LinkLuaModifier("modifier_item_agi_1", "items/tier1/baseitem/item_agi_1", LUA_MODIFIER_MOTION_NONE)

item_agi_1 = class({})

function item_agi_1:GetIntrinsicModifierName()
	return "modifier_item_agi_1"
end

item_agi_1_1 = class(item_agi_1)
item_agi_1_2 = class(item_agi_1)
item_agi_1_3 = class(item_agi_1)

modifier_item_agi_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}end,
})

function modifier_item_agi_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end