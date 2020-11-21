
LinkLuaModifier( "modifier_axe_culling_blade_custom", "heroes/hero_axe/culling_blade_custom", LUA_MODIFIER_MOTION_NONE )

axe_culling_blade_custom = class({})

function axe_culling_blade_custom:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function axe_culling_blade_custom:GetAbilityTextureName()
	-- local caster = self:GetCaster()
	-- if caster:HasModifier("modifier_axe_berserk_form")  then
	-- 	return "axe/culling_blade_berserk"
	-- else
		return "axe/culling_blade"
	-- end
end

function axe_culling_blade_custom:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = target:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local kill_threshold = self:GetSpecialValueFor("kill_threshold")
	local bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.sound = "Hero_Axe.Culling_Blade_Fail"

	FindClearSpaceForUnit(caster, point, true)
	local enemies = caster:FindEnemyUnitsInRadius(point, radius, nil)

	for _,enemy in pairs(enemies) do
		if enemy:GetHealth() < kill_threshold then
			self:KillTarget(enemy)
			-- local modifier = caster:AddNewModifier(caster, self, "modifier_axe_culling_blade_custom", {})
			-- local current_stack = modifier:GetStackCount()
			-- modifier:SetStackCount(current_stack + bonus_damage)
		else
			DealDamage(caster, enemy, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
		end
	end
	caster:EmitSound(self.sound)
end

function axe_culling_blade_custom:KillTarget(enemy)
	local caster = self:GetCaster()
	enemy:Kill(self, caster)
	local target_location = enemy:GetAbsOrigin()
	self.sound = "Hero_Axe.Culling_Blade_Success"

	local effect = "particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(pfx, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(pfx, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(pfx, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:ReleaseParticleIndex(pfx)
end
--------------------------------------------------------------------------------

modifier_axe_culling_blade_custom = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		} end,
})


function modifier_axe_culling_blade_custom:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
