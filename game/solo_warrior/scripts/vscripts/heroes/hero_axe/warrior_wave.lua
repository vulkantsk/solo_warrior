LinkLuaModifier( "modifier_axe_warrior_wave_debuff", "heroes/hero_axe/warrior_wave", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_warrior_wave_buff", "heroes/hero_axe/warrior_wave", LUA_MODIFIER_MOTION_NONE )
axe_warrior_wave = class({})

function axe_warrior_wave:OnSpellStart()
	if IsServer() then
	
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
			
    if caster:HasTalent("talent_axe_warrior_wave_1") then
        if RollPercentage(caster:FindTalentValue("talent_axe_warrior_wave_1", "chance")) then
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

    caster:EmitSound("Hero_Magnataur.ShockWave.Particle.Anvil")
	
	end
end

function axe_warrior_wave:OnProjectileHit(hTarget, vLocation)
	if hTarget and IsServer() then
        local caster = self:GetCaster()
    	local damage = self:GetSpecialValueFor("damage")
        if caster:HasTalent("talent_axe_warrior_wave_2") and hTarget then
            hTarget:AddNewModifier(caster, self, "modifier_axe_warrior_wave_debuff", {duration = caster:FindTalentValue("talent_axe_warrior_wave_2", "duration")})
        end
        if caster:HasTalent("talent_axe_warrior_wave_3") then
            local buff = caster:AddNewModifier(caster, self, "modifier_axe_warrior_wave_buff", {duration = caster:FindTalentValue("talent_axe_warrior_wave_3", "duration")})
             buff:SetStackCount(buff:GetStackCount()+1)
        end
    	DealDamage(caster, hTarget, damage, DAMAGE_TYPE_MAGICAL, nil, self)
    end
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

function modifier_axe_warrior_wave_debuff:OnCreated(kv)
	self:SetHasCustomTransmitterData( true )
	self:OnRefresh( kv )
end

function modifier_axe_warrior_wave_debuff:OnRefresh(kv)
	if IsServer() then
		self.ms = (-1)*self:GetCaster():FindTalentValue("talent_axe_warrior_wave_2", "ms_debuff")
		self.as = (-1)*self:GetCaster():FindTalentValue("talent_axe_warrior_wave_2", "as_debuff")
		self:SendBuffRefreshToClients()
	end
end

function modifier_axe_warrior_wave_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_axe_warrior_wave_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_axe_warrior_wave_debuff:AddCustomTransmitterData( )
	return
	{
		ms = self.ms,
		as = self.as,
	}
end

function modifier_axe_warrior_wave_debuff:HandleCustomTransmitterData( data )
	if data.ms ~= nil then
		self.ms = tonumber( data.ms )
	end
	if data.as ~= nil then
		self.as = tonumber( data.as )
	end
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

function modifier_axe_warrior_wave_buff:OnCreated(kv)
	self:SetHasCustomTransmitterData( true )
	self:OnRefresh( kv )
end

function modifier_axe_warrior_wave_buff:OnRefresh(kv)
	if IsServer() then
		self.armor_bonus = self:GetCaster():FindTalentValue("talent_axe_warrior_wave_3", "armor_bonus")
		self:SendBuffRefreshToClients()
	end
end

function modifier_axe_warrior_wave_buff:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()*self.armor_bonus
end

--------------------------------------------------------------------------------

function modifier_axe_warrior_wave_buff:AddCustomTransmitterData( )
	return
	{
		armor = self.armor_bonus,
	}
end

function modifier_axe_warrior_wave_buff:HandleCustomTransmitterData( data )
	if data.armor ~= nil then
		self.armor_bonus = tonumber( data.armor )
	end
end