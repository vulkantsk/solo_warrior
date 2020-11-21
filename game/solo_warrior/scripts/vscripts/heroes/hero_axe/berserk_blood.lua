
LinkLuaModifier( "modifier_axe_berserk_blood", "heroes/hero_axe/berserk_blood", LUA_MODIFIER_MOTION_NONE )

axe_berserk_blood = class({})

function axe_berserk_blood:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_axe_berserk_blood", {duration = self:GetSpecialValueFor("duration")})
end

--------------------------------------------------------------------------------

modifier_axe_berserk_blood = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		} end,
})

function modifier_axe_berserk_blood:OnCreated()
	local ability = self:GetAbility()
	self.attack_speed = ability:GetSpecialValueFor("attack_speed")
    self.move_speed = ability:GetSpecialValueFor("move_speed")
    if IsServer() then
        local caster = self:GetCaster()
        self:SetStackCount(math.floor((100-caster:GetHealth()/caster:GetMaxHealth()*100)/(ability:GetSpecialValueFor("prc_health_for_bonus"))))
    end
end

function modifier_axe_berserk_blood:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed * self:GetStackCount()
end

function modifier_axe_berserk_blood:GetModifierMoveSpeedBonus_Constant()
	return self.move_speed * self:GetStackCount()
end