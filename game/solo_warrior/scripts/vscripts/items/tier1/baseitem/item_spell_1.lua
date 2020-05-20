LinkLuaModifier("modifier_item_spell_1", "items/tier1/baseitem/item_spell_1", LUA_MODIFIER_MOTION_NONE)

item_spell_1 = class({})

function item_spell_1:GetIntrinsicModifierName()
	return "modifier_item_spell_1"
end

item_spell_1_1 = class(item_spell_1)
item_spell_1_2 = class(item_spell_1)
item_spell_1_3 = class(item_spell_1)

modifier_item_spell_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}end,
})

function modifier_item_spell_1:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end