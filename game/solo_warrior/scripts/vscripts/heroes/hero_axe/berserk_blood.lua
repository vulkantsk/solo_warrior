
LinkLuaModifier( "modifier_axe_berserk_blood", "heroes/hero_axe/berserk_blood", LUA_MODIFIER_MOTION_NONE )

axe_berserk_blood = class({})

function axe_berserk_blood:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_berserk_blood", {duration = self:GetSpecialValueFor("duration")})
end

--------------------------------------------------------------------------------

modifier_axe_berserk_blood = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
})

function modifier_axe_berserk_blood:DeclareFunctions()
	local DFtable = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
    if IsServer() and self.talent_bonus then
		table.insert(DFtable, MODIFIER_PROPERTY_MIN_HEALTH)
	end
	return DFtable
end

function modifier_axe_berserk_blood:OnCreated()
	local ability = self:GetAbility()
	self.attack_speed = ability:GetSpecialValueFor("attack_speed")
    self.attack_bonus = ability:GetSpecialValueFor("attack_bonus")
    if IsServer() then
		local caster = self:GetCaster()
		local health_prc = caster:GetHealth()/caster:GetMaxHealth()*100
		local stackCount = 0
		if caster:HasTalent("talent_axe_berserk_blood_4") then
			stackCount = math.floor(100/ability:GetSpecialValueFor("prc_health_for_bonus"))*100
		else
			stackCount = math.floor((100-health_prc)/ability:GetSpecialValueFor("prc_health_for_bonus"))*100
		end
		if caster:HasTalent("talent_axe_berserk_blood_3") then
			stackCount = stackCount * (1 + caster:FindTalentValue("talent_axe_berserk_blood_3", "prc")/100)
		end
		self:SetStackCount(stackCount)
		if caster:HasTalent("talent_axe_berserk_blood_2") and health_prc < caster:FindTalentValue("talent_axe_berserk_blood_2", "hp_required") then
			self.talent_bonus = true
		end
    end
end

function modifier_axe_berserk_blood:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed * self:GetStackCount()/100
end

function modifier_axe_berserk_blood:GetModifierPreAttack_BonusDamage()
	return self.attack_bonus * self:GetStackCount()/100
end

function modifier_axe_berserk_blood:OnTakeDamage( params )
	if IsServer() then
    	local caster = self:GetCaster()
		if caster:HasTalent("talent_axe_berserk_blood_1") then
			if params.attacker == self:GetParent() then
				if params.unit and params.unit:GetHealth() < 1 then
					local heal = params.unit:GetMaxHealth()*caster:FindTalentValue("talent_axe_berserk_blood_1", "hp_pct")/100
					caster:Heal(heal, caster)	
				end
			end
		end
	end
end

function modifier_axe_berserk_blood:GetMinHealth()
	return 1
end