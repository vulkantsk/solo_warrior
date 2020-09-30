
START_GAME_AUTOMATICALLY = true				-- Should the game start automatically
UNIVERSAL_SHOP_MODE = true             -- Should the main shop contain Secret Shop items as well as regular items
PLAYER_COUNT_GOODGUYS = 5
PLAYER_COUNT_BADGUYS = 0
PLAYER_COUNT_CUSTOM_1 = 0
PLAYER_COUNT_CUSTOM_2 = 0

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
HERO_RESPAWN_TIME = 15					--
STARTING_GOLD = 500						-- What starting gold player have ?
HERO_START_LEVEL = 3

ALLOW_SAME_HERO_SELECTION = false        -- Should we let people select the same hero as each other
FREE_COURIER_ENABLED = true

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
HERO_STRATEGY_TIME = 0					-- How long players being in stage after select hero?
HERO_SHOWCASE_TIME = 0					-- Shocase time on start game

GAMESETUP_lOCK = false
GAMESETUP_TIME = 15
PRE_GAME_TIME = 10.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 30.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 30.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes
CAMERA_DISTANCE_OVERRIDE = -1           -- How far out should we allow the camera to go?  Use -1 for the default (1134) while still allowing for panorama camera distance changes

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COST = 250
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false  -- Should we use a custom buyback time?
CUSTOM_BUYBACK_COOLDOWN = 900  -- Should we use a custom buyback time?
BUYBACK_ENABLED = true                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = GetMapName() == "testroom"     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = true           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?
MAXIMUM_ATTACK_SPEED = 1200
MINIMUM_ATTACK_SPEED = 50

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?
USE_CUSTOM_TOP_BAR_VALUES = false
TOP_BAR_VISIBLE = true

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[0] = 0
for i=1,14 do
  XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 50
end

for i=15,29 do
  XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 100
end


-- Generated from template
if GameSettings == nil then
	GameSettings = class({})
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameSettings:InitGameSettings()
	GameSettings = self
	print('[BAREBONES] Starting to load Barebones GameSettings...')

	-- Setup rules
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, PLAYER_COUNT_GOODGUYS )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, PLAYER_COUNT_BADGUYS)
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_1, PLAYER_COUNT_CUSTOM_1 )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_CUSTOM_2, PLAYER_COUNT_CUSTOM_2 )
	GameRules:LockCustomGameSetupTeamAssignment(GAMESETUP_lOCK)
	GameRules:SetCustomGameSetupAutoLaunchDelay(GAMESETUP_TIME)
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetStrategyTime( HERO_STRATEGY_TIME )	
	GameRules:SetShowcaseTime( HERO_SHOWCASE_TIME )	
	GameRules:SetPreGameTime( PRE_GAME_TIME)
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
	GameRules:SetStartingGold(STARTING_GOLD)
	print('[BAREBONES] GameRules set')


	-- Listeners - Event Hooks
	-- All of these events can potentially be fired by the game, though only the uncommented ones have had
	-- Functions supplied for them.
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameSettings, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(GameSettings, 'OnAbilityChannelFinished'), self)
	ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(GameSettings, 'OnPlayerLearnedAbility'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(GameSettings, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameSettings, 'OnConnectFull'), self)
--	ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameSettings, 'OnDisconnect'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameSettings, 'OnPlayerReconnect'), self)
--	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(GameSettings, 'OnItemPurchased'), self)
	ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameSettings, 'OnItemPickedUp'), self)
--	ListenToGameEvent('last_hit', Dynamic_Wrap(GameSettings, 'OnLastHit'), self)
--	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(GameSettings, 'OnNonPlayerUsedAbility'), self)
--	ListenToGameEvent('player_changename', Dynamic_Wrap(GameSettings, 'OnPlayerChangedName'), self)
--	ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(GameSettings, 'OnRuneActivated'), self)
--	ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(GameSettings, 'OnPlayerTakeTowerDamage'), self)
--	ListenToGameEvent('tree_cut', Dynamic_Wrap(GameSettings, 'OnTreeCut'), self)
--	ListenToGameEvent('entity_hurt', Dynamic_Wrap(GameSettings, 'OnEntityHurt'), self)
--	ListenToGameEvent('player_connect', Dynamic_Wrap(GameSettings, 'PlayerConnect'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameSettings, 'OnAbilityUsed'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameSettings, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameSettings, 'OnNPCSpawned'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameSettings, 'OnPlayerPickHero'), self)
	ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(GameSettings, 'OnTeamKillCredit'), self)

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))

	-- Initialized tables for tracking state
	self.vUserIds = {}
	self.vSteamIds = {}
	self.vBots = {}
	self.vBroadcasters = {}

	self.vPlayers = {}
	self.vRadiant = {}
	self.vDire = {}

	self.nRadiantKills = 0
	self.nDireKills = 0

	self.bSeenWaitForPlayers = false

	-- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
	Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameSettings, 'ExampleConsoleCommand'), "A console command example", 0 )

	print('[BAREBONES] Done loading Barebones GameSettings!\n\n')
end

mode = nil

-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function GameSettings:PlayerConnect(keys)
	print('[BAREBONES] PlayerConnect')
	DeepPrintTable(keys)

	if keys.bot == 1 then
		-- This user is a Bot, so add it to the bots table
		self.vBots[keys.userid] = 1
	end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameSettings:OnConnectFull(keys)
	print ('[BAREBONES] OnConnectFull')
	DeepPrintTable(keys)
	GameSettings:CaptureGameMode()

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	-- Update the user ID table with this user
	self.vUserIds[keys.userid] = ply

	-- Update the Steam ID table
	self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If the player is a broadcaster flag it in the Broadcasters table
	if PlayerResource:IsBroadcaster(playerID) then
		self.vBroadcasters[keys.userid] = 1
		return
	end
end

-- This function is called as the first player loads and sets up the GameSettings parameters
function GameSettings:CaptureGameMode()
	if mode == nil then
		-- Set GameSettings parameters
		mode = GameRules:GetGameModeEntity()
		mode:SetFreeCourierModeEnabled(FREE_COURIER_ENABLED)
		mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
		mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
		mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
		mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
		mode:SetBuybackEnabled( BUYBACK_ENABLED )
		mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
		mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
		mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
		mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

		--mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

		mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetUnseenFogOfWarEnabled(USE_UNSEEN_FOG_OF_WAR)
		mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
		mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
		mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED ) 
		mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
--[[
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE,1)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_STATUS_RESISTANCE_PERCENT,0)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP,20)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN_PERCENT,0.02)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_MAGIC_RESISTANCE_PERCENT,0)

		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE,1)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR,0)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED,1)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_MOVE_SPEED_PERCENT,0)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR,0.015)

		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA,10)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE,1)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_SPELL_AMP_PERCENT,0)
		mode:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN_PERCENT,0.015)
]]
		self:OnFirstPlayerLoaded()
	end
end

-- This is an example console command
function GameSettings:ExampleConsoleCommand()
	print( '******* Example Console Command ***************' )
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			-- Do something here for the player who called this command
			PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
		end
	end
	print( '*********************************************' )
end

--[[
  This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
  in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
  If this occurs it causes the client to never precache things configured in that block.
  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.
  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).
]]
function GameSettings:PostLoadPrecache()
	print("[BAREBONES] Performing Post-Load precache")

end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameSettings() but needs to be done before everyone loads in.
]]
function GameSettings:OnFirstPlayerLoaded()
	print("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameSettings:OnAllPlayersLoaded()
	print("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.
  The hero parameter is the hero entity that just spawned in.
]]
function GameSettings:OnHeroInGame(hero)
	print("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

	-- Store a reference to the player handle inside this hero handle.
	hero.player = PlayerResource:GetPlayer(hero:GetPlayerID())
	-- Store the player's name inside this hero handle.
	hero.playerName = PlayerResource:GetPlayerName(hero:GetPlayerID())
	-- Store this hero handle in this table.
	table.insert(self.vPlayers, hero)

	-- This line for example will set the starting gold of every hero to 500 unreliable gold


	-- These lines will create an item and add it to the player, effectively ensuring they start with the item
	--local item = CreateItem("item_example_item", hero, hero)
	--hero:AddItem(item)
end

--[[
	This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
	gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
	is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameSettings:OnGameInProgress()
	print("[BAREBONES] The game has officially begun")
	for i=0,4 do
		PlayerResource:SetCustomBuybackCooldown(i, CUSTOM_BUYBACK_COOLDOWN)		
		PlayerResource:SetCustomBuybackCost(i, CUSTOM_BUYBACK_COST)
	end
	print("Make buildings vulnerable")
    local allBuildings = Entities:FindAllByClassname('npc_dota_building')
    for i = 1, #allBuildings, 1 do
        local building = allBuildings[i]
        building:RemoveModifierByName('modifier_invulnerable')
		building:RemoveModifierByName("modifier_tower_truesight_aura")

    end

	Timers:CreateTimer(60, function() -- Start this timer 30 game-time seconds later
		GiveExperiencePlayers( 1 )
		return 60.0 -- Rerun this timer every 30 game-time seconds
	end)
end

-- Cleanup a player when they leave
function GameSettings:OnDisconnect(keys)
	print('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	DeepPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end

-- The overall game state has changed
function GameSettings:OnGameRulesStateChange(keys)
	print("[BAREBONES] GameRules State Changed")
	DeepPrintTable(keys)

	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameSettings:OnGameInProgress()
	end
end


function addItemBySteamID(enum,item_name,steamID,npc)
	for _,ID in pairs(enum) do
		if steamID == ID then
			Timers:CreateTimer(1,function() npc:AddItemByName(item_name) end)
		end
	end
end
-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameSettings:OnEntityHurt(keys)
	--print("[BAREBONES] Entity Hurt")
	--DeepPrintTable(keys)
--	local entCause = EntIndexToHScript(keys.entindex_attacker)
--	local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function GameSettings:OnItemPickedUp(keys)
	print ( '[BAREBONES] OnItemPurchased' )
	DeepPrintTable(keys)

--	local heroEntity = EntIndexToHScript()
	local unit_index = keys.HeroEntityIndex or keys.UnitEntityIndex
	local hero = EntIndexToHScript(unit_index):GetPlayerOwner()
	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = keys.PlayerID
	local itemname = keys.itemname
	
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameSettings:OnPlayerReconnect(keys)
	print ( '[BAREBONES] OnPlayerReconnect' )
	DeepPrintTable(keys)
end

-- An item was purchased by a player
function GameSettings:OnItemPurchased( keys )
	print ( '[BAREBONES] OnItemPurchased' )
	DeepPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname

	-- The cost of the item purchased
	local itemcost = keys.itemcost

end

-- An ability was used by a player
function GameSettings:OnAbilityUsed(keys)
	print('[BAREBONES] AbilityUsed')
	DeepPrintTable(keys)

	local player = EntIndexToHScript(keys.PlayerID)
	local abilityname = keys.abilityname
	local caster = EntIndexToHScript(keys.caster_entindex)
	
	
	if GetMapName() == "roshdef_turbo" then
		if abilityname == "item_ultra_boots" or abilityname == "item_travel_boots_2" or abilityname == "item_travel_boots"or abilityname == "item_tpscroll" then
			for i=0,8 do
				local item = caster:GetItemInSlot( i )
				local item_name = ""
				if item then item_name = item:GetAbilityName() end
--				print ("item = "..item_name)
				
				if item and item_name == abilityname then 
					Timers:CreateTimer(0.01,function()
--						local cooldown = item:GetCooldownTimeRemaining()/2
						local cooldown = item:GetCooldownTime()/2
						item:EndCooldown()
						item:StartCooldown(cooldown)
					end)
				end 			
			end
		end
	end

end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameSettings:OnNonPlayerUsedAbility(keys)
	print('[BAREBONES] OnNonPlayerUsedAbility')
	DeepPrintTable(keys)

	local abilityname=  keys.abilityname
end

-- A player changed their name
function GameSettings:OnPlayerChangedName(keys)
	print('[BAREBONES] OnPlayerChangedName')
	DeepPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function GameSettings:OnPlayerLearnedAbility( keys)
	print ('[BAREBONES] OnPlayerLearnedAbility')
	DeepPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameSettings:OnAbilityChannelFinished(keys)
	print ('[BAREBONES] OnAbilityChannelFinished')
	DeepPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1

end

-- A player leveled up
function GameSettings:OnPlayerLevelUp(keys)
	print ('[BAREBONES] OnPlayerLevelUp')
	DeepPrintTable(keys)

--	local player = EntIndexToHScript(keys.player)
	local hero = EntIndexToHScript(keys.hero_entindex)
	-- local hero = PlayerResource:GetSelectedHeroEntity(keys.player_id)
	local level = keys.level
	if hero and level then
		print(level)
		local ability_point = hero:GetAbilityPoints()
		local no_points_levels = {
		[17] = 1,
		[19] = 1,
		[21] = 1,
		[22] = 1,
		[23] = 1,
		[24] = 1,
		}


		if no_points_levels[level] or level >= 26 then
			hero:SetAbilityPoints(ability_point + 1)
		end
	end
end

-- A player last hit a creep, a tower, or a hero
function GameSettings:OnLastHit(keys)
	print ('[BAREBONES] OnLastHit')
	DeepPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down by tango, quelling blade, etc
function GameSettings:OnTreeCut(keys)
	print ('[BAREBONES] OnTreeCut')
	DeepPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameSettings:OnRuneActivated (keys)
	print ('[BAREBONES] OnRuneActivated')
	DeepPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

end

-- A player took damage from a tower
function GameSettings:OnPlayerTakeTowerDamage(keys)
	print ('[BAREBONES] OnPlayerTakeTowerDamage')
	DeepPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- A player picked a hero
function GameSettings:OnPlayerPickHero(keys)
	print ('[BAREBONES] OnPlayerPickHero')
	DeepPrintTable(keys)

	local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameSettings:OnTeamKillCredit(keys)
	print ('[BAREBONES] OnTeamKillCredit')
	DeepPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameSettings:OnNPCSpawned(keys)
--	print("[BAREBONES] NPC Spawned")
--	DeepPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()
	
	if npc:IsRealHero() and npc.bFirstSpawned == nil then
--		GameSettings:OnHeroInGame(npc)			
		npc.bFirstSpawned = true
		local playerID = npc:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)

		if FirstSpawned == nil then
			FirstSpawned = {}
		end
		
		if not FirstSpawned[playerID] or _G.testmode then

			FirstSpawned[playerID] = true
			while npc:GetLevel() < HERO_START_LEVEL do
				npc:AddExperience(50, 0, true, true)
			end
		end
	end	
	if npc:IsTempestDouble() or npc:IsIllusion() then
		local owner = npc:GetPlayerOwner():GetAssignedHero()
		npc:SetTeam(owner:GetTeam())
		for _, modifier in pairs( owner:FindAllModifiers() ) do
			local stacks = modifier:GetStackCount()
			local modifier_name = modifier:GetName()

			if stacks > 0 then
				local modifier = npc:AddNewModifier(owner, nil, modifier_name, {})
				modifier:SetStackCount(stacks)
			end
		end
	end
end
-- An entity died
function GameSettings:OnEntityKilled( keys )
--	print( '[BAREBONES] OnEntityKilled Called' )
--	DeepPrintTable( keys )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil
	local team= killedUnit:GetTeam()
	
	if killedUnit:IsRealHero() and killedUnit:IsReincarnating() == false then
		killedUnit:SetTimeUntilRespawn( HERO_RESPAWN_TIME )
--		PlayerResource:SetCustomBuybackCost(killedUnit:GetPlayerID(), CUSTOM_BUYBACK_COST)
	end
	
	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- Put code here to handle when an entity gets killed
end
