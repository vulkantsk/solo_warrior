LinkLuaModifier( "modifier_axe_warrior_form", "heroes/hero_axe/warrior_form", LUA_MODIFIER_MOTION_NONE )

axe_warrior_form = class({})

function axe_warrior_form:Spawn()
    if IsServer() then
		Timers:CreateTimer(0, function()
			local caster = self:GetCaster()
			caster:AddNewModifier(caster, self, "modifier_axe_warrior_form", nil)
			caster:CalculateStatBonus(true)
		end)
	end
end

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
        caster:EmitSound("axe_jung_axe_spawn_0"..RandomInt(1, 9))
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

        local berserk_form = caster:FindAbilityByName("axe_berserk_form")
        caster:AddNewModifier(caster, berserk_form, "modifier_axe_berserk_form", nil)
		caster:AddNewModifier(caster, nil, "modifier_axe_berserkers_call_armor", nil)
        caster:CalculateStatBonus(true)
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
	self.health_ptp = ability:GetSpecialValueFor("health_per_tp")
	self.armor_ptp = ability:GetSpecialValueFor("armor_per_tp")

	if IsServer() then
		self:SetStackCount(TalentTree:GetColumnTalentPoints(self:GetCaster(), 1))
		self:StartIntervalThink(1)
	end
end

function modifier_axe_warrior_form:OnIntervalThink()
	if IsServer() then
		local old_stack_count = self:GetStackCount()
		self:SetStackCount(TalentTree:GetColumnTalentPoints(self:GetCaster(), 1))
		if old_stack_count ~= self:GetStackCount() then
			self:GetCaster():CalculateStatBonus(true)
		end
		return 1
	end
end

function modifier_axe_warrior_form:GetModifierHealthBonus()
	return self.health + self.health_ptp * self:GetStackCount()
end

function modifier_axe_warrior_form:GetModifierPhysicalArmorBonus()
	return self.armor + self.armor_ptp * self:GetStackCount()
end
