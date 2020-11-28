
LinkLuaModifier( "modifier_axe_warrior_form", "heroes/hero_axe/warrior_form", LUA_MODIFIER_MOTION_NONE )

axe_warrior_form = class({})

function axe_warrior_form:OnSpellStart()	
    if IsServer() then
		local caster = self:GetCaster()
		local abils = {
			"axe_culling_blade_custom",
			"axe_berserk_blood",
			"axe_berserk_counter_helix",
			"axe_berserk_form",
			"axe_true_punch",
			"axe_last_chance",
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
        caster:RemoveModifierByName("modifier_axe_warrior_form")
		caster:AddNewModifier(caster, nil, "modifier_axe_berserkers_call_armor", nil)
        caster:CalculateStatBonus()
        caster:EmitSound("axe_jung_axe_spawn_0"..RandomInt(1, 9))
	end
end

--------------------------------------------------------------------------------

modifier_axe_warrior_form = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		} end,
})

function modifier_axe_warrior_form:OnCreated()
	local ability = self:GetAbility()
	self.health = ability:GetSpecialValueFor("health")
	self.armor = ability:GetSpecialValueFor("armor")
end

function modifier_axe_warrior_form:GetModifierHealthBonus()
	return self.health
end

function modifier_axe_warrior_form:GetModifierPhysicalArmorBonus()
	return self.armor
end