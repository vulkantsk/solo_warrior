--https://pastebin.com/c05fLCQW
if ZBots == nil then
    ZBots = class({})
    
    ZBots.MAX_PLAYERS_PER_TEAM = 5
    ZBots.MAX_BOTS = 9
    ZBots.BOT_DIFFICULTY = "unfair"
    ZBots.HERO_LIST_PATH = "scripts/npc/bot_herolist.txt"
    ZBots.LANE = {{"mid", 0, 0}, {"bot", 0, 0}, {"top", 0, 0}}
    ZBots.MAX_BOTS_ON_ONE_LANE = 2
end

function ZBots:preload()
    Tutorial:StartTutorialMode(); 
    GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
end

--[[ 
function ZBots:Load()
    GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap( ZBots, "ItemFilter" ), self )
    Tutorial:StartTutorialMode(); 
    GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
    
    local botCount = 0
    for team = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do 
        local count = PlayerResource:GetPlayerCountForTeam(team)
        while(count < ZBots.MAX_PLAYERS_PER_TEAM) do
            count = count + 1
            if botCount < ZBots.MAX_BOTS then
                botCount = botCount + 1
                ZBots:CreateBotForTeam(team, botCount)
            end
        end
    end
end
]]

function ZBots:CreateBotForTeam(team, delay)
    team = team == DOTA_TEAM_GOODGUYS
    Timers:CreateTimer(delay, function()
        Tutorial:AddBot(ZBots:GetRandomHero(), "mid", ZBots.BOT_DIFFICULTY, team);
    end)
end
 
function ZBots:GetRandomHero()
    local kv = LoadKeyValues(ZBots.HERO_LIST_PATH)
    local hero = ""
    for k,v in pairs(kv) do
        hero = k
        local rand = RandomInt(0, 4)
        
        if v == 1 and rand == 3 and not ZBots:HeroPicked(k) then
            return hero
        end
    end
end
 
function ZBots:HeroPicked(name)
    for i = 0, PlayerResource:GetPlayerCount() do
        if PlayerResource:IsValidPlayer(i) then
            local hero = PlayerResource:GetPlayer(i):GetAssignedHero()
            if hero and hero:GetUnitName() == name then
                print("zpr hero picked "..hero:GetUnitName()) 
                return true 
            end
        end
    end
    
    return false
end
 
function ZBots:GetRandomLane(team)
    local lane = RandomInt(1, 3)
    local side = 2 if team == false then side = 3 end
    
    while ZBots.LANE[lane][side] >= ZBots.MAX_BOTS_ON_ONE_LANE do
        lane = RandomInt(1, 3)
    end
    
    ZBots.LANE[lane][side] = ZBots.LANE[lane][side] + 1 
    return ZBots.LANE[lane][1]
end
 
function ZBots:ItemFilter(keys)
    local unit = EntIndexToHScript(keys.inventory_parent_entindex_const)
    local item = EntIndexToHScript(keys.item_entindex_const)
    
    if string.match(item:GetAbilityName(), "ward") and PlayerResource:GetSteamAccountID(unit:GetPlayerOwnerID()) == 0 then
        return false
    end
    
    return true
end

function ZBots:IsBot(playerId)
	return PlayerResource:GetConnectionState(playerId) == 1
end