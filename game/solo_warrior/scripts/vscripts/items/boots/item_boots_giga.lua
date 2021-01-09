function Damage(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local damage = caster:GetHealth() / 100 * tonumber(ability:GetSpecialValueFor("damage"))
	
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		ability = ability,
	})
end
