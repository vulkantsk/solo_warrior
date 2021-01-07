--команды для дебага

if Commands == nil then
    _G.Commands = class({})
end

-- рег конваров
function Commands:init()
	--[[ВЫДАЧА ПОИНТОВ]] 		Convars:RegisterCommand( "tpoints", Dynamic_Wrap(Commands, 'GiveTalentPoints'), "Give Talent Points to player, usage: tpoints {pid} {points}", FCVAR_CHEAT )
	--[[ДЕНЬГИ И УРОВЕНЬ]] 		Convars:RegisterCommand( "gig", Dynamic_Wrap(Commands, 'GreedIsGood'), "Greed Is Good, usage: gig {pid}", FCVAR_CHEAT )
	--[[ПРОВЕРКА ПЕРЕЗАХОДА]]   Convars:RegisterCommand( "trec", Dynamic_Wrap(Commands, 'TestReconnect'), "Test Reconnect", FCVAR_CHEAT ) -- только для speedrun.lua, можно добавить и для events, если будет такой
	--[[ВЫИГРАТЬ ИГРУ]]  		Convars:RegisterCommand( "win", Dynamic_Wrap(Commands, 'Win'), "win {team}", FCVAR_CHEAT )
end

-- функции конваров:
function Commands:GiveTalentPoints(pid, count) --tpoints
	if not count then count = pid; pid = 0 end
	pid = tonumber(pid)
	
	if PlayerResource:IsValidPlayer(pid) then
		TalentTree:AddTalentPointsToHero(PlayerResource:GetPlayer(pid):GetAssignedHero(), tonumber(count))
	end
end

function Commands:GreedIsGood(pid) --gig
	if not pid then pid = 0 end
	pid = tonumber(pid)
	
	if PlayerResource:IsValidPlayer(pid) then
		local hero = PlayerResource:GetPlayer(pid):GetAssignedHero()
		hero:AddExperience(1000000, DOTA_ModifyXP_Unspecified, false, false)
		hero:ModifyGold(999999, true, DOTA_ModifyGold_CheatCommand)
	end
end

function Commands:TestReconnect(pid)
	Speedrun:OnPlayerReconnect({PlayerID = tonumber(pid)})
end

function Commands:Win(team)
	if not team then team = 2 end
	GameRules:SetGameWinner(tonumber(team))
end