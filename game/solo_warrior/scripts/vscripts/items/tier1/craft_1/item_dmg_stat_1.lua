LinkLuaModifier("modifier_item_dmg_stat_1", "items/tier1/craft_1/item_dmg_stat_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_dmg_stat_aura_1", "items/tier1/craft_1/item_dmg_stat_1", LUA_MODIFIER_MOTION_NONE)

item_dmg_stat_1 = class({})

function item_dmg_stat_1:GetCastRange()
	return self:GetSpecialValueFor("aura_radius")
end

function item_dmg_stat_1:GetIntrinsicModifierName()
	return "modifier_item_dmg_stat_1"
end

item_dmg_stat_1_1 = class(item_dmg_stat_1)
item_dmg_stat_1_2 = class(item_dmg_stat_1)
item_dmg_stat_1_3 = class(item_dmg_stat_1)

modifier_item_dmg_stat_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsAura 					= function(self) return true end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("aura_radius") end,
	GetAuraSearchTeam 		= function(self) return DOTA_UNIT_TARGET_TEAM_ENEMY end,
	GetAuraSearchType 		= function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura 		= function(self) return "modifier_item_dmg_stat_aura_1" end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}end,
})

function modifier_item_dmg_stat_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_dmg_stat_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_dmg_stat_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_dmg_stat_1:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_dmg_stat_1:GetEffectName()
	return "particles/items2_fx/radiance_owner.vpcf"
end

modifier_item_dmg_stat_aura_1 = class({
	IsHidden 		= function(self) return false end,
})

function modifier_item_dmg_stat_aura_1:OnCreated()
	local caster = self:GetCaster()
	self:StartIntervalThink(1)
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/radiance.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin())
	self:AddParticle(pfx, false, false, MODIFIER_PRIORITY_HIGH, false, false)

end

function modifier_item_dmg_stat_aura_1:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local dmg_per_sec = ability:GetSpecialValueFor("dmg_per_sec")
	local damage = dmg_per_sec

	DealDamage(caster, parent, damage, DAMAGE_TYPE_MAGICAL, nil, ability)

end