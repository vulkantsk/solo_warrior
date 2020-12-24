LinkLuaModifier("modifier_item_dmg_armor_1", "items/tier1/craft_1/item_dmg_armor_1", LUA_MODIFIER_MOTION_NONE)

item_dmg_armor_1 = class({})

function item_dmg_armor_1:GetIntrinsicModifierName()
	return "modifier_item_dmg_armor_1"
end

item_dmg_armor_1_1 = class(item_dmg_armor_1)
item_dmg_armor_1_2 = class(item_dmg_armor_1)
item_dmg_armor_1_3 = class(item_dmg_armor_1)

modifier_item_dmg_armor_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}end,
})

function modifier_item_dmg_armor_1:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_dmg_armor_1:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_dmg_armor_1:OnCreated()
	self:GetParent():EmitSound("DOTA_Item.BladeMail.Activate")
end

function modifier_item_dmg_armor_1:OnTakeDamage(data)
	local parent = self:GetParent()
	local attacker = data.attacker
	local unit = data.unit
	local original_damage  = data.original_damage 
	local damage_flags = data.damage_flags
	local damage_type = data.damage_type

	if unit == parent and unit:IsAlive() and attacker:GetTeam() ~= unit:GetTeam() then
		if bit.band( damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
			return 0
		end		
		--print("Reflected " .. damage .. " damage from " .. victim:GetUnitName() .. " to " .. attacker:GetUnitName())
		local ability = self:GetAbility()
		local dmg_return_pct = ability:GetSpecialValueFor("dmg_return_pct")/100
		local damage = original_damage*dmg_return_pct

		--unit:EmitSound("DOTA_Item.BladeMail.Damage")
		ApplyDamage({
			victim = attacker,
			attacker = unit,
			damage = damage,
			damage_type = damage_type,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_REFLECTION,
			ability = ability
		})
		return true
	end
	return false
		
end

function modifier_item_dmg_armor_1:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end
