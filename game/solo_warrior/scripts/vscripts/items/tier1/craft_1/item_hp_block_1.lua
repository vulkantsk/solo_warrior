LinkLuaModifier("modifier_item_hp_block_1", "items/tier1/craft_1/item_hp_block_1", LUA_MODIFIER_MOTION_NONE)

item_hp_block_1 = class({})

function item_hp_block_1:GetIntrinsicModifierName()
	return "modifier_item_hp_block_1"
end

item_hp_block_1_1 = class(item_hp_block_1)
item_hp_block_1_2 = class(item_hp_block_1)

modifier_item_hp_block_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}end,
})

function modifier_item_hp_block_1:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_hp")
end

function modifier_item_hp_block_1:GetModifierPhysical_ConstantBlock()
	return self:GetAbility():GetSpecialValueFor("bonus_block")
end

function modifier_item_hp_block_1:OnAttackLanded(data)
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
