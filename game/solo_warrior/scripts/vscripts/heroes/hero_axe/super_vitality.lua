LinkLuaModifier( "modifier_axe_super_vitality", "heroes/hero_axe/super_vitality", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_axe_super_vitality_buff", "heroes/hero_axe/super_vitality", LUA_MODIFIER_MOTION_NONE )

axe_super_vitality = class({})

function axe_super_vitality:OnSpellStart()
	local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_axe_super_vitality", {duration = self:GetSpecialValueFor("duration")})
    caster:EmitSound("Hero_Axe.BerserkersCall.Item.Shoutmask")
			
	if caster:HasTalent("talent_axe_warrior_vitality_1") then
		caster:Purge(false, true, false, false, false)
	end
end

--------------------------------------------------------------------------------

modifier_axe_super_vitality = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	DeclareFunctions		= function(self) return 
		{
            MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		} end,
})

function modifier_axe_super_vitality:OnCreated()
	local ability = self:GetAbility()
	self.regen = ability:GetSpecialValueFor("regen")/100
    self.bonus_regen = ability:GetSpecialValueFor("bonus_regen")/100
	self.buff_duration = ability:GetSpecialValueFor("buff_duration")
   	self.caster = self:GetCaster()
   	self.taken_damage = 0
 
	if IsServer() then
 
		self.status_res = ability:GetSpecialValueFor("status_res")

--		if self.caster:HasTalent("talent_axe_warrior_vitality_2") then
--			self.status_res = self.status_res * (1+ self.caster:FindTalentValue("talent_axe_warrior_vitality_2", "bonus_prc")/100)
--		end
		
		self:StartIntervalThink(0.1)
	end
end

function modifier_axe_super_vitality:OnDestroy()
	if IsServer() then
		print("taken damage = "..self.taken_damage)
		self:GetCaster().total_damage = self.taken_damage
		local regen_buff = self.caster:AddNewModifier(self.caster, self:GetAbility(), "modifier_axe_super_vitality_buff", {duration = self.buff_duration})
		regen_buff:SetStackCount(self.taken_damage)
	end
end

function modifier_axe_super_vitality:OnTakeDamage( params )
    if params.unit == self:GetParent() then
		self.taken_damage = self.taken_damage + params.damage
    end
end

function modifier_axe_super_vitality:CheckState()
	if IsServer() then
		return {
			[MODIFIER_STATE_ROOTED] = self.caster:HasTalent("talent_axe_warrior_vitality_2"),
		}
	end
end

function modifier_axe_super_vitality:OnIntervalThink()
	if IsServer() then
		if self.caster:HasTalent("talent_axe_warrior_vitality_4") then
			self.caster:Purge(false, true, false, false, false)
		end
	end
end

function modifier_axe_super_vitality:GetEffectName()
	return "particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger.vpcf"
end

function modifier_axe_super_vitality:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_axe_super_vitality_buff = class({
	IsHidden 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
 			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
 			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		} end,
})

function modifier_axe_super_vitality_buff:GetModifierConstantHealthRegen()
	return self:GetStackCount()*self.regen
end

function modifier_axe_super_vitality_buff:GetModifierHealthRegenPercentage()
	if self:GetCaster():HasTalent("talent_axe_warrior_vitality_3") then
		return self:GetCaster():FindTalentValue("talent_axe_warrior_vitality_3", "regen_pct")
	end
end

function modifier_axe_super_vitality_buff:OnCreated(data)
--	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		print("total damage = ".. self:GetStackCount())
		self.regen = ability:GetSpecialValueFor("damage_convert")/100 /ability:GetSpecialValueFor("buff_duration")
		self.regen_pct = 0
		caster:EmitSound("Rune.Regen")

		if caster:HasTalent("talent_axe_warrior_vitality_2") then
			self.regen = self.regen * (1+ caster:FindTalentValue("talent_axe_warrior_vitality_2", "bonus_prc")/100)
		end

--	end
end

function modifier_axe_super_vitality_buff:OnRefresh()
	self:OnCreated()
end

function modifier_axe_super_vitality_buff:GetEffectName()
	return "particles/generic_gameplay/rune_regen_owner.vpcf"
end
