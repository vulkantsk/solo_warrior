if GameSpawner == nil then
	_G.GameSpawner = class({})
end

GameSpawner.exit_gate =nil
GameSpawner.current_units = {}
GameSpawner.line_interval = {}
GameSpawner.wave_index = 0

GameSpawner.wave_list = {
	[1]={reward_gold=250,reward_exp=500,
			units={["npc_line_creep_1"]=4,["npc_line_creep_2"]=4}},
	[2]={reward_gold=500,reward_exp=1000,
			units={["npc_line_creep_3"]=4,["npc_line_creep_4"]=4}},
	[3]={reward_gold=750,reward_exp=1500,
			units={["npc_line_boss_1"]=1,["npc_line_creep_4"]=4}},
	[4]={reward_gold=1000,reward_exp=2000,
			units={["npc_line_boss_1"]=8}},
}

function GameSpawner:InitGameSpawner()
	print("vse ok - ?")
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
end

function GameSpawner:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

	end
end

function GameSpawner:SpawnUnits(index)
	print("index = "..index)
	local current_wave = self.wave_list[index]
	if current_wave == nil then
		print("wave not found !")
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		return
	end

	local points = Entities:FindAllByName("spawner_point_"..index)
	local units = current_wave.units

--	GameRules:SendCustomMessage("#Game_notification_boss_spawn_"..boss_name,0,0)

	for key, value in pairs (units) do
		local unit_name
		if type(key) == "string" then
			unit_count = value
			unit_name = key
		else
			unit_count =1
			unit_name = value
		end

		for i=1, unit_count do			
			local point = points[RandomInt(1,#points)]:GetAbsOrigin() 
			local unit = CreateUnitByName( unit_name , point + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS ) 
			unit:SetInitialGoalEntity( waypoint )
			unit.reward = true
			local ent_index = unit:entindex()
--			table.insert(self.current_units, ent_index, unit)
			self.current_units[ent_index]= unit
		end
	end 
end

function GameSpawner:OnNPCSpawned(keys)
--	print("[BAREBONES] NPC Spawned")
--	DeepPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()
	
	if npc:IsRealHero() and npc.bbFirstSpawned == nil then
--		GameSpawner:OnHeroInGame(npc)			
		npc.bbFirstSpawned = true
		local playerID = npc:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)
		
		Timers:CreateTimer(0,function() 
			local item = npc:FindItemInInventory("item_tpscroll")
			if item then
				print("item_find!")
			else
				print("item dont exist!")
			end
			item:RemoveSelf()

			local ability = npc:GetAbilityByIndex(3)
			ability:SetLevel(1)
		end)
	end
end

function GameSpawner:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)
	local unit_name = unit:GetUnitName()
	
	if unit_name == "npc_goodguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)		
	end

	if unit.reward then
		local ent_index = unit:entindex()
		
		self.current_units[ent_index] = nil
		local units = 0
		for key,value in pairs(self.current_units) do
			units = units + 1
		end

		if units == 0 then
			self.wave_index = self.wave_index + 1
			GameSpawner:OpenExitGate( self.wave_index )
		end
	end
	
	if unit_name == "npc_gate_destructible_tier1" then
		self:OpenEntryGate(unit)
	end	
end
function GameSpawner:OpenExitGate( index )
	local current_wave = self.wave_list[index]
	local reward_gold = current_wave.reward_gold
	local reward_exp = current_wave.reward_exp

	GiveGoldPlayers( reward_gold )
	GiveExperiencePlayers( reward_exp )

	local next_index = index+1
	local exit_gate = Entities:FindByName(nil, "exit_gate_"..next_index)
	if exit_gate then
		exit_gate:ForceKill(false)
		local exit_obstructions = Entities:FindAllByName( "exit_gate_obstruction_"..next_index)

		for _,obstruction in pairs (exit_obstructions) do
	--		obstruction:RemoveSelf()
			obstruction:SetEnabled(false, true)
		end		
	else
		print("exit_gate_"..index.." don't exist !")
	end
end
function GameSpawner:OpenEntryGate( unit )
	local gateName = unit:GetName()
	print("unit name = "..gateName)
	local gateIndex = string.gsub(gateName, "entry_gate_", "")
	gateIndex = tonumber(gateIndex)
	print("gate index = "..gateIndex)

--	local exit_gate = Entities:FindByName( nil, "exit_gate_"..gateIndex ) or 
	local exit_gate = self.exit_gate
	local entry_obstructions = Entities:FindAllByName( "entry_gate_obstruction_"..gateIndex)
	local exit_obstructions = Entities:FindAllByName( "exit_gate_obstruction_"..gateIndex)

	for _,obstruction in pairs (entry_obstructions) do
--		obstruction:RemoveSelf()
		obstruction:SetEnabled(false, true)
	end
	for _,obstruction in pairs (exit_obstructions) do
		obstruction:SetEnabled(true, true)
	end
--	EmitGlobalSound("gate_break")

	if exit_gate then
		local hAnimGate = CreateUnitByName( "npc_gate_blocked", exit_gate:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_BADGUYS )
		local vGateAngles = exit_gate:GetAnglesAsVector()
		hAnimGate:SetAngles( vGateAngles.x, vGateAngles.y+90, vGateAngles.z )
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/dev/library/base_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, hAnimGate:GetAbsOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 300, 300, 300 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	
	end
	GameSpawner:SpawnUnits(gateIndex)
--	thisEntity:SetModel("")
--	thisEntity:StartGestureWithPlaybackRate("ACT_DOTA_SPAWN", 1)

end


GameSpawner:InitGameSpawner()