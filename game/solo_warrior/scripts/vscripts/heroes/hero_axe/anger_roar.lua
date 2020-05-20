
LinkLuaModifier( "modifier_axe_anger_roar", "heroes/hero_axe/anger_roar", LUA_MODIFIER_MOTION_NONE )

axe_anger_roar = class({})

function axe_anger_roar:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:EmitSound("hero_axe.berserkers_call")

	caster:AddNewModifier(caster, self, "modifier_axe_anger_roar", {duration = duration})
end
 
--------------------------------------------------------------------------------

modifier_axe_anger_roar = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
			MODIFIER_PROPERTY_MODEL_SCALE,
		} end,
})

function modifier_axe_anger_roar:OnCreated()
	local ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.bonus_armor	= ability:GetSpecialValueFor("bonus_armor")
	self.bonus_health_pct	= ability:GetSpecialValueFor("bonus_health_pct")
	self.bonus_scale 	= ability:GetSpecialValueFor("bonus_scale")

end

function modifier_axe_anger_roar:GetEffectName()
	return "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_beserkers_call_owner.vpcf"
end

function modifier_axe_anger_roar:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_axe_anger_roar:GetModifierExtraHealthPercentage()
	return self.bonus_health_pct
end

function modifier_axe_anger_roar:GetModifierModelScale()
	return self.bonus_scale
end
