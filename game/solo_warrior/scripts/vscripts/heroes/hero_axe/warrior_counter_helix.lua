LinkLuaModifier( "modifier_axe_warrior_counter_helix", "heroes/hero_axe/warrior_counter_helix", LUA_MODIFIER_MOTION_NONE ) 

axe_warrior_counter_helix = class({})

function axe_warrior_counter_helix:GetAbilityTextureName()
	-- local caster = self:GetCaster()
	-- if caster:HasModifier("modifier_axe_berserk_form")  then
	-- 	return "axe/counter_helix_berserk"
	-- else
		return "axe/counter_helix"
	-- end
end

function axe_warrior_counter_helix:GetCastRange()
	return self:GetSpecialValueFor("trigger_chance")
end

function axe_warrior_counter_helix:GetIntrinsicModifierName()
	return "modifier_axe_warrior_counter_helix"
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
        } end,
})

function modifier_axe_warrior_counter_helix:OnAttackLanded( params )
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
			
			-- if caster:HasTalent("special_bonus_custom_axe_1") then
			-- 	trigger_chance = trigger_chance + caster:FindTalentValue("special_bonus_custom_axe_1")
			-- end
			
			-- if caster:HasTalent("special_bonus_custom_axe_2") then
			-- 	damage = damage*(100 + caster:FindTalentValue("special_bonus_custom_axe_2"))/100
			-- end

			if ability:IsCooldownReady() and RollPercentage(trigger_chance) then
				local data = {iFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES}
				local enemies = caster:FindEnemyUnitsInRadius(point, radius, data)
				ability:UseResources(true, true, true)
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
					DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
				end
			end
		end
    end
    return 0
end