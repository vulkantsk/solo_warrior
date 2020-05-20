LinkLuaModifier( "modifier_undestructible_gate",			"abilities/gate/undestructible_gate",    		LUA_MODIFIER_MOTION_NONE )

undestructible_gate = class({})

function undestructible_gate:GetIntrinsicModifierName()
	return "modifier_undestructible_gate"
end

modifier_undestructible_gate = class({})

--------------------------------------------------------------------------------

function modifier_undestructible_gate:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_undestructible_gate:CanParentBeAutoAttacked()
	return false
end

--------------------------------------------------------------------------------

function modifier_undestructible_gate:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

--------------------------------------------------------------------------------

function modifier_undestructible_gate:OnCreated( kv )
	if IsServer() then
		self.hGate = self:GetParent().hGate
		self.attacks_required = self:GetAbility():GetSpecialValueFor("attacks_required")
		self.attacks_taken = 0

		if self:GetParent():GetUnitName() == "npc_gate_destructible_tier1" then
			self.szDamageSound = "Gate.Tier1.Damage"
			self.szDestroySound = "Gate.Tier1.Destroy"
		elseif self:GetParent():GetUnitName() == "npc_gate_destructible_tier2" then
			self.szDamageSound = "Gate.Tier2.Damage"
			self.szDestroySound = "Gate.Tier2.Destroy"
		elseif self:GetParent():GetUnitName() == "npc_gate_destructible_tier3" then
			self.szDamageSound = "Gate.Tier3.Damage"
			self.szDestroySound = "Gate.Tier3.Destroy"
		end
	end
end

--------------------------------------------------------------------------------

function modifier_undestructible_gate:CheckState()
	local state = {}
	state[MODIFIER_STATE_ROOTED] = true
	state[MODIFIER_STATE_BLIND] = true
	state[MODIFIER_STATE_MAGIC_IMMUNE] = true
	state[MODIFIER_STATE_ATTACK_IMMUNE] = true
	state[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	state[MODIFIER_STATE_NOT_ON_MINIMAP] = true

	return state
end

--------------------------------------------------------------------------------

function modifier_undestructible_gate:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

-----------------------------------------------------------------------

function modifier_undestructible_gate:OnDeath( params )
	if IsServer() then
		if params.unit == self:GetParent() and not self:GetParent():IsNull() then
--			assert ( self.szDestroySound ~= nil, "ERROR: modifier_undestructible_gate - self.szDestroySound is nil" )

			if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
				EmitSoundOn( self.szDestroySound, self:GetParent() )
			end

			local radius = 400
			self:PlayDustParticle( radius )

			-- Scale the ScreenShake amplitude and duration based on the level of the gate
			local nLevel = self:GetParent():GetLevel()
			local fShakeAmt = 15 * nLevel
			local fShakeDuration = 0.75 * nLevel

			--"Start a screenshake with the following parameters. vecCenter, flAmplitude, flFrequency, flDuration, flRadius, eCommand( SHAKE_START = 0, SHAKE_STOP = 1 ), bAirShake"
			ScreenShake( self:GetParent():GetOrigin(), fShakeAmt, 100.0, fShakeDuration, 1300.0, 0, true )

--			self.hGate:SetObstructions( false ) -- change this to setpath open?

			local szGateWithAnim = self:GetParent():GetUnitName() .. "_anim"
			local hAnimGate = CreateUnitByName( szGateWithAnim, self:GetParent():GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS )
			local vGateAngles = self:GetParent():GetAnglesAsVector()
			if hAnimGate == nil then
				printf( "ERROR: modifier_undestructible_gate:OnDeath -- hAnimGate is nil." )
				return
			end
			hAnimGate:SetAngles( vGateAngles.x, vGateAngles.y, vGateAngles.z )
--			hAnimGate.hGate = self.hGate
			GameMode.exit_gate = hAnimGate

			self:GetParent():AddNoDraw()
--			UTIL_Remove( self:GetParent() )
		end
	end
end

-----------------------------------------------------------------------

function modifier_undestructible_gate:GetModifierProvidesFOWVision( params )
	return 1
end

------------------------------------------------------------

function modifier_undestructible_gate:GetAbsoluteNoDamagePhysical( params )
	return 1
end

function modifier_undestructible_gate:GetAbsoluteNoDamageMagical( params )
	return 1
end

------------------------------------------------------------

function modifier_undestructible_gate:GetAbsoluteNoDamagePure( params )
	return 1
end

------------------------------------------------------------

function modifier_undestructible_gate:OnAttacked( params )
	if IsServer() then
		local parent = self:GetParent()
		if params.target == parent and params.attacker:IsRealHero() then
			assert ( self.szDamageSound ~= nil, "ERROR: modifier_undestructible_gate - self.szDamageSound is nil" )

			EmitSoundOn( self.szDamageSound, parent )

			-- The base_dust_hit particle we're currently using doesn't scale itself based on passed radius, so this scaling isn't doing anything
			self.attacks_taken = self.attacks_taken + 1
			if self.attacks_taken == self.attacks_required then
				parent:Kill(nil, params.attacker)
			else
				local fHealthPct = (self.attacks_required - self.attacks_taken)/self.attacks_required
				parent:SetHealth(parent:GetMaxHealth()*fHealthPct)

				local fRadiusMultiplier = 1 - fHealthPct 
				local radius = 300 * fRadiusMultiplier

				self:PlayDustParticle( radius )
			end
		end
	end

	return 1
end

------------------------------------------------------------

function modifier_undestructible_gate:PlayDustParticle( radius )
	local vPos = self:GetParent():GetOrigin()
	vPos.z = vPos.z + 100

	local nFXIndex = ParticleManager:CreateParticle( "particles/dev/library/base_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, vPos )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

------------------------------------------------------------
