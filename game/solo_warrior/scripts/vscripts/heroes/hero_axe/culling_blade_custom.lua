
LinkLuaModifier( "modifier_axe_culling_blade_custom", "heroes/hero_axe/culling_blade_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_culling_blade_debuff", "heroes/hero_axe/culling_blade_custom", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_culling_blade_duel", "heroes/hero_axe/culling_blade_custom", LUA_MODIFIER_MOTION_NONE )

axe_culling_blade_custom = class({})

-- function axe_culling_blade_custom:GetAOERadius()
--	return self:GetSpecialValueFor("radius")
-- end

function axe_culling_blade_custom:OnSpellStart()
	if IsServer() then
	
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = target:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local kill_threshold = self:GetSpecialValueFor("kill_threshold")
	local bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.sound = "Hero_Axe.Culling_Blade_Fail"

	if caster:HasTalent("talent_axe_berserk_culblade_1") then
		damage = damage + caster:GetAverageTrueAttackDamage(caster)
	end

	FindClearSpaceForUnit(caster, point, true)
	if target:GetHealth() < kill_threshold then
		self:KillTarget(target)
		if target:IsConsideredHero() then
			 local modifier = caster:AddNewModifier(caster, self, "modifier_axe_culling_blade_custom", {})
			 local current_stack = modifier:GetStackCount()
			 modifier:SetStackCount(current_stack + bonus_damage)
		end
	else
		DealDamage(caster, target, damage, DAMAGE_TYPE_PHYSICAL, nil, ability)
		if caster:HasTalent("talent_axe_berserk_culblade_2") then
			self.duel_target = target
			caster:AddNewModifier(caster, self, "modifier_axe_culling_blade_duel", {duration = caster:FindTalentValue("talent_axe_berserk_culblade_2", "duration")})
            target:MoveToTargetToAttack(caster)
		end
	end
--[[
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
	]]	
	caster:EmitSound(self.sound)
	
	end
end

function axe_culling_blade_custom:KillTarget(enemy)
	if IsServer() then

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

	if caster:HasTalent("talent_axe_berserk_culblade_3") then
		local point = caster:GetAbsOrigin()
		local enemies = caster:FindEnemyUnitsInRadius(point, caster:FindTalentValue("talent_axe_berserk_culblade_3", "radius"), nil)
		
		for _,enemy in pairs(enemies) do
			local modifier = enemy:AddNewModifier(caster, self, "modifier_axe_culling_blade_debuff", {duration = caster:FindTalentValue("talent_axe_berserk_culblade_3", "duration")})
			modifier:SetStackCount(caster:FindTalentValue("talent_axe_berserk_culblade_3", "min_armor"))
		end
	end
	
	end
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

--------------------------------------------------------------------------------

modifier_axe_culling_blade_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		} end,
})


function modifier_axe_culling_blade_debuff:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end

--------------------------------------------------------------------------------

modifier_axe_culling_blade_duel = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
})

function modifier_axe_culling_blade_duel:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end

function modifier_axe_culling_blade_duel:OnCreated(kv)
	local ability = self:GetAbility()
	self.kill_threshold = ability:GetSpecialValueFor("kill_threshold")

	if IsServer() then
		if ability.duel_target and ability.duel_target:IsAlive() then
			self.duel_target = ability.duel_target
			self:GetParent():MoveToTargetToAttack(self.duel_target)
			self:StartIntervalThink(0.1)
		else
			self:Destroy()
		end
    end
end

function modifier_axe_culling_blade_duel:OnIntervalThink()
	if IsServer() then
		if self.duel_target and self.duel_target:IsAlive() then
			if self.duel_target:GetHealth() < self.kill_threshold then
				self:GetAbility():KillTarget(self.duel_target)
				self:Destroy()
			end
		else
			self:Destroy()
		end
        return 0.1
    end
end