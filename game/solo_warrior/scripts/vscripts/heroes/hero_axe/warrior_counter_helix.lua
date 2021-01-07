LinkLuaModifier( "modifier_axe_warrior_counter_helix", "heroes/hero_axe/warrior_counter_helix", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_warrior_counter_helix_active", "heroes/hero_axe/warrior_counter_helix", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_warrior_counter_helix_cooldown", "heroes/hero_axe/warrior_counter_helix", LUA_MODIFIER_MOTION_NONE ) 

axe_warrior_counter_helix = class({})

function axe_warrior_counter_helix:GetBehavior()
	if self:GetCaster():HasModifier("modifier_talent_axe_warrior_helix_5") and not self:GetCaster():HasModifier("modifier_axe_warrior_counter_helix_cooldown") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function axe_warrior_counter_helix:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:HasTalent("talent_axe_warrior_helix_5") then
			local duration = caster:FindTalentValue("talent_axe_warrior_helix_5", "duration")
			local cooldown = caster:FindTalentValue("talent_axe_warrior_helix_5", "cooldown")

			caster:AddNewModifier(caster, self, "modifier_axe_warrior_counter_helix_active", {duration = duration})
			caster:AddNewModifier(caster, self, "modifier_axe_warrior_counter_helix_cooldown", {duration = cooldown})
		end
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

		if caster:HasTalent("talent_axe_warrior_helix_5") then
			if caster.mega_helix then
				caster.mega_helix = false
				radius = radius * caster:FindTalentValue("talent_axe_warrior_helix_5", "radius_mult")
			end
		end
		local base_damage = self:GetSpecialValueFor("base_damage")
		local attack_damage = self:GetSpecialValueFor("attack_damage")/100
		local damage = base_damage + caster:GetAverageTrueAttackDamage(caster)*attack_damage
		local data = {iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES}
		local enemies = caster:FindEnemyUnitsInRadius(point, radius, data)
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

function modifier_axe_warrior_counter_helix:OnIntervalThink()
	if IsServer() then
    	local caster = self:GetCaster()
		if caster:HasTalent("talent_axe_warrior_helix_3") then
			self:GetAbility():CounterHelix()
			return caster:FindTalentValue("talent_axe_warrior_helix_3", "interval")
		end
		return 1
    end
end
function modifier_axe_warrior_counter_helix:OnAttackLanded( params )
    if IsServer() then
    	local caster = self:GetCaster()

		if params.target == caster and not caster:PassivesDisabled() then
			local ability = self:GetAbility()
			local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
			
			-- if caster:HasTalent("talent_axe_warrior_helix_1") then
			-- 	trigger_chance = trigger_chance + caster:FindTalentValue("talent_axe_warrior_helix_1", "bonus_chance")
			-- end
			
			-- if caster:HasTalent("special_bonus_custom_axe_2") then
			-- 	damage = damage*(100 + caster:FindTalentValue("special_bonus_custom_axe_2"))/100
			-- end

			if ability:IsCooldownReady() and RollPercentage(trigger_chance) then
				ability:CounterHelix()
				ability:UseResources(true, true, true)
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

	if szSpecialValueName == "trigger_chance" and self:GetParent():HasModifier("modifier_talent_axe_warrior_helix_1") then
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
			return flBaseValue + self:GetParent():GetModifierStackCount("modifier_talent_axe_warrior_helix_1", self:GetParent())
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
    	local ability = self:GetAbility()
		if caster:HasTalent("talent_axe_warrior_helix_2") then
			if ability:IsCooldownReady() and RollPercentage(caster:FindTalentValue("talent_axe_warrior_helix_2", "chance")) then
				ability:CounterHelix()
				ability:UseResources(true, true, true)
			end
		end
		if caster:HasTalent("talent_axe_warrior_helix_4") then
			if params.attacker == self:GetParent() then
				if params.unit and params.unit:GetHealth() < 1 and params.inflictor == ability then
					local abil = params.attacker:FindAbilityByName("axe_power_of_pain")
					local cooldown = abil:GetCooldownTimeRemaining()
					if cooldown > 0 then
						abil:StartCooldown(cooldown - caster:FindTalentValue("talent_axe_warrior_helix_3", "cd_per_kill"))
					end
				end
			end
		end
	end
end

modifier_axe_warrior_counter_helix_active = class({
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
})

function modifier_axe_warrior_counter_helix_active:OnCreated( params )
    if IsServer() then
    	local caster = self:GetCaster()
 		local interval = caster:FindTalentValue("talent_axe_warrior_helix_5", "interval")
		self:StartIntervalThink(interval)
  end
end

function modifier_axe_warrior_counter_helix_active:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		caster.mega_helix = true
		self:GetAbility():CounterHelix()
    end
end

modifier_axe_warrior_counter_helix_cooldown = class({
	IsHidden = function() return false end,
	IsDebuff = function() return true end,
	IsPurgable = function() return false end,
})
