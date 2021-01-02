
if ItemDrop == nil then
	_G.ItemDrop = class({})
end

ItemDrop.item_drop = {
--		{items = {"item_branches"}, chance = 5, duration = 5, limit = 3, units = {} },
		{items = {"item_belt_of_strength","item_boots_of_elves","item_robe"}, chance = 10, limit = 5, units = {"npc_dota_neutral_kobold","npc_dota_neutral_centaur_outrunner"}},--50% drop from list with limit --limit -это скольк таких итемов может выпасть
		--{items = {"item_flask"}, chance = 25, duration = 10},-- global drop 25%   --имхо вообще не рулит...залочивает слот. выкинь-подбери - нееее!!! так не пойдет!!!
		{items = {"item_wraith_band"}, units ={"npc_neutral_boss_1"}},      -- если указан units - то итем может упасть тольк с этих юнитов
		{items = {"item_quarterstaff"}, units ={"npc_neutral_boss_2"}},
		{items = {"item_lifesteal"}, units ={"npc_neutral_boss_3"}},
		--все что ниже нахимичил ЕНОТ. А енотов бить нельзя кста!!!=)
		{items = {"item_clarity"}, chance = 10, duration = 10, units = {"npc_line_creep_2","npc_line_creep_4"}},-- chance = шанс дропа со всех -Х(стока-то)%, пропадает(уничтожается с карты) через duration = 10 сек если не поднять!
--		{items = {"item_faerie_fire"}, chance = 10, duration = 15},
--		{items = {"item_greater_faerie_fire"}, chance = 2, duration = 10},
        {items = {"item_havoc_hammer"}, chance = 1, limit = 1},
        {items = {"item_dmg_stat_1_1"}, limit = 1, units ={"npc_line_boss_1"}},
}

ItemDrop.secret_items = {
--	["point_name"] = "item_name",
	["item_spawner_1"] = "item_power_treads",
	["item_spawner_2"] = "item_test",

}
function ItemDrop:InitGameMode()
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
end

function ItemDrop:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		ItemDrop:SpawnItems()
	end
end

function ItemDrop:SpawnItems()
	local items = self.secret_items
	for point_name,item_name in pairs(items) do
		local point = Entities:FindByName(nil, point_name)
		if point then
			point = point:GetAbsOrigin()
			local newItem = CreateItem( item_name, nil, nil )
			local drop = CreateItemOnPositionSync( point, newItem )
		else
			print("point with name "..point_name.." dont exist !")
		end
	end
end

function ItemDrop:OnEntityKilled( keys )
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local name = killedUnit:GetUnitName()
	local team = killedUnit:GetTeam()

	if team ~= DOTA_TEAM_GOODGUYS and name ~= "npc_dota_thinker" then
		ItemDrop:RollItemDrop(killedUnit)
	end

end

function ItemDrop:RollItemDrop(unit)
	local unit_name = unit:GetUnitName()

	for _,drop in ipairs(self.item_drop) do
		local items = drop.items or nil
		local items_num = #items
		local units = drop.units or nil -- если юниты не были определены, то срабатывает для любого
		local chance = drop.chance or 100 -- если шанс не был определен, то он равен 100
		local loot_duration = drop.duration or nil -- длительность жизни предмета на земле
		local limit = drop.limit or nil -- лимит предметов
		local item_name = items[1] -- название предмета
		local roll_chance = RandomFloat(0, 100)
			
		if units then 
			for _,current_name in pairs(units) do
				if current_name == unit_name then
					units = nil
					break
				end
			end
		end

		if units == nil and (limit == nil or limit > 0) and roll_chance < chance then
			if limit then
				drop.limit = drop.limit - 1
			end

			if items_num > 1 then
				item_name = items[RandomInt(1, #items)]
			end

			local spawnPoint = unit:GetAbsOrigin()	
			local newItem = CreateItem( item_name, nil, nil )
			local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
			local dropRadius = RandomFloat( 50, 100 )

			newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
			if loot_duration then
				newItem:SetContextThink( "KillLoot", 
					function() 
						if drop:IsNull() then
							return
						end

						local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
						ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
						ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
						ParticleManager:ReleaseParticleIndex( nFXIndex )
					--	EmitGlobalSound("Item.PickUpWorld")

						UTIL_Remove( item )
						UTIL_Remove( drop )
					end, loot_duration )
			end
		end
	end	
end

function KillLoot( item, drop )

	if drop:IsNull() then
		return
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
--	EmitGlobalSound("Item.PickUpWorld")

	UTIL_Remove( item )
	UTIL_Remove( drop )
end

ItemDrop:InitGameMode()