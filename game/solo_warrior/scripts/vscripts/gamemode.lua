if GameMode == nil then
	_G.GameMode = class({})
end

function GameMode:InitGameMode()
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(self, 'OnAbilityUsed'), self)
end

function GameMode:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(self, 'ExecuteOrderFilter'), self )
		PlayerResource:SetCameraTarget(0, PlayerResource:GetPlayer(0):GetAssignedHero())
	end
end

--ФИЛЬТРЫ
function GameMode:ExecuteOrderFilter(filterTable)
	local order_type = filterTable.order_type
	local unit
	if filterTable.units["0"] then
		unit = EntIndexToHScript(filterTable.units["0"])
	else
		return true
	end

	local playerId = filterTable.issuer_player_id_const
	local target = EntIndexToHScript(filterTable.entindex_target)
	local ability = EntIndexToHScript(filterTable.entindex_ability)

	local abilityname
	if ability and ability.GetAbilityName then
		abilityname = ability:GetAbilityName()
	end

	if order_type == DOTA_UNIT_ORDER_SELL_ITEM and ability and unit then 
		GameMode:SellItem(playerId, unit, ability)
	end

	return true
end

function GameMode:SellItem(playerId, unit, item)
	local itemname = item:GetAbilityName()
	local cost = item:GetCost()
	if unit:IsIllusion() or
		unit:IsTempestDouble() or
		unit:IsStunned() then
		return
	end
	if GameRules:IsGamePaused() then
		Containers:DisplayError(playerId, "#dota_hud_error_game_is_paused")
		return
	end
	if not item:IsSellable() then
		Containers:DisplayError(playerId, "dota_hud_error_cant_sell_item")
		return
	end
	if item:IsStackable() then
		local chargesRate = item:GetCurrentCharges() / item:GetInitialCharges()
		cost = cost * chargesRate
	end
	if GameRules:GetGameTime() - item:GetPurchaseTime() > 10 then
		cost = cost / 2
	else
		return
	end
	PlayerResource:ModifyGold(playerId, cost, false, 0)
end

--ИВЕНТЫ
function GameMode:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()
	
end

function GameMode:OnAbilityUsed(keys)
	print('[BAREBONES] AbilityUsed')
	DeepPrintTable(keys)

--	local player = EntIndexToHScript(keys.PlayerID)
	local ability_name = keys.abilityname
	local caster = EntIndexToHScript(keys.caster_entindex)
	
	
	if abilityname == "filler_ability"  then
		local ability = caster:FindAbilityByName(ability_name)
		if ability then
			caster:RemoveAbility(ability_name)
		end		
	end

end
function GameMode:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)
	local unit_name = unit:GetUnitName()
	
end

function GameMode:ItemHelp_GiveModifier(unit, sModifierName, keys)
	local item = CreateItem("item_help", nil, nil)
    item:ApplyDataDrivenModifier(unit, unit, sModifierName, keys)
	UTIL_Remove(item)
end

--
GameMode:InitGameMode()