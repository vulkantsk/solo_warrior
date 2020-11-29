
LinkLuaModifier( "modifier_axe_super_vitality", "heroes/hero_axe/super_vitality", LUA_MODIFIER_MOTION_NONE )

axe_super_vitality = class({})

function axe_super_vitality:OnSpellStart()
	local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_axe_super_vitality", {duration = self:GetSpecialValueFor("duration")})
			
	if caster:HasTalent("ability_talent_warrior_2") then
		Purge(false, true, false, false, false)
	end
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
	self.regen = ability:GetSpecialValueFor("regen")/100
    self.bonus_regen = ability:GetSpecialValueFor("bonus_regen")/100
	self.duration = ability:GetSpecialValueFor("duration")

	if IsServer() then
    	self.caster = self:GetCaster()
    	local health_prc = self.caster:GetHealth()/self.caster:GetMaxHealth()*100
    	self.lost_hp_bonus = math.floor((100-health_prc)/(ability:GetSpecialValueFor("prc_health_for_bonus")))
		self.status_res = ability:GetSpecialValueFor("status_res") + ability:GetSpecialValueFor("bonus_status_res") * self.lost_hp_bonus

		if self.caster:HasTalent("ability_talent_warrior_10") then
			self.status_res = self.status_res * (1+ self.caster:FindTalentValue("ability_talent_warrior_10", "bonus_prc")/100)
		end
	
		if self.caster:HasTalent("ability_talent_warrior_7") then
			self:SetStackCount(self.caster:GetMaxHealth()*self.caster:FindTalentValue("ability_talent_warrior_7", "prc_hp")/100)
		end
		
		self:StartIntervalThink(0.1)
	end
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
			local regen = self.taken_damage * (self.regen + self.bonus_regen * self.lost_hp_bonus) / self.duration
			if self.caster:HasTalent("ability_talent_warrior_7") then
				regen = regen + self.caster:GetMaxHealth()*self.caster:FindTalentValue("ability_talent_warrior_7", "prc_hp")/100
			end
			if self.caster:HasTalent("ability_talent_warrior_10") then
				regen = regen * (1+ self.caster:FindTalentValue("ability_talent_warrior_10", "bonus_prc")/100)
			end
            self:SetStackCount(regen)
        end
	end
end

function modifier_axe_super_vitality:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_ROOTED] = self.caster:HasTalent("ability_talent_warrior_10"),
		}
	end
end

function modifier_axe_super_vitality:OnIntervalThink()
	if IsServer() then
		if self.caster:HasTalent("ability_talent_warrior_11") then
			Purge(false, true, false, false, false)
		end
	end
end