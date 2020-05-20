LinkLuaModifier("modifier_axe_true_strength", "heroes/hero_axe/true_strength", LUA_MODIFIER_MOTION_NONE)

axe_true_strength = class({})

function axe_true_strength:GetIntrinsicModifierName() 
	return "modifier_axe_true_strength"
end
--------------------------------------------------------
------------------------------------------------------------
modifier_axe_true_strength = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		} end,
})

function modifier_axe_true_strength:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_axe_true_strength:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local bonus_str_pct = ability:GetSpecialValueFor("bonus_str_pct")/100
	local stack_count = self:GetStackCount()
	local strength = caster:GetStrength() - stack_count
	local str_bonus = strength * bonus_str_pct

	self:SetStackCount(str_bonus)
end

function modifier_axe_true_strength:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end


