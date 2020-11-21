
LinkLuaModifier( "modifier_axe_berserk_form", "heroes/hero_axe/berserk_form", LUA_MODIFIER_MOTION_NONE )

axe_berserk_form = class({})

function axe_berserk_form:OnSpellStart()	
    if IsServer() then
		local caster = self:GetCaster()
		local abils = {
			"axe_warrior_wave",
			"axe_super_vitality",
			"axe_warrior_counter_helix",
			"axe_warrior_form",
			"axe_power_of_pain",
			"axe_blood_bath",
		}
		for i=0, 5 do
			local old_abil = caster:GetAbilityByIndex(i)
			local level = old_abil:GetLevel()
			local cooldown = old_abil:GetCooldownTimeRemaining()
			caster:RemoveAbilityByHandle(old_abil)
			local new_abil = caster:AddAbility(abils[i+1])
			new_abil:SetLevel(level)
			new_abil:StartCooldown(cooldown)
        end
	end
end

function axe_berserk_form:GetIntrinsicModifierName()
	return "modifier_axe_berserk_form"
end

--------------------------------------------------------------------------------

modifier_axe_berserk_form = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		} end,
})

function modifier_axe_berserk_form:OnCreated()
	local ability = self:GetAbility()
	self.bat = ability:GetSpecialValueFor("bat")
	self.move_speed = ability:GetSpecialValueFor("move_speed")
end

function modifier_axe_berserk_form:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_axe_berserk_form:GetModifierMoveSpeedBonus_Constant()
	return self.move_speed
end
