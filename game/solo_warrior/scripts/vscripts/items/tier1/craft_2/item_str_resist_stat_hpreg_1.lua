LinkLuaModifier("modifier_item_str_resist_stat_hpreg_1", "items/tier1/craft_2/item_str_resist_stat_hpreg_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_str_resist_stat_hpreg_buff_1", "items/tier1/craft_2/item_str_resist_stat_hpreg_1", LUA_MODIFIER_MOTION_NONE)

item_str_resist_stat_hpreg_1 = class({})

function item_str_resist_stat_hpreg_1:GetIntrinsicModifierName()
	return "modifier_item_str_resist_stat_hpreg_1"
end

function item_str_resist_stat_hpreg_1:OnSpellStart()
	local caster = self:GetCaster()
	local buff_duration = self:GetSpecialValueFor("buff_duration")

	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	caster:AddNewModifier(caster, self, "modifier_item_str_resist_stat_hpreg_buff_1", {duration = buff_duration})
end

item_str_resist_stat_hpreg_1_1 = class(item_str_resist_stat_hpreg_1)
item_str_resist_stat_hpreg_1_2 = class(item_str_resist_stat_hpreg_1)

modifier_item_str_resist_stat_hpreg_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}end,
})

function modifier_item_str_resist_stat_hpreg_1:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_resist")
end

function modifier_item_str_resist_stat_hpreg_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")+self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_str_resist_stat_hpreg_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_str_resist_stat_hpreg_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_str_resist_stat_hpreg_1:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_hpreg")
end

modifier_item_str_resist_stat_hpreg_buff_1 = class({
	IsHidden 		= function(self) return false end,
	CheckState  = function(self) return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}end,
})

function modifier_item_str_resist_stat_hpreg_buff_1:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end
function modifier_item_str_resist_stat_hpreg_buff_1:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("buff_regen")
end
