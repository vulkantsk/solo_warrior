LinkLuaModifier("modifier_item_hp_stat_1", "items/tier1/craft_1/item_hp_stat_1", LUA_MODIFIER_MOTION_NONE)

item_hp_stat_1 = class({})

function item_hp_stat_1:GetIntrinsicModifierName()
	return "modifier_item_hp_stat_1"
end

item_hp_stat_1_1 = class(item_hp_stat_1)
item_hp_stat_1_2 = class(item_hp_stat_1)
item_hp_stat_1_3 = class(item_hp_stat_1)

modifier_item_hp_stat_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}end,
})

function modifier_item_hp_stat_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_hp_stat_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_hp_stat_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_hp_stat_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_hp_stat_1:OnTakeDamage( data )
	if IsServer() then
		local Attacker = data.attacker
		local Target = data.unit
		local Ability = data.inflictor
		local flDamage = data.damage

		if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
			return 0
		end

		if bit.band( data.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
			return 0
		end
		if bit.band( data.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL ) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
			return 0
		end
		
		local ability = self:GetAbility()
		local spell_lifesteal_pct = ability:GetSpecialValueFor("spell_lifesteal_pct")/100

		local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		local flLifesteal = flDamage * spell_lifesteal_pct
		Attacker:Heal( flLifesteal, ability )
	end
	return 0
end