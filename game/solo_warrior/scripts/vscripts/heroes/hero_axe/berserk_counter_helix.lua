LinkLuaModifier( "modifier_axe_berserk_counter_helix", "heroes/hero_axe/berserk_counter_helix", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_berserk_counter_helix_debuff", "heroes/hero_axe/berserk_counter_helix", LUA_MODIFIER_MOTION_NONE ) 

axe_berserk_counter_helix = class({})

function axe_berserk_counter_helix:GetCastRange()
	return self:GetSpecialValueFor("trigger_chance")
end

function axe_berserk_counter_helix:GetIntrinsicModifierName()
	return "modifier_axe_berserk_counter_helix"
end

modifier_axe_berserk_counter_helix = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {           
            MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE
        } end,
})

function modifier_axe_berserk_counter_helix:OnAttackLanded( params )
    if IsServer() then
    	local caster = self:GetCaster()

		if params.target == caster and not caster:PassivesDisabled() then
			local ability = self:GetAbility()
			local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
			local radius = ability:GetSpecialValueFor("radius")
			local base_damage = ability:GetSpecialValueFor("base_damage")
			local attack_damage = ability:GetSpecialValueFor("attack_damage")/100
			local damage = base_damage + caster:GetAverageTrueAttackDamage(caster)*attack_damage
			local point = caster:GetAbsOrigin()
			
			-- if caster:HasTalent("ability_talent_berserk_1") then
			-- 	trigger_chance = trigger_chance + caster:FindTalentValue("ability_talent_berserk_1", "bonus_chance")
			-- end
			
			-- if caster:HasTalent("special_bonus_custom_axe_2") then
			-- 	damage = damage*(100 + caster:FindTalentValue("special_bonus_custom_axe_2"))/100
			-- end

			if ability:IsCooldownReady() and RollPercentage(trigger_chance) then
				local data = {iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES}
				local enemies = caster:FindEnemyUnitsInRadius(point, radius, data)
				local needcooldown = true
				if caster:HasTalent("ability_talent_berserk_5") and caster:FindModifierByName("modifier_axe_berserk_blood") then
					needcooldown = false
				end
				ability:UseResources(true, true, needcooldown)
				caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1)
				caster:EmitSound("hero_axe.counterhelix")

				local effect = "particles/units/heroes/hero_axe/axe_counterhelix.vpcf"
				local effect_cast = ParticleManager:CreateParticle( effect, PATTACH_ABSORIGIN_FOLLOW, caster )
				ParticleManager:ReleaseParticleIndex( effect_cast )

				local effect2 = "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf"
				if caster:HasModifier("modifier_axe_berserk_form") then
					effect2 = "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_attack_blur_counterhelix.vpcf"
				end
				local effect_cast2 = ParticleManager:CreateParticle( effect2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
				ParticleManager:ReleaseParticleIndex( effect_cast2 )

				for _, enemy in pairs(enemies) do
					if caster:HasTalent("ability_talent_berserk_4") and RollPercentage(caster:FindTalentValue("ability_talent_berserk_4", "chance")) then
						enemy:AddNewModifier(caster, ability, "modifier_stun", {duration = caster:FindTalentValue("ability_talent_berserk_4", "duration")})
					end
					if caster:HasTalent("ability_talent_berserk_13") then
						local mod = enemy:FindModifierByName("modifier_axe_berserk_counter_helix_debuff")
						if mod then
							mod:SetStackCount(mod:GetStackCount()+caster:FindTalentValue("ability_talent_berserk_13", "min_armor"))
							mod:SetDuration(caster:FindTalentValue("ability_talent_berserk_13", "duration"), true)
						else
							mod = enemy:AddNewModifier(caster, ability, "modifier_axe_berserk_counter_helix_debuff", {duration = caster:FindTalentValue("ability_talent_berserk_13", "duration")})
							mod:SetStackCount(caster:FindTalentValue("ability_talent_berserk_13", "min_armor"))
						end
					end
					DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
				end
			end
		end
    end
    return 0
end

function modifier_axe_berserk_counter_helix:GetModifierOverrideAbilitySpecial( params )
	if self:GetParent() == nil or params.ability == nil then
		return 0
	end

	local szAbilityName = params.ability:GetAbilityName()
	if szAbilityName ~= "axe_berserk_counter_helix" then
		return 0
	end
	
	local szSpecialValueName = params.ability_special_value

	if szSpecialValueName == "trigger_chance" and self:GetParent():HasModifier("modifier_ability_talent_berserk_1") then
		return 1
	end

	return 0
end

function modifier_axe_berserk_counter_helix:GetModifierOverrideAbilitySpecialValue( params )
	local szAbilityName = params.ability:GetAbilityName()
	local szSpecialValueName = params.ability_special_value
	if szAbilityName == "axe_berserk_counter_helix" then
		if szSpecialValueName == "trigger_chance" then
			local nSpecialLevel = params.ability_special_level
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( szSpecialValueName, nSpecialLevel )
			return flBaseValue + self:GetParent():GetModifierStackCount("modifier_ability_talent_berserk_1", self:GetParent())
		end
	end

	return 0
end

--------------------------------------------------------------------------------

modifier_axe_berserk_counter_helix_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		} end,
})


function modifier_axe_berserk_counter_helix_debuff:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end
