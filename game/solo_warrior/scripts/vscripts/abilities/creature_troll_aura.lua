LinkLuaModifier("modifier_creature_troll_aura", "abilities/creature_troll_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_creature_troll_aura_aura", "abilities/creature_troll_aura", LUA_MODIFIER_MOTION_NONE)

creature_troll_aura = class({})

function creature_troll_aura:GetCastRAnge()
	return self:GetSpecialValueFor("aura_radius")
end

function creature_troll_aura:GetIntrinsicModifierName()
	return "modifier_creature_troll_aura"
end

modifier_creature_troll_aura = class({
	IsHidden 		= function(self) return true end,
	IsAura 			= function(self) return true end,
	GetAuraRadius 	= function(self) return self:GetAbility().aura_radius end,
	GetAuraSearchTeam = function(self) return DOTA_UNIT_TARGET_TEAM_FRIENDLY end,
	GetAuraSearchType = function(self) return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO end,
	GetModifierAura   = function(self) return "modifier_creature_troll_aura_aura" end,
})

function modifier_creature_troll_aura:OnCreated( kv )
	local ability = self:GetAbility()

	ability.aura_radius = ability:GetSpecialValueFor( "aura_radius" )
	ability.armor_aura = ability:GetSpecialValueFor( "armor_aura" )
	ability.health_regen_aura = ability:GetSpecialValueFor( "health_regen_aura" )
--	ability.mana_regen_aura = ability:GetSpecialValueFor( "mana_regen_aura" )
--	ability.damage_aura = ability:GetSpecialValueFor( "damage_aura" )
	ability.vampiric_aura = ability:GetSpecialValueFor( "vampiric_aura" )/100

	local effect = "particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf"
	local pfx = ParticleManager:CreateParticle(effect, PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 1, Vector( ability.aura_radius, ability.aura_radius, ability.aura_radius ) )
	ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	self:AddParticle(pfx, true, false, 0, true, false)
end

function modifier_creature_troll_aura:OnRefresh( kv )
	local ability = self:GetAbility()
	ability.armor_aura = ability:GetSpecialValueFor( "armor_aura" )
	ability.health_regen_aura = ability:GetSpecialValueFor( "health_regen_aura" )
	ability.vampiric_aura = ability:GetSpecialValueFor( "vampiric_aura" )/100
--	ability.mana_regen_aura = ability:GetSpecialValueFor( "mana_regen_aura" )
--	ability.damage_aura = ability:GetSpecialValueFor( "damage_aura" )
end

modifier_creature_troll_aura_aura = class({})

function modifier_creature_troll_aura_aura:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
--		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
--		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

----------------------------------------

function modifier_creature_troll_aura_aura:GetModifierConstantHealthRegen()
	return self:GetAbility().health_regen_aura
end

function modifier_creature_troll_aura_aura:GetModifierPhysicalArmorBonus()
	return self:GetAbility().armor_aura
end

function modifier_creature_troll_aura_aura:GetModifierConstantManaRegen()
	return self:GetAbility().mana_regen_aura
end

function modifier_creature_troll_aura_aura:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility().damage_aura
end

----------------------------------------

function modifier_creature_troll_aura_aura:OnTakeDamage( params )
	if IsServer() then
		local Target = params.unit
		local Attacker = params.attacker
		local ability = params.inflictor
		local flDamage = params.damage
		
		if Attacker ~= nil and Attacker == self:GetParent() and Target ~= nil and not Target:IsBuilding() and ability == nil then
			local heal =  flDamage * self:GetAbility().vampiric_aura
			Attacker:Heal( heal, self:GetAbility() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
	return 0
end
