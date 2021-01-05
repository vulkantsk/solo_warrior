--команды для дебага

if Commands == nil then
    _G.Commands = class({})
end

-- рег конваров
function Commands:init()
	--[[ВЫДАЧА ПОИНТОВ]] 		Convars:RegisterCommand( "tpoints", Dynamic_Wrap(Commands, 'GiveTalentPoints'), "Give Talent Points to player, usage: tpoints {pid} {points}", FCVAR_CHEAT )
	--[[ДЕНЬГИ И УРОВЕНЬ]] 		Convars:RegisterCommand( "gig", Dynamic_Wrap(Commands, 'GreedIsGood'), "Greed Is Good, usage: gig {pid}", FCVAR_CHEAT )
end

-- функции конваров:
function Commands:GiveTalentPoints(pid, count) --tpoints
	pid = tonumber(pid)
	if PlayerResource:IsValidPlayer(pid) then
		TalentTree:AddTalentPointsToHero(PlayerResource:GetPlayer(pid):GetAssignedHero(), tonumber(count))
	end
end

function Commands:GreedIsGood(pid) --gig
	pid = tonumber(pid)
	if PlayerResource:IsValidPlayer(pid) then
		local hero = PlayerResource:GetPlayer(pid):GetAssignedHero()
		hero:AddExperience(1000000, DOTA_ModifyXP_Unspecified, false, false)
		hero:ModifyGold(999999, true, DOTA_ModifyGold_CheatCommand)
	end
end