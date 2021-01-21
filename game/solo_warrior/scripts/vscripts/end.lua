if Ending == nil then
	_G.Ending = class({})
end

END_ALLIES_COUNT = 4
END_ENEMIES_COUNT = 5

--[[
vmap point name example:
sTeam_sName

dire_ancient
radiant_spawn1
]]
function Ending:precache(context)
	for i = 1, END_ALLIES_COUNT do
		PrecacheUnitByNameSync("npc_sw_ending_unit_radiant_"..i, context)
	end
	
	for i = 1, END_ENEMIES_COUNT do
		PrecacheUnitByNameSync("npc_sw_ending_unit_dire_"..i, context)
	end
	
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lina.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shredder.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", context)	
end

function Ending:init()
	DPRINT("ENDING INIT")
	
	Ending.point = {}
	Ending.point["radiant"] = {index = "radiant",}
	Ending.point["dire"] = {index = "dire",}
	
	for _,v in pairs(Ending.point) do
		local index = tostring(v.index)
		v["ancient"] = Ending:GetPoint(index, "ancient")
		v["spawn1"] = Ending:GetPoint(index, "spawn1")
		v["spawn2"] = Ending:GetPoint(index, "spawn2")
		v["spawn3"] = Ending:GetPoint(index, "spawn3")
		v["spawn4"] = Ending:GetPoint(index, "spawn4")
		v["spawn5"] = Ending:GetPoint(index, "spawn5")	
	end
	
	Ending.point["final_dest"] = Ending:GetPoint("final", "axe_dest")
end

function Ending:GetPoint(team, name)
	return Entities:FindByName(nil, team.."_"..name):GetAbsOrigin()
end

function Ending:Start()
	DPRINT("ENDING START")
	local hero = PlayerResource:GetPlayer(0):GetAssignedHero()
	
	--preparing heroes
	Ending:CreateHeroes(END_ALLIES_COUNT, "radiant", DOTA_TEAM_GOODGUYS)
	Ending:CreateHeroes(END_ENEMIES_COUNT, "dire", DOTA_TEAM_BADGUYS)
	--
	
	--preparing buildings
	local ancient = Ending:SpawnAncient(DOTA_TEAM_GOODGUYS, Ending.point["radiant"]["ancient"])
	Ending:SpawnAncient(DOTA_TEAM_BADGUYS, Ending.point["dire"]["ancient"])
	--
	
	--listeners
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Ending, 'OnEntityKilled'), self)
	--
	
	--anouncing
	Ending:ChatMessagesAndPings(hero)
	--
	
	--hero teleporting
	Timers:CreateTimer(4.0, function()
		PlayerResource:SetCameraTarget(0, ancient)
		
		GameMode.blockOrders = true
		local item = hero:AddItemByName("item_tpscroll")
		
		ExecuteOrderFromTable({
			UnitIndex = hero:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			AbilityIndex = item:entindex(),
			Position = ancient:GetOrigin(),
			Queue = false,
		})
		
		Timers:CreateTimer(3.0, function()
			GameMode.blockOrders = false
			PlayerResource:SetCameraTarget(0, nil)
		end)
	end)
	
	--[[
	Timers:CreateTimer(5.0, function()
		FindClearSpaceForUnit(hero, Ending.point["radiant"]["spawn5"], true)
	end)
	]]
	--
end

function Ending:CreateHeroes(count, teamIndex, team)
	local owner = nil
	if team == PlayerResource:GetPlayer(0):GetTeam() then owner = PlayerResource:GetPlayer(0) end
	
	for i = 1, count do
		Ending:CreateHero(team, Ending.point[teamIndex]["spawn"..i], owner, teamIndex, i)
	end
end

function Ending:CreateHero(team, pos, owner, teamIndex, id)
	local name = "npc_sw_ending_unit"
	if id then name = "npc_sw_ending_unit_"..teamIndex.."_"..id end

	local hero = CreateUnitByName(name, pos, true, owner, owner, team)
	if owner then
		hero:SetControllableByPlayer(owner:GetPlayerID(), false)
		hero:SetOwner(owner)
	end
	
	if team == DOTA_TEAM_BADGUYS then -- убрать если нужно всем давать приказ идти а не только врагам
		Timers:CreateTimer(2.0, function()
			local pos = Ending.point["dire"]["ancient"]
			if team == DOTA_TEAM_BADGUYS then pos = Ending.point["radiant"]["ancient"] end
			
			ExecuteOrderFromTable({ 
				UnitIndex = hero:GetEntityIndex(), 
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = pos,
				Queue = false
			}) 
		end)
	end
end

function Ending:SpawnAncient(team, pos)
	local ancient = CreateUnitByName("npc_sw_ending_ancient", pos, false, nil, nil, team)
	ancient:RemoveModifierByName("modifier_invulnerable")
	GameMode:ItemHelp_GiveModifier(ancient, "modifier_ancient", {})
	
	if team == DOTA_TEAM_BADGUYS then
		ancient:SetOriginalModel("models/props_structures/dire_ancient_base001.vmdl")
		ancient:SetModel("models/props_structures/dire_ancient_base001.vmdl")
	end
	
	return ancient
end

function Ending:ChatMessagesAndPings(unit)
	local function over()
		for i = 1,4 do
			Timers:CreateTimer(i/RandomInt(2,3), function()
				Ending:SayChat("sw_disconnect_"..i)
				Timers:CreateTimer(RandomFloat(0.25, 1.25), function()
					Ending:SayChat("sw_abandone_"..i)
				end)
			end)
		end
	end
	
	Timers:CreateTimer(RandomFloat(0, 4), function()
		Ending:SayChat("sw_teammate_msg_"..tostring(RandomInt(1,3)))
	end)
	
	for i = 1, 20 do
		Timers:CreateTimer(i/5, function()
			Ending:PingUnit(unit, RandomInt(0, 1), {r=RandomInt(0, 255),g=RandomInt(0, 255),b=RandomInt(0, 255)})
			if i >= 20 then over() end
		end)
	end
end

function Ending:PingUnit(unit, iPingType, color) --ping type: 0 - exclamation mark, 1 - cross --color: {0-255, 0-255, 0-255}
	if color then
		PlayerResource:SetCustomPlayerColor(unit:GetPlayerOwnerID(), color.r, color.g, color.b)
	end

	GameRules:ExecuteTeamPing(unit:GetTeamNumber(), unit:GetOrigin().x, unit:GetOrigin().y, unit, iPingType)
end

function Ending:SayChat(msg, s1, s2)
	GameRules:SendCustomMessage(msg, s1 or 0, s2 or 0)
end

function Ending:OnEntityKilled(keys)
	local npc = EntIndexToHScript(keys.entindex_killed)
	
	if npc then
		--'hero' killed
		if npc:GetUnitName() == "npc_sw_ending_unit" then
		
		end
	
		--ancient killed
		if npc:GetUnitName() == "npc_sw_ending_ancient" then
			local winner = DOTA_TEAM_GOODGUYS
			if npc:GetTeam() == winner then winner = DOTA_TEAM_BADGUYS end
			
			local hero = PlayerResource:GetPlayer(0):GetAssignedHero()
			PlayerResource:SetCameraTarget(0, npc)
			GameMode:ItemHelp_GiveModifier(hero, "modifier_ending", {})
			ExecuteOrderFromTable({ 
				UnitIndex = hero:GetEntityIndex(), 
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = Ending.point["final_dest"],
				Queue = false
			}) 
			GameMode.blockOrders = true
			
			Timers:CreateTimer(7.0, function()
				GameRules:SetGameWinner(winner)
			end)
		end
	end
end