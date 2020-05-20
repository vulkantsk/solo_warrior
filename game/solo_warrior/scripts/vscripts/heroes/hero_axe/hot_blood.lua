
LinkLuaModifier( "modifier_axe_hot_blood", "heroes/hero_axe/hot_blood", LUA_MODIFIER_MOTION_NONE )

axe_hot_blood = class({})

function axe_hot_blood:GetIntrinsicModifierName()
	return "modifier_axe_hot_blood"
end

--------------------------------------------------------------------------------

modifier_axe_hot_blood = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		} end,
})

function modifier_axe_hot_blood:OnCreated()
	local ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.bonus_regen 	= ability:GetSpecialValueFor("bonus_regen")
	self.bonus_regen_pct= ability:GetSpecialValueFor("bonus_regen_pct")
	self.required_hp 	= ability:GetSpecialValueFor("required_hp")

	self:StartIntervalThink(0.1)
end

function modifier_axe_hot_blood:OnIntervalThink()
	if self.caster:GetHealthPercent() <= self.required_hp  then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

function modifier_axe_hot_blood:GetModifierConstantHealthRegen()
	return self:GetStackCount()*self.bonus_regen
end

function modifier_axe_hot_blood:GetModifierHealthRegenPercentage()
	return self:GetStackCount()*self.bonus_regen_pct
end
