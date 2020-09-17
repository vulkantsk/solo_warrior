LinkLuaModifier( "modifier_axe_counter_helix_custom", "heroes/hero_axe/counter_helix_custom", LUA_MODIFIER_MOTION_NONE ) 

axe_counter_helix_custom = class({})

function axe_counter_helix_custom:GetAbilityTextureName()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_axe_berserk_form")  then
		return "axe/counter_helix_berserk"
	else
		return "axe/counter_helix"
	end
end

function axe_counter_helix_custom:GetCastRange()
	return self:GetSpecialValueFor("trigger_chance")
end

function axe_counter_helix_custom:GetIntrinsicModifierName()
	return "modifier_axe_counter_helix_custom"
end

modifier_axe_counter_helix_custom = class({
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

function modifier_axe_counter_helix_custom:OnAttackLanded( params )
    if IsServer() then
    	local caster = self:GetCaster()

		if params.target == caster and not caster:PassivesDisabled() then
			local ability = self:GetAbility()
			local trigger_chance = ability:GetSpecialValueFor("trigger_chance")
			local radius = ability:GetSpecialValueFor("radius")
			local base_damage =ability:GetSpecialValueFor("base_damage")
			local attack_damage =ability:GetSpecialValueFor("attack_damage")/100
			local damage = base_damage + caster:GetAverageTrueAttackDamage(caster)*attack_damage
			local point = caster:GetAbsOrigin()
			
			if caster:HasTalent("special_bonus_custom_axe_1") then
				trigger_chance = trigger_chance + caster:GetSpecialValueForTalent("special_bonus_custom_axe_1")
			end
			
			if caster:HasTalent("special_bonus_custom_axe_2") then
				base_damage = base_damage + caster:GetSpecialValueForTalent("special_bonus_custom_axe_2")
			end

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


