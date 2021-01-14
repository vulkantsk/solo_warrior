if Ending == nil then
	_G.Ending = class({})
end

--[[
vmap point name example:
sTeam_sName

dire_ancient
radiant_spawn1
]]
function Ending:init()
	DPRINT("ENDING INIT")

	Ending.alliesCount = 4
	Ending.enemiesCount = 5
	
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
end

function Ending:GetPoint(team, name)
	return Entities:FindByName(nil, team.."_"..name):GetAbsOrigin()
end

function Ending:Start()
	DPRINT("ENDING START")
	
	--preparing heroes
	Ending:CreateHeroes(Ending.alliesCount, "radiant", DOTA_TEAM_GOODGUYS)
	Ending:CreateHeroes(Ending.enemiesCount, "dire", DOTA_TEAM_BADGUYS)
	FindClearSpaceForUnit(PlayerResource:GetPlayer(0):GetAssignedHero(), Ending.point["radiant"]["spawn5"], true)
	--
	
	--preparing buildings
	Ending:SpawnAncient(DOTA_TEAM_GOODGUYS, Ending.point["radiant"]["ancient"])
	Ending:SpawnAncient(DOTA_TEAM_BADGUYS, Ending.point["dire"]["ancient"])
	--
	
	--listeners
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Ending, 'OnEntityKilled'), self)
	--
	
	--anouncing
	Ending:ChatMessagesAndPings()
	--
end

function Ending:CreateHeroes(count, teamIndex, team)
	local owner = nil
	if team == PlayerResource:GetPlayer(0):GetTeam() then owner = PlayerResource:GetPlayer(0) end
	
	for i = 1, count do
		Ending:CreateHero(team, Ending.point[teamIndex]["spawn"..i], owner)
	end
end

function Ending:CreateHero(team, pos, owner)
	local hero = CreateUnitByName("npc_sw_ending_unit", pos, true, owner, owner, team)
	if owner then
		hero:SetControllableByPlayer(owner:GetPlayerID(), false)
		hero:SetOwner(owner)
	end
	
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

function Ending:SpawnAncient(team, pos)
	local ancient = CreateUnitByName("npc_sw_ending_ancient", pos, false, nil, nil, team)
	
	GameMode:ItemHelp_GiveModifier(ancient, "modifier_ancient", {})
	
	if team == DOTA_TEAM_BADGUYS then
		ancient:SetOriginalModel("models/props_structures/dire_ancient_base001.vmdl")
		ancient:SetModel("models/props_structures/dire_ancient_base001.vmdl")
	end
end

function Ending:ChatMessagesAndPings()

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
			
			GameRules:SetGameWinner(winner)
		end
	end
end

function Ending:SayChat(msg)
	GameRules:SendCustomMessage(msg, 0, 0)
end