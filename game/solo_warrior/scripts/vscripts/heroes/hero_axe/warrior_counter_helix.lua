LinkLuaModifier( "modifier_axe_warrior_counter_helix", "heroes/hero_axe/warrior_counter_helix", LUA_MODIFIER_MOTION_NONE ) 

axe_warrior_counter_helix = class({})

function axe_warrior_counter_helix:GetBehavior()
	if self:GetCaster():HasModifier("modifier_ability_talent_warrior_6") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function axe_warrior_counter_helix:OnSpellStart()
    if IsServer() then
		self:CounterHelix()
	end
end

function axe_warrior_counter_helix:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function axe_warrior_counter_helix:GetIntrinsicModifierName()
	return "modifier_axe_warrior_counter_helix"
end

function axe_warrior_counter_helix:CounterHelix()
	if IsServer() then
    	local caster = self:GetCaster()
		local point = caster:GetAbsOrigin()
		local radius = self:GetSpecialValueFor("radius")
		if caster:HasTalent("ability_talent_warrior_6") then
			radius = radius * 2
		end
		local base_damage = self:GetSpecialValueFor("base_damage")
		local attack_damage = self:GetSpecialValueFor("attack_damage")/100
		local damage = base_damage + caster:GetAverageTrueAttackDamage(caster)*attack_damage
		local data = {iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES}
		local enemies = caster:FindEnemyUnitsInRadius(point, radius, data)
		self:UseResources(true, true, true)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1)
		caster:EmitSound("hero_axe.counterhelix")

		local effect = "particles/units/heroes/hero_axe/axe_counterhelix.vpcf"
		local effect_cast = ParticleManager:CreateParticle( effect, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		local effect2 = "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf"
		if caster:HasModifier("modifier_axe_berserk_form") then
			effect2 = "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_attack_blur_counterhelix.vpcf"
		end
		local effect_cast2 = ParticleManager:CreateParticle( effect2, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:ReleaseParticleIndex( effect_cast2 )

		for _, enemy in pairs(enemies) do
			DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, self)
		end
    end
end

modifier_axe_warrior_counter_helix = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {           
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
        } end,
})

function modifier_axe_warrior_counter_helix:OnCreated( params )
    if IsServer() then
		self:StartIntervalThink(1)
    end
end

function modifier_axe_warrior_counter_helix:OnAttackLanded( params )
    if IsServer() then
    	local caster = self:GetCaster()

		if params.target == caster and not caster:PassivesDisabled() then
			local ability = self:GetAbility()
			local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
			
			-- if caster:HasTalent("ability_talent_warrior_1") then
			-- 	trigger_chance = trigger_chance + caster:FindTalentValue("ability_talent_warrior_1", "bonus_chance")
			-- end
			
			-- if caster:HasTalent("special_bonus_custom_axe_2") then
			-- 	damage = damage*(100 + caster:FindTalentValue("special_bonus_custom_axe_2"))/100
			-- end

			if ability:IsCooldownReady() and RollPercentage(trigger_chance) then
				ability:CounterHelix()
			end
		end
    end
    return 0
end

function modifier_axe_warrior_counter_helix:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()
	if szAbilityName ~= "axe_warrior_counter_helix" then
		return 0
	end
	
	local szSpecialValueName = params.ability_special_value

	if szSpecialValueName == "trigger_chance" and self:GetParent():HasModifier("modifier_ability_talent_warrior_1") then
		return 1
	end

	if szSpecialValueName == "radius" and self:GetParent():HasModifier("modifier_ability_talent_warrior_6") then
		return 1
	end

	return 0
end

function modifier_axe_warrior_counter_helix:GetModifierOverrideAbilitySpecialValue( params )
	local szAbilityName = params.ability:GetAbilityName()
	local szSpecialValueName = params.ability_special_value
	if szAbilityName == "axe_warrior_counter_helix" then
		if szSpecialValueName == "trigger_chance" then
			local nSpecialLevel = params.ability_special_level
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, nSpecialLevel )
			return flBaseValue + self:GetParent():GetModifierStackCount("modifier_ability_talent_warrior_1", self:GetParent())
		end
		if szSpecialValueName == "radius" then
			local nSpecialLevel = params.ability_special_level
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, nSpecialLevel )
			return flBaseValue * 2
		end
	end

	return 0
end

function modifier_axe_warrior_counter_helix:OnTakeDamage( params )
	if IsServer() then
    	local caster = self:GetCaster()
		if caster:HasTalent("ability_talent_warrior_4") then
			params.target = params.unit
			self:OnAttackLanded( params )
		end
		if caster:HasTalent("ability_talent_warrior_14") then
			if params.attacker == self:GetParent() then
				if params.unit and params.unit:GetHealth() < 1 and params.inflictor == self:GetAbility() then
					local abil = params.attacker:FindAbilityByName("axe_power_of_pain")
					local cooldown = abil:GetCooldownTimeRemaining()
					if cooldown > 0 then
						abil:StartCooldown(cooldown - caster:FindTalentValue("ability_talent_warrior_14", "cd_per_kill"))
					end
				end
			end
		end
	end
end

function modifier_axe_warrior_counter_helix:OnIntervalThink()
	if IsServer() then
    	local caster = self:GetCaster()
		if caster:HasTalent("ability_talent_warrior_5") then
			self:GetAbility():CounterHelix()
			return caster:FindTalentValue("ability_talent_warrior_5", "interval")
		end
		return 1
    end
end