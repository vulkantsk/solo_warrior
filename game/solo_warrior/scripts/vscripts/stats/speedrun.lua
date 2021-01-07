-- статистика спидранеров
if Speedrun == nil then
    _G.Speedrun = class({})
end

function Speedrun:init()
	Speedrun.url = "http://185.180.231.205/solowarrior/?"
	Speedrun.key = GetDedicatedServerKeyV2("VETALYA_LOH_HAHAHA")
	if not IsDedicatedServer() and IsInToolsMode() then Speedrun.key = "TESTING" end
	Speedrun.LastRequestBody = {}
	
	Speedrun.time = 0
	Speedrun.pb = 0
	Speedrun.wr = 0
	
	Speedrun.alive = true
	Speedrun.sid = 0
	
	ListenToGameEvent('dota_game_state_change', Dynamic_Wrap(Speedrun, 'OnStateChange'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(Speedrun, 'OnPlayerReconnect'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Speedrun, 'OnEntityKilled'), self)
end

function Speedrun:OnStateChange(keys)
	if IsServer() then
		local state = GameRules:State_Get()
		DPRINT("STATE: "..state)
		
		if state == DOTA_GAMERULES_STATE_PRE_GAME then
			Speedrun.sid = PlayerResource:GetSteamAccountID(0)
			Speedrun:GetRecords()
		elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			Speedrun:StartTimer()
		elseif state == DOTA_GAMERULES_STATE_POST_GAME and Speedrun:IsWin() then
			Speedrun:SendStat()
		end	
	end
end

function Speedrun:GetRecords()
	Speedrun:SimpleRequest(Speedrun.url.."sid="..Speedrun.sid, "LOADSTAT")
	Speedrun:SimpleRequest(Speedrun.url, "LOADTOP")
	
	Timers:CreateTimer(1.0, function()
		if Speedrun.LastRequestBody["LOADTOP"] == nil then return 0.1 end
		Speedrun:SetWR(Speedrun:Decode(Speedrun.LastRequestBody["LOADTOP"])[1]["time"])	
		Speedrun:SetPB(Speedrun:Decode(Speedrun.LastRequestBody["LOADSTAT"])[1]["time"])			
	end)
end
function Speedrun:SetWR(time)
	Speedrun.wr = time
	CustomGameEventManager:Send_ServerToAllClients( "speedrun_wr", {time = time} )
end
function Speedrun:SetPB(time)
	Speedrun.pb = time
	CustomGameEventManager:Send_ServerToAllClients( "speedrun_pb", {time = time} )
end

function Speedrun:Decode(body)
	local obj, pos, err = json.decode(body)
	return obj
end

function Speedrun:StartTimer()
	Timers:CreateTimer({
    useGameTime = false,
    endTime = 0,
    callback = function()
		if not (GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME) then
			Speedrun.time = Speedrun.time + 1
			CustomGameEventManager:Send_ServerToAllClients( "speedrun_time", {time = Speedrun.time} )
			return 1.0
		end
	end
	})
end

function Speedrun:SimpleRequest(url, sName)
    local req = CreateHTTPRequestScriptVM("GET",url)
	req:Send(function(res)
	    print("speedrun http SimpleRequest code: "..res.StatusCode)		
        if res.StatusCode == 200 then
		    Speedrun.LastRequestBody[sName] = res.Body
		end
    end)
end


function Speedrun:IsWin()
	if Speedrun.alive then --and not IsCheatMode() and IsDedicatedServer() then
		return true
	end
	return false
end

function Speedrun:SendStat()
	local url = Speedrun.url.."key="..Speedrun.key.."&time="..Speedrun.time.."&sid="..Speedrun.sid

	Speedrun:SimpleRequest(url, "SAVESTAT")
	DPRINT("RUN SENDED")
end

function Speedrun:OnPlayerReconnect(keys)
	Timers:CreateTimer(0, function()
		if PlayerResource:GetConnectionState(keys.PlayerID) == DOTA_CONNECTION_STATE_CONNECTED then
			Timers:CreateTimer(2.25, function()
				Speedrun:SetWR(Speedrun.wr)
				Speedrun:SetPB(Speedrun.pb)
			end)
		else return 0.1 end
	end)
end

function Speedrun:OnEntityKilled(keys)
	local npc = EntIndexToHScript(keys.entindex_killed)
	
	if npc:IsRealHero() and not npc:HasModifier("modifier_extra_life") then
		Speedrun.alive = false
		DPRINT("Run's Dead")
	end
end