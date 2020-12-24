if GameSpawner == nil then
	_G.GameSpawner = class({})
end
HERO_START_LIFES = 3

GameSpawner.exit_gate =nil
GameSpawner.current_units = {}
GameSpawner.line_interval = {}
GameSpawner.wave_index = 0

GameSpawner.reward_tier = {
	[1] = {"item_str_1_3","item_stat_1_3","item_dmg_1_3","item_hp_1_3","item_hpreg_1_3","item_str_1_3",},
	[2] = {"item_str_1_3","item_stat_1_3","item_dmg_1_3","item_hp_1_3","item_hpreg_1_3","item_str_1_3",},
	[3] = {"item_str_1_3","item_stat_1_3","item_dmg_1_3","item_hp_1_3","item_hpreg_1_3","item_str_1_3",},
	[4] = {"item_str_1_3","item_stat_1_3","item_dmg_1_3","item_hp_1_3","item_hpreg_1_3","item_str_1_3",},
}

GameSpawner.wave_list = {
--	[1]={reward_gold=250,reward_exp=500,                                            --НАГРАДА ЗА закрытие (прохождение) комнаты первой комнаты. [1] - это номер комнаты
--			units={["npc_kobold"]=3,["npc_gnoll_ranger"]=2,["npc_kobold_tunneler"]=2}},                 --Юниты в комнате (какие в [этих скобках]) и их количество      --было по 4
--	[2]={reward_gold=500,reward_exp=1000,
--			units={["npc_melee_troll"]=5,["npc_troll_healer"]=3,["npc_troll_dd"]=3,["npc_troll_shaman"]=2,["npc_troll_mini_boss"]=1}},           
--	[3]={reward_gold=750,reward_exp=1500,
--			units={["npc_gnoll_ranger"]=3,["npc_kobold_tunneler"]=3,["npc_troll_dd"]=3,["npc_troll_shaman"]=2,["npc_meepo_mini_boss"]=5}},
--	[4]={reward_gold=1000,reward_exp=2000,
--			units={["npc_troll_mini_boss"]=2,["npc_meepo_mini_boss"]=5,["npc_boss_kobold"]=1}},"npc_gorgule_mini_boss"  "npc_boss_golem_split"  "npc_boss_golem"  "npc_granite_golem" ["npc_boss_golem_split"]=0,
--["npc_bone_golem"]=3,["npc_granite_golem"]=5,["npc_boss_golem"]=1 "npc_iron_golem"
--["npc_stone_golem"]=5,["npc_granite_golem"]=4,["npc_ice_golem"]=3,["npc_lava_golem"]=2,["npc_tiny_mini_boss"]=1
--["npc_ogre"]=3,["npc_ogre_smasher"]=5,["npc_ogre_ambal"]=2,["npc_tower_golem"]=1,["npc_ogremagi_mini_boss"]=1
--["npc_wolf"]=7,["npc_alfa_wolf"]=1,["npc_beta_wolf"]=3,["npc_black_wolf"]=4
--["npc_gorgule"]=10,["npc_gorgule_prime"]=3,["npc_harpy"]=7,["npc_harpy_witch"]=2,["npc_gorgule_mini_boss"]=1
--"npc_skeleton" "npc_skeleton_archer" "npc_skeleton_mage" "npc_skeleton_big" "npc_zombie" "npc_creeping_zombie"
	[1]={reward_gold=100,reward_exp=200,
			units={["npc_common_dog"]=10,["npc_rare_dog"]=4,["npc_unique_dog"]=2}},
	[2]={reward_gold=200,reward_exp=200,
			units={["npc_common_troll"]=10,["npc_rare_troll"]=3,["npc_unique_troll"]=2}},
	[3]={reward_gold=600,reward_exp=200,
			units={["npc_common_vulture"]=15,["npc_rare_vulture"]=5,["npc_unique_vulture"]=4,}},
	[4]={reward_gold=900,reward_exp=200,
			units={["npc_boss_koboldini"]=3,["npc_boss_manowar"]=1,["npc_boss_brigadir"]=1},
		reward_chest={gold=1000,tier=1}},
	[5]={reward_gold=100,reward_exp=200,
			units={["npc_common_satyr"]=6,["npc_rare_satyr"]=10,["npc_unique_satyr"]=2}},
	[6]={reward_gold=100,reward_exp=200,
			units={["npc_common_centaur"]=15,["npc_rare_centaur"]=10,["npc_unique_centaur"]=4}},
	[7]={reward_gold=100,reward_exp=200,
			units={["npc_common_ogre"]=15,["npc_rare_ogre"]=8 ,["npc_unique_ogre"]=8}},
	[8]={reward_gold=100,reward_exp=200,
			units={["npc_common_golem"]=15,["npc_rare_golem"]=7 ,["npc_unique_golem"]=3}},
	[9]={reward_gold=100,reward_exp=200,
			units={["npc_common_ghost"]=1,["npc_rare_ghost"]=1,["npc_unique_ghost"]=1}},
	[10]={reward_gold=100,reward_exp=200,
			units={["npc_common_bug"]=10,["npc_rare_bug"]=5 ,["npc_unique_bug"]=3}},
	[11]={reward_gold=400,reward_exp=800,
			units={["npc_common_fish"]=10,["npc_rare_fish"]=5 ,["npc_unique_fish"]=3}},
	[12]={reward_gold=500,reward_exp=1000,
			units={["npc_ursa_yellow"]=15,["npc_ursa_red"]=7}},
	[13]={reward_gold=700,reward_exp=1200,
			units={["npc_common_dragon"]=15,["npc_rare_dragon"]=7 ,["npc_unique_dragon"]=3}},
	[14]={reward_gold=1000,reward_exp=1500,
			units={["npc_common_skeleton"]=15,["npc_rare_skeleton"]=7 ,["npc_unique_skeleton"]=3}},
	[15]={reward_gold=1500,reward_exp=2000,
			units={["npc_common_lizard"]=15,["npc_rare_lizard"]=7 ,["npc_unique_lizard"]=3}},
	[16]={reward_gold=3000,reward_exp=3000,
			units={["npc_boss_satyr"]=15}},
--[[	[2]={reward_gold=125,reward_exp=250,
				units={["npc_melee_troll"]=5,["npc_troll_shaman"]=1,["npc_troll_healer"]=2,["npc_troll_dd"]=3,["npc_troll_mini_boss"]=1}},
		[3]={reward_gold=150,reward_exp=300,
				units={["npc_kobold"]=7,["npc_kobold_tunneler"]=5,["npc_troll_shaman"]=2,["npc_troll_dd"]=4,["npc_meepo_mini_boss"]=5}},
		[4]={reward_gold=175,reward_exp=350,
				units={["npc_kobold"]=12,["npc_kobold_tunneler"]=7,["npc_gnoll_ranger"]=5,["npc_dazzle_hero"]=1,["npc_boss_kobold"]=1}},
		[5]={reward_gold=200,reward_exp=400,
				units={["npc_wolf"]=9,["npc_alfa_wolf"]=1,["npc_beta_wolf"]=3,["npc_black_wolf"]=5}},
		[6]={reward_gold=225,reward_exp=450,
				units={["npc_ogre"]=3,["npc_ogre_smasher"]=5,["npc_ogre_ambal"]=2,["npc_ogremagi_mini_boss"]=1}},
		[7]={reward_gold=250,reward_exp=500,
				units={["npc_stone_golem"]=5,["npc_granite_golem"]=4,["npc_ice_golem"]=3,["npc_lava_golem"]=2,["npc_tower_golem"]=1,["npc_tiny_mini_boss"]=1}},
		[8]={reward_gold=275,reward_exp=550,
				units={["npc_bone_golem"]=3,["npc_iron_golem"]=2,["npc_granite_golem"]=5,["npc_boss_golem"]=1}},
		[9]={reward_gold=300,reward_exp=600,
				units={["npc_gorgule"]=7,["npc_gorgule_prime"]=3,["npc_harpy"]=5,["npc_harpy_witch"]=2,["npc_gorgule_mini_boss"]=1}},
		[10]={reward_gold=350,reward_exp=700,
				units={["npc_skeleton"]=10,["npc_skeleton_archer"]=5,["npc_skeleton_mage"]=3,["npc_skeleton_big"]=2,["npc_zombie"]=8,["npc_creeping_zombie"]=4}},
		[11]={reward_gold=400,reward_exp=800,
				units={["npc_kobold"]=1,["npc_kobold_tunneler"]=1}},
		[12]={reward_gold=500,reward_exp=1000,
				units={["npc_kobold"]=1,["npc_kobold_tunneler"]=1}},
		[13]={reward_gold=700,reward_exp=1200,
				units={["npc_kobold"]=1,["npc_kobold_tunneler"]=1}},
		[14]={reward_gold=1000,reward_exp=1500,
				units={["npc_kobold"]=1,["npc_kobold_tunneler"]=1}},
		[15]={reward_gold=1500,reward_exp=2000,
				units={["npc_kobold"]=1,["npc_kobold_tunneler"]=1}},
		[16]={reward_gold=3000,reward_exp=3000,
				units={["npc_kobold"]=1,["npc_kobold_tunneler"]=1}},
	]]	

}

function GameSpawner:InitGameSpawner()
	print("vse ok - ?")
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
	
	CustomGameEventManager:RegisterListener("TestRoom_SetRoom", Dynamic_Wrap(GameSpawner, 'TestRoom_SetRoom'))
	CustomGameEventManager:RegisterListener("TestRoom_SetHero", Dynamic_Wrap(GameSpawner, 'TestRoom_SetHero'))
	CustomGameEventManager:RegisterListener("RewardChest_SelectReward", Dynamic_Wrap(GameSpawner, 'RewardChest_SelectReward'))

	_G.testmode = GetMapName() == "testroom"
	
	Convars:RegisterCommand( "room", Dynamic_Wrap(GameSpawner, 'StartTestRoom'), "A console command example", 0 )
	Convars:RegisterCommand( "sethero", Dynamic_Wrap(GameSpawner, 'SetHero'), "A console command example", 0 )
end

function GameSpawner:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

	end
end

function GameSpawner:RewardChest_SelectReward(event)
	if GameSpawner.rewards then 
		if not GameSpawner.rewards[event.PlayerID] then
			GameSpawner.rewards[event.PlayerID] = event.reward
			if event.reward == "gold" then
				local player = PlayerResource:GetPlayer(event.PlayerID)
				local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
				hero:ModifyGold(GameSpawner.rewards["reward_chest"].gold, false, 0)
				SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, hero, GameSpawner.rewards["reward_chest"].gold, nil )
			end
		elseif GameSpawner.rewards[event.PlayerID] == "item" then
			GameSpawner.rewards[event.PlayerID] = event.reward
			local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
			hero:AddItemByName(GameSpawner.reward_tier[GameSpawner.rewards["reward_chest"].tier][tonumber(event.reward)])
		end
	end
end

function GameSpawner:TestRoom_SetRoom(event)
	GameSpawner:StartTestRoom(event.room)
end

function GameSpawner:TestRoom_SetHero(event)
	GameSpawner:SetHero(event.room)
end

function GameSpawner:SetHero(room)
	if not _G.testmode then return end
	print("SetHero "..room)

	local gold = 0
	local exp = 0

	for i=1, tonumber(room)-1 do
		local wave = GameSpawner.wave_list[i]
		local reward_gold = wave.reward_gold
		local reward_exp = wave.reward_exp
		gold = gold + reward_gold
		exp = exp + reward_exp
	end
	
	local id = Convars:GetCommandClient():GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity(id)
	hero:SetAbilityPoints(0)

	PlayerResource:ReplaceHeroWith(id, "npc_dota_hero_axe", gold, exp)
	hero = PlayerResource:GetSelectedHeroEntity(id)

	for i=0, hero:GetAbilityCount()-1 do
		local abil = hero:GetAbilityByIndex(i)
		if abil then
			abil:SetLevel(0)
		end
	end
	hero:SetAbilityPoints(hero:GetAbilityPoints()+2)
end

function GameSpawner:StartTestRoom(room)
	if not _G.testmode then return end
	print("StartTestRoom "..room)
	
	local current_wave = GameSpawner.wave_list[tonumber(room)]
	local points = Entities:FindAllByName("test_spawner_points")
	local units = current_wave.units
	local bonus_units = current_wave.bonus_units

	for key, value in pairs(units) do
		local unit_name
		local unit_count
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
		end

	end

	if bonus_units then
		for key, value in pairs (bonus_units) do
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
			end
		end 
	end

	local filler = Entities:FindByName(nil, "test_filler")
	local filler_ability = filler:FindAbilityByName("filler_ability")
	filler_ability:EndCooldown()
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
	local bonus_units = current_wave.bonus_units
	local reward_chest = current_wave.reward_chest

--	GameRules:SendCustomMessage("#Game_notification_boss_spawn_"..boss_name,0,0)

	for key, value in pairs (units) do
		local unit_name
		local unit_count
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
			unit.reward = true
			local ent_index = unit:entindex()
--			table.insert(self.current_units, ent_index, unit)
			self.current_units[ent_index]= unit
		end
	end 
	if bonus_units then
		for key, value in pairs (bonus_units) do
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
			end
		end 
	end
	if reward_chest then
--		self.reward_chest.gold = reward_chest.gold
--		self.reward_chest.tier = reward_chest.tier
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

			local ability = npc:GetAbilityByIndex(0)
			ability:SetLevel(1)
			local ability = npc:GetAbilityByIndex(1)
			ability:SetLevel(1)
			local ability = npc:GetAbilityByIndex(2)
			ability:SetLevel(1)
			local ability = npc:GetAbilityByIndex(3)
			ability:SetLevel(1)
			local ability_point = npc:GetAbilityPoints()
			npc:SetAbilityPoints(ability_point + 1)

	        local warrior_form = npc:FindAbilityByName("axe_warrior_form")
	        npc:AddNewModifier(npc, warrior_form, "modifier_axe_warrior_form", nil)
			npc:CalculateStatBonus(true)

			local life_modifier = npc:AddNewModifier(npc, nil, "modifier_extra_life", nil)
			life_modifier:SetStackCount(HERO_START_LIFES)
		end)
	elseif npc:IsRealHero() and npc.spawn_point then
		npc:SetAbsOrigin(npc.spawn_point)
	end
end

function GameSpawner:OnEntityKilled(keys)
	if _G.testmode then return end

	local npc = EntIndexToHScript(keys.entindex_killed)
	local unit_name = npc:GetUnitName()
	
	if unit_name == "npc_goodguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)		
	end
	
	if npc:IsRealHero() and not npc:IsReincarnating() then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)		
	end

	if npc.split_name then
		self:SplitterDeath(npc)
	end

	if npc.reward then
		local ent_index = npc:entindex()
		
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
		self:OpenEntryGate(npc)
	end	
end
function GameSpawner:OpenExitGate( index )
	local current_wave = self.wave_list[index]
	local reward_gold = current_wave.reward_gold
	local reward_exp = current_wave.reward_exp
	local reward_chest = current_wave.reward_chest

	GiveGoldPlayers( reward_gold )
	GiveExperiencePlayers( reward_exp )

	local next_index = index+1
	local exit_gate = Entities:FindByName(nil, "exit_gate_"..next_index)
	if exit_gate then
		self.exit_gate = {exit_gate:GetAbsOrigin(), exit_gate:GetAnglesAsVector()}
		exit_gate:ForceKill(false)
		local exit_obstructions = Entities:FindAllByName( "exit_gate_obstruction_"..next_index)

		for _,obstruction in pairs (exit_obstructions) do
	--		obstruction:RemoveSelf()
			obstruction:SetEnabled(false, true)
		end		
		
		local spawn_point = Entities:FindByName(nil, "hero_spawn_point_"..next_index)
		if spawn_point then
			print("All ok spawn_point_"..next_index)
			for i=0,4 do
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if hero then
					hero.spawn_point = spawn_point:GetAbsOrigin()
--					hero:SetAbsOrigin(hero.spawn_point)
				end
			end
		else
			print("Failed spawn_point_"..next_index)
		end
		local filler = Entities:FindByName(nil, "filler_"..next_index)
		if filler then
			print("All ok filler_"..next_index)
			local filler_ability = filler:FindAbilityByName("filler_ability")
			filler_ability:EndCooldown()
		else
			print("Failed filler_"..next_index)
		end
	else
		print("exit_gate_"..next_index.." don't exist !")
	end

	if reward_chest then
		local select_duration = 10
		self.rewards = {}
		self.rewards["reward_chest"] = reward_chest
		CustomGameEventManager:Send_ServerToAllClients("RewardChest", {
			gold = reward_chest.gold,
			items = GameSpawner.reward_tier[reward_chest.tier],
			duration = select_duration,
			start_time = GameRules:GetGameTime()
		})
		
		Timers:CreateTimer(select_duration,function()
			CustomGameEventManager:Send_ServerToAllClients("EndRewardChest", {})
			for i=0, PlayerResource:GetPlayerCount()-1 do
				if self.rewards[i] == nil then
					local player = PlayerResource:GetPlayer(i)
					local hero = PlayerResource:GetSelectedHeroEntity(i)
					hero:ModifyGold(reward_chest.gold, false, 0)
					SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, hero, reward_chest.gold, nil )
				elseif self.rewards[i] == "item" then
					local hero = PlayerResource:GetSelectedHeroEntity(i)
					hero:AddItemByName(GameSpawner.reward_tier[reward_chest.tier][RandomInt(1,#GameSpawner.reward_tier[reward_chest.tier])])
				end
			end
			self.rewards = nil
		end)
	end
end
function GameSpawner:OpenEntryGate( unit )
	local gateName = unit:GetName()
	print("unit name = "..gateName)
	local gateIndex = string.gsub(gateName, "entry_gate_", "")
	gateIndex = tonumber(gateIndex)
	print("gate index = "..gateIndex)

--	local exit_gate = Entities:FindByName( nil, "exit_gate_"..gateIndex ) or 
	-- local exit_gate = self.exit_gate
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

	if self.exit_gate then
		local hAnimGate = CreateUnitByName( "npc_gate_blocked", self.exit_gate[1], false, nil, nil, DOTA_TEAM_BADGUYS )
		local vGateAngles = self.exit_gate[2]
		hAnimGate:SetAngles( vGateAngles.x, vGateAngles.y+90, vGateAngles.z )
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/dev/library/base_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, hAnimGate:GetAbsOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 300, 300, 300 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	
		self.exit_gate = nil
	end
	GameSpawner:SpawnUnits(gateIndex)
--	thisEntity:SetModel("")
--	thisEntity:StartGestureWithPlaybackRate("ACT_DOTA_SPAWN", 1)

end

function GameSpawner:SplitterDeath(npc)
	local split_name = npc.split_name
	local split_count = npc.split_count
	local point = npc:GetAbsOrigin()

	for i=1, split_count do
		local unit = CreateUnitByName( split_name, point+RandomVector(10), false, nil, nil, npc:GetTeam() )

		if npc.reward then
			local ent_index = unit:entindex()
			self.current_units[ent_index]= unit
			unit.reward = true
		end

		local kv = {
		should_stun = 1,
		knockback_duration = 0.75,
		duration = 0.75,
		knockback_distance = 100,
		knockback_height = 150,
		center_x = point.x,
		center_y = point.y,
		center_z = point.z
		}
		unit:AddNewModifier( npc, nil, "modifier_knockback", kv )
	end
end

GameSpawner:InitGameSpawner()