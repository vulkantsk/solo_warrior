LinkLuaModifier( "modifier_axe_true_punch", "heroes/hero_axe/true_punch", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_true_punch_crit", "heroes/hero_axe/true_punch", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_true_punch_debuff", "heroes/hero_axe/true_punch", LUA_MODIFIER_MOTION_NONE ) 

axe_true_punch = class({})

function axe_true_punch:OnSpellStart()	
    if IsServer() then
        local hTarget = self:GetCursorTarget()
        self:Punch(hTarget)
	end
end

function axe_true_punch:Punch(hTarget)
    if IsServer() then
        local caster = self:GetCaster()
        hTarget:EmitSound("Hero_Dark_Seer.NormalPunch.Lv"..RandomInt(2, 3))
       
        local effect = "particles/units/heroes/hero_dark_seer/dark_seer_attack_normal_punch.vpcf"
        local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(pfx, 1, hTarget:GetAbsOrigin())
        ParticleManager:SetParticleControl(pfx, 2, hTarget:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(pfx)

        if caster:HasTalent("talent_axe_berserk_punch_1") then
            local mod = hTarget:AddNewModifier(caster, self, "modifier_axe_true_punch_debuff", {duration = caster:FindTalentValue("talent_axe_berserk_punch_1", "duration")})
            mod:SetStackCount(caster:FindTalentValue("talent_axe_berserk_punch_1", "min_armor_prc"))
        end

        caster:AddNewModifier(caster, self, "modifier_axe_true_punch_crit", {duration = 0.01})
        caster:PerformAttack(hTarget, true, true, true, true, false, false, true)
        caster:RemoveModifierByName("modifier_axe_true_punch_crit")
--[[       
          local damageInfo = 
          {
              victim = hTarget,
              attacker = caster,
              damage = caster:GetAverageTrueAttackDamage(caster) * self:GetSpecialValueFor("crit"),
              damage_type = DAMAGE_TYPE_PHYSICAL,
              ability = self,
          }
          ApplyDamage( damageInfo )
  ]]
	end
end

function axe_true_punch:GetIntrinsicModifierName()
    if IsServer() then
        if self:GetCaster():HasTalent("talent_axe_berserk_punch_2") then
            return "modifier_axe_true_punch"
        end
    end
end

---------------------------------------------------------------------

modifier_axe_true_punch = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {           
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        } end,
})

function modifier_axe_true_punch:OnAttackLanded( params )
    if IsServer() then
    	local caster = self:GetCaster()
        if caster:HasTalent("talent_axe_berserk_punch_2") then
            if params.attacker == caster then--and not caster:PassivesDisabled()
                local mod = caster:FindModifierByName("modifier_axe_true_punch")
                local stacks = mod:GetStackCount()
                if stacks >= caster:FindTalentValue("talent_axe_berserk_punch_2", "attacks") then
                    self:GetAbility():Punch(params.target)
                    mod:SetStackCount(0)
                else
                    mod:SetStackCount(stacks+1)
                end
            end
        end
    end
    return 0
end


modifier_axe_true_punch_crit = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {           
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        } end,
})

function modifier_axe_true_punch_crit:GetModifierPreAttack_CriticalStrike()
    return self:GetAbility():GetSpecialValueFor("crit")
end
--------------------------------------------------------------------------------

modifier_axe_true_punch_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	DeclareFunctions		= function(self) return 
		{
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		} end,
})

function modifier_axe_true_punch_debuff:OnCreated( kv )
	self.nArmorReductionPerStack = self:GetParent():GetPhysicalArmorValue(false) / 100
end


function modifier_axe_true_punch_debuff:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount() * self.nArmorReductionPerStack
end
