LinkLuaModifier("modifier_test_ability", "abilities/test_ability", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_test_ability_buff", "abilities/test_ability", LUA_MODIFIER_MOTION_NONE)

test_ability = class({})

function test_ability:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_test_ability_buff", {duration = duration})
end

function test_ability:GetIntrinsicModifierName()
	return "modifier_test_ability"
end

modifier_test_ability = class({
	IsHidden 		= function(self) return false end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}end,
})

function modifier_test_ability:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_bonus")
end


modifier_test_ability_buff = class({
	IsHidden 		= function(self) return false end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}end,
})

function modifier_test_ability_buff:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("health_regen")
end

