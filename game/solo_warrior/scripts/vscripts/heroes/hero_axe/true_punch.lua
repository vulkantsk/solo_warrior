axe_true_punch = class({})

function axe_true_punch:OnSpellStart()	
    if IsServer() then
        local caster = self:GetCaster()
		local hTarget = self:GetCursorTarget()

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