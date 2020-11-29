LinkLuaModifier( "modifier_axe_warrior_wave_debuff", "heroes/hero_axe/warrior_wave", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_warrior_wave_buff", "heroes/hero_axe/warrior_wave", LUA_MODIFIER_MOTION_NONE )
axe_warrior_wave = class({})

function axe_warrior_wave:OnSpellStart()
	local caster = self:GetCaster()
	local casterOrigin = caster:GetAbsOrigin()
	local point = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local range = self:GetSpecialValueFor("range")
	local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    
    local direction = point - casterOrigin
    direction.z = 0.0
    direction = direction:Normalized()
    local info = 
    {
        Ability = self,
        EffectName = "particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil.vpcf",
        vSpawnOrigin = casterOrigin,
        fDistance = range,
        fStartRadius = radius,
        fEndRadius = radius,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit = false,
        vVelocity = direction * projectile_speed,
        bProvidesVision = false
    }
    ProjectileManager:CreateLinearProjectile(info)
			
    if caster:HasTalent("ability_talent_warrior_3") then
        if RollPercentage(caster:FindTalentValue("ability_talent_warrior_3", "chance")) then
            local locPos = Vector( 0, 0.5*(casterOrigin - point):Length2D(), 0 )
            local relPos = RotatePosition( Vector(0,0,0), caster:GetAngles(), locPos )
            local absPos = GetGroundPosition( relPos + point, caster )
            local direction = absPos - casterOrigin
            direction.z = 0.0
            direction = direction:Normalized()
            info.vVelocity = direction * projectile_speed
            ProjectileManager:CreateLinearProjectile(info)

            relPos = RotatePosition( Vector(0,0,0), caster:GetAngles(), locPos * -1 )
            local absPos = GetGroundPosition( relPos + point, caster )
            local direction = absPos - casterOrigin
            direction.z = 0.0
            direction = direction:Normalized()
            info.vVelocity = direction * projectile_speed
            ProjectileManager:CreateLinearProjectile(info)
        end
    end
end

function axe_warrior_wave:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
    if caster:HasTalent("ability_talent_warrior_9") then
        hTarget:AddNewModifier(caster, self, "modifier_axe_warrior_wave_debuff", {duration = 4})
    end
    if caster:HasTalent("ability_talent_warrior_12") then
        if caster:HasModifier("modifier_axe_warrior_wave_buff") then
            local buff = caster:FindModifierByName("modifier_axe_warrior_wave_buff")
            buff:SetStackCount(buff:GetStackCount()+1)
        else
            local buff = caster:AddNewModifier(caster, self, "modifier_axe_warrior_wave_buff", {duration = 7})
            buff:SetStackCount(1)
        end
    end
	DealDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, nil, self)
end

--------------------------------------------------------------------------------

modifier_axe_warrior_wave_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		} end,
})

function modifier_axe_warrior_wave_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -20
end

function modifier_axe_warrior_wave_debuff:GetModifierAttackSpeedBonus_Constant()
	return -30
end

--------------------------------------------------------------------------------

modifier_axe_warrior_wave_buff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		} end,
})

function modifier_axe_warrior_wave_buff:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()
end