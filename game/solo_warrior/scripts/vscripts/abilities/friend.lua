LinkLuaModifier("modifier_friend", "abilities/friend", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_friend_buff", "abilities/friend", LUA_MODIFIER_MOTION_NONE)

friend = class({})

function friend:GetCastRAnge()
	return self:GetSpecialValueFor("aura_radius")
end

function friend:GetIntrinsicModifierName()
	return "modifier_friend"
end

modifier_friend = class({
	IsHidden 		= function() return true end,
})

function modifier_friend:OnCreated( kv )
	local caster = self:GetCaster()
	local ability = self:GetAbility()

	caster:AddNewModifier(caster, ability, "modifier_friend_buff", hModifierTable)
end

modifier_friend_buff = class({
	IsHidden 		= function(self) return false end,
	IsPurgable 		= function(self) return false end,
})

function modifier_friend_buff:OnCreated( kv )
	local ability = self:GetAbility()

	self.search_radius = ability:GetSpecialValueFor( "search_radius" )
	self.search = true

--	local effect = "particles/generic_gameplay/generic_has_quest.vpcf"
--	self.pfx = ParticleManager:CreateParticle(effect, PATTACH_OVERHEAD_FOLLOW, self:GetCaster())

	self:StartIntervalThink(1)
end

function modifier_friend_buff:GetEffectName()
	return "particles/generic_gameplay/generic_has_quest.vpcf"
end

function modifier_friend_buff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_friend_buff:OnIntervalThink()
	if self.search then
		local caster = self:GetCaster()
		local point = caster:GetAbsOrigin()
		local team = caster:GetTeam()

		local friends = FindUnitsInRadius(team, point, nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_CLOSEST, false)
		for _,friend in pairs (friends) do
			if friend ~= caster then
--				print("friends near !")
				return
			end
		end		

		local enemies = FindUnitsInRadius(team, point, nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,FIND_CLOSEST, false)
		for _,enemy in pairs (enemies) do
			if enemy:IsRealHero() then
				local player_id = enemy:GetPlayerID()
				local player_team = enemy:GetTeam()
				caster:SetControllableByPlayer(player_id, false)
				caster:SetTeam(player_team)
				caster:SetOwner(enemy)

				self:Destroy()
--				self.search = false
--				ParticleManager:DestroyParticle(self.pfx, true)
--				ParticleManager:ReleaseParticleIndex(self.pfx)
			end
		end
	end
end
