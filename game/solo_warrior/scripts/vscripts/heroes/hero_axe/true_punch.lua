LinkLuaModifier( "modifier_axe_true_punch", "heroes/hero_axe/true_punch", LUA_MODIFIER_MOTION_NONE ) 

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

        local damageInfo = 
        {
            victim = hTarget,
            attacker = caster,
            damage = caster:GetAverageTrueAttackDamage(caster) * self:GetSpecialValueFor("crit"),
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }
        ApplyDamage( damageInfo )
	end
end

function axe_true_punch:GetIntrinsicModifierName()
    if IsServer() then
        if caster:HasTalent("ability_talent_berserk_12") then
            return "modifier_axe_true_punch"
        end
    end
end

---------------------------------------------------------------------

modifier_axe_true_punch = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {           
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        } end,
})

function modifier_axe_true_punch:OnAttackLanded( params )
    if IsServer() then
    	local caster = self:GetCaster()
        if caster:HasTalent("ability_talent_berserk_12") then
            if params.attacker == caster then--and not caster:PassivesDisabled()
                local mod = caster:FindModifierByName("modifier_axe_true_punch")
                local stacks = mod:GetStackCount()
                if stacks >= caster:FindTalentValue("ability_talent_berserk_12", "attacks") then
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