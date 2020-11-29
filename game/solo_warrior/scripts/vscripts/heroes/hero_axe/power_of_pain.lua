
LinkLuaModifier( "modifier_axe_power_of_pain", "heroes/hero_axe/power_of_pain", LUA_MODIFIER_MOTION_NONE )

axe_power_of_pain = class({})

function axe_power_of_pain:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_power_of_pain", {duration = self:GetSpecialValueFor("duration")})
end

--------------------------------------------------------------------------------

modifier_axe_power_of_pain = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
            MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
		} end,
})

function modifier_axe_power_of_pain:OnCreated()
	local ability = self:GetAbility()
    self.caster = self:GetCaster()
    self.bonus_str_per_attack = ability:GetSpecialValueFor("bonus_str")
	self.bonus_str = 0
	self.damage_per_str = ability:GetSpecialValueFor("damage_per_str")
	self.radius = ability:GetSpecialValueFor("radius")
end

function modifier_axe_power_of_pain:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_axe_power_of_pain:OnAttackLanded( params )
	if IsServer() then
        if params.target == self:GetParent() then
            self.bonus_str = self.bonus_str + self.bonus_str_per_attack
			if self.caster:HasTalent("ability_talent_warrior_13") then
				self.bonus_str = self.bonus_str + self.caster:FindTalentValue("ability_talent_warrior_13", "bonus_str_per_attack")
			end
        end
	end
end

function modifier_axe_power_of_pain:OnDestroy()
	if IsServer() then
		if self.caster and self.caster:IsAlive() then
			local enemies = FindUnitsInRadius( self.caster:GetTeamNumber(), self.caster:GetOrigin(), self.caster, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
			for _,enemy in pairs( enemies ) do
				if enemy ~= nil and enemy:IsInvulnerable() == false then
					local damage = self.caster:GetStrength() * self.damage_per_str
					
					if self.caster:HasTalent("ability_talent_warrior_8") and self.take_damage then
						damage = damage + self.take_damage*self.caster:FindTalentValue("ability_talent_warrior_8", "part")/100
					end

					local damageInfo = 
					{
						victim = enemy,
						attacker = self.caster,
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
						ability = self:GetAbility(),
					}
					ApplyDamage( damageInfo )
				end
			end
		end
	end
end

function modifier_axe_power_of_pain:OnTakeDamage( params )
	if IsServer() then
		if self.caster:HasTalent("ability_talent_warrior_8") then
			if not self.take_damage then self.take_damage = 0 end
			self.take_damage = self.take_damage + params.damage
		end
	end
end