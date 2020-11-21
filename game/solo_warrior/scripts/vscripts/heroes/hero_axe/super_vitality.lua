
LinkLuaModifier( "modifier_axe_super_vitality", "heroes/hero_axe/super_vitality", LUA_MODIFIER_MOTION_NONE )

axe_super_vitality = class({})

function axe_super_vitality:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_super_vitality", {duration = self:GetSpecialValueFor("duration")})
end

--------------------------------------------------------------------------------

modifier_axe_super_vitality = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
            MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		} end,
})

function modifier_axe_super_vitality:OnCreated()
	local ability = self:GetAbility()
    self.caster = self:GetCaster()
    local health_prc = self.caster:GetHealth()/self.caster:GetMaxHealth()*100
    self.lost_hp_bonus = math.floor((100-health_prc)/(ability:GetSpecialValueFor("prc_health_for_bonus")))
	self.status_res = ability:GetSpecialValueFor("status_res") + ability:GetSpecialValueFor("bonus_status_res") * self.lost_hp_bonus
	self.regen = ability:GetSpecialValueFor("regen")/100
    self.bonus_regen = ability:GetSpecialValueFor("bonus_regen")/100
    self.duration = ability:GetSpecialValueFor("duration")
end

function modifier_axe_super_vitality:GetModifierStatusResistanceStacking()
	return self.status_res
end

function modifier_axe_super_vitality:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end

function modifier_axe_super_vitality:OnTakeDamage( params )
	if IsServer() then
        if params.unit == self:GetParent() then
            if self.taken_damage == nil then
                self.taken_damage = 0
            end
            self.taken_damage = self.taken_damage + params.damage
            self:SetStackCount(self.taken_damage * (self.regen + self.bonus_regen * self.lost_hp_bonus) / self.duration)
        end
	end
end