LinkLuaModifier("modifier_item_block_1", "items/tier1/baseitem/item_block_1", LUA_MODIFIER_MOTION_NONE)

item_block_1 = class({})

function item_block_1:GetIntrinsicModifierName()
	return "modifier_item_block_1"
end

item_block_1_1 = class(item_block_1)
item_block_1_2 = class(item_block_1)
item_block_1_3 = class(item_block_1)

modifier_item_block_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}end,
})

function modifier_item_block_1:GetModifierPhysical_ConstantBlock()
	return self:GetAbility():GetSpecialValueFor("bonus_value")
end