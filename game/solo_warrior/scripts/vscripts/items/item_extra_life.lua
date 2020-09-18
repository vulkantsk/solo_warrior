item_extra_life = class({})

function item_extra_life:OnSpellStart()
	local caster = self:GetCaster()

	local life_modifier = caster:AddNewModifier(caster, nil, "modifier_extra_life", nil)
	life_modifier:IncrementStackCount()
	self:SpendCharge()
end