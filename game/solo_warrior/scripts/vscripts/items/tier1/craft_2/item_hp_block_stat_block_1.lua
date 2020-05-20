LinkLuaModifier("modifier_item_hp_block_stat_block_1", "items/tier1/craft_2/item_hp_block_stat_block_1", LUA_MODIFIER_MOTION_NONE)

item_hp_block_stat_block_1 = class({})

function item_hp_block_stat_block_1:GetIntrinsicModifierName()
	return "modifier_item_hp_block_stat_block_1"
end

item_hp_block_stat_block_1_1 = class(item_hp_block_stat_block_1)
item_hp_block_stat_block_1_2 = class(item_hp_block_stat_block_1)

modifier_item_hp_block_stat_block_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}end,
})

function modifier_item_hp_block_stat_block_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_hp_block_stat_block_1:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_hp_block_stat_block_1:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_stat")
end

function modifier_item_hp_block_stat_block_1:GetModifierTotal_ConstantBlock()
	return self:GetAbility():GetSpecialValueFor("abs_block")
end
function modifier_item_hp_block_stat_block_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_hp_block_stat_block_1:GetModifierPhysical_ConstantBlock()
	return self:GetAbility():GetSpecialValueFor("bonus_block")
end

function modifier_item_hp_block_stat_block_1:OnAttackLanded(data)
	local target = data.target
	local parent = self:GetParent()

	if target==parent and parent:IsAlive() then
		local ability = self:GetAbility()
		local heal_per_attack = ability:GetSpecialValueFor("heal_per_attack")

		parent:Heal(heal_per_attack, ability)
		local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

	end

end
