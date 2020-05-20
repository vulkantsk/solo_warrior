LinkLuaModifier("modifier_item_str_resist_1", "items/tier1/craft_1/item_str_resist_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_str_resist_buff_1", "items/tier1/craft_1/item_str_resist_1", LUA_MODIFIER_MOTION_NONE)

item_str_resist_1 = class({})

function item_str_resist_1:OnSpellStart()
	local caster = self:GetCaster()
	local buff_duration = self:GetSpecialValueFor("buff_duration")

	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	caster:AddNewModifier(caster, self, "modifier_item_str_resist_buff_1", {duration = buff_duration})
end

function item_str_resist_1:GetIntrinsicModifierName()
	return "modifier_item_str_resist_1"
end

item_str_resist_1_1 = class(item_str_resist_1)
item_str_resist_1_2 = class(item_str_resist_1)

modifier_item_str_resist_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}end,
})

function modifier_item_str_resist_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_str_resist_1:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_resist")
end

modifier_item_str_resist_buff_1 = class({
	IsHidden 		= function(self) return false end,
	IsPurgable 	= function(self) return false end,
	CheckState  = function(self) return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}end,
})

function modifier_item_str_resist_buff_1:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end