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
			"axe_blood_bath",
			"axe_power_of_pain",
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
        caster:RemoveModifierByName("modifier_axe_berserk_form")
        caster:RemoveModifierByName("modifier_axe_berserkers_call_armor")
        caster:EmitSound("axe_axe_spawn_0"..RandomInt(1, 9))
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)

        local warrior_form = caster:FindAbilityByName("axe_warrior_form")
        caster:AddNewModifier(caster, warrior_form, "modifier_axe_warrior_form", nil)
        caster:CalculateStatBonus(true)
	end
end

--------------------------------------------------------------------------------

modifier_axe_berserk_form = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		} end,
})

function modifier_axe_berserk_form:OnCreated()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	self.bat = ability:GetSpecialValueFor("bat")
	self.move_speed = ability:GetSpecialValueFor("move_speed")
	self.bat_ptp = ability:GetSpecialValueFor("bat_per_tp")
	self.move_speed_ptp = ability:GetSpecialValueFor("move_speed_per_tp")

	if IsServer() then
		if self.item == nil and caster:GetUnitName()=="npc_dota_hero_axe" then
			local model = "models/items/axe/ti9_jungle_axe/ti9_jungle_axe_belt.vmdl"
			self.item = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model})
			Timers:CreateTimer(0.01,function () self.item:FollowEntity(caster, true) end)
		end
	
		self:SetStackCount(TalentTree:GetColumnTalentPoints(self:GetCaster(), 2))
		self:StartIntervalThink(1)
	end
end

function modifier_axe_berserk_form:OnDestroy()
	if self.item then
		self.item:RemoveSelf()
		self.item = nil
	end
end

function modifier_axe_berserk_form:OnIntervalThink()
	if IsServer() then
		local old_stack_count = self:GetStackCount()
		self:SetStackCount(TalentTree:GetColumnTalentPoints(self:GetCaster(), 2))
		if old_stack_count ~= self:GetStackCount() then
			self:GetCaster():CalculateStatBonus(true)
		end
		return 1
	end
end

function modifier_axe_berserk_form:GetModifierBaseAttackTimeConstant()
	return self.bat - self.bat_ptp * self:GetStackCount()
end

function modifier_axe_berserk_form:GetModifierMoveSpeedBonus_Constant()
	return self.move_speed + self.move_speed_ptp * self:GetStackCount()
end

function modifier_axe_berserk_form:GetModifierModelChange()
	return "models/items/axe/ti9_jungle_axe/axe_bare.vmdl"
end

function modifier_axe_berserk_form:GetAttackSound()
	return "Hero_Axe.Attack.Jungle"
end
