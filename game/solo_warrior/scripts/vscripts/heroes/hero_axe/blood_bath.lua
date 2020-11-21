axe_blood_bath = class({})

function axe_blood_bath:OnSpellStart()	
    if IsServer() then
        local caster = self:GetCaster()
		local hTarget = self:GetCursorTarget()
        local caster_health = caster:GetHealth()
        local caster_max_health = caster:GetMaxHealth()
        local hp_remain = self:GetSpecialValueFor("hp_remain")

        local damageInfo = 
        {
            victim = hTarget,
            attacker = caster,
            damage = caster_health * self:GetSpecialValueFor("multiplier"),
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = self,
        }
        ApplyDamage( damageInfo )

        local caster_damage = caster_health-(caster_max_health / 100 * hp_remain)
        if caster_damage > 0 then
            local damageInfo = 
            {
                victim = caster,
                attacker = caster,
                damage = caster_damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = self,
            }
            ApplyDamage( damageInfo )
        end
	end
end