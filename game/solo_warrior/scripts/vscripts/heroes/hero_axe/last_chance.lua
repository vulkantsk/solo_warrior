
LinkLuaModifier( "modifier_axe_last_chance", "heroes/hero_axe/last_chance", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_last_chance_buff", "heroes/hero_axe/last_chance", LUA_MODIFIER_MOTION_NONE )

axe_last_chance = class({})

function axe_last_chance:GetIntrinsicModifierName()
	return "modifier_axe_last_chance"
end

--------------------------------------------------------------------------------

modifier_axe_last_chance = class({
	IsHidden 				= function(self) return true end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
            MODIFIER_EVENT_ON_TAKEDAMAGE,
		} end,
})

function modifier_axe_last_chance:OnTakeDamage( params )
	if IsServer() then
        if params.unit == self:GetParent() then
            local ability = self:GetAbility()
            if params.unit:GetHealth() < 1 and ability:IsCooldownReady() then
                params.unit:SetHealth(1)
                params.unit:AddNewModifier(params.unit, ability, "modifier_axe_last_chance_buff", {duration = ability:GetSpecialValueFor("duration")})
				ability:UseResources(true, true, true)
            end
        end
	end
end

--------------------------------------------------------------------------------

modifier_axe_last_chance_buff = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		} end,
})

function modifier_axe_last_chance_buff:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end

function modifier_axe_last_chance_buff:OnCreated()
	local ability = self:GetAbility()
    self.bonus_move_speed = ability:GetSpecialValueFor("bonus_move_speed")
    self.bonus_attack_speed = ability:GetSpecialValueFor("bonus_attack_speed")
    self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")

    if IsServer() then
        self:StartIntervalThink(0.03)
    end
end

function modifier_axe_last_chance_buff:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), parent:GetCurrentVisionRange(), {order = FIND_CLOSEST})
        for _,enemy in pairs(enemies) do
            parent:MoveToTargetToAttack(enemy)
            return 0.03
        end
        return 0.03
    end
end

function modifier_axe_last_chance_buff:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_move_speed
end

function modifier_axe_last_chance_buff:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attack_speed
end

function modifier_axe_last_chance_buff:GetModifierBaseDamageOutgoing_Percentage()
	return self.bonus_damage
end