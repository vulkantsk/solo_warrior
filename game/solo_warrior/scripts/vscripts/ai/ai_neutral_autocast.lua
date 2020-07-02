function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end
	
	thisEntity:SetContextThink( "NeutralAutoCasterThink", NeutralAutoCasterThink, 1 )
end

function NeutralAutoCasterThink()
	if ( not thisEntity:IsAlive() ) then		--если юнит мертв
		return -1	
	end
	
	if GameRules:IsGamePaused() == true then	--если игра приостановлена
		return 1	
	end

	if thisEntity:IsChanneling() then	-- если юнит кастует скил
		return 1	
	end
	
	if thisEntity:IsControllableByAnyPlayer() then	-- если юнит принадлежит игроку, то поведение отключается
		return -1
	end
	
	local npc = thisEntity

	if not thisEntity.bInitialized then
		npc.vInitialSpawnPos = npc:GetOrigin()		-- точка спавна юнита
		npc.fMaxDist = npc:GetAcquisitionRange()	-- радиус агра 
		npc.bInitialized = true						-- флаг инициализации
		npc.agro = false							-- флаг агра
		
		npc.ability0 = FindAbility(npc, 0)			-- ищет способность по индексу
		npc.ability1 = FindAbility(npc, 1)			-- ищет способность по индексу
		npc.ability2 = FindAbility(npc, 2)			-- ищет способность по индексу
		npc.ability3 = FindAbility(npc, 3)			-- ищет способность по индексу
		npc.ability4 = FindAbility(npc, 4)			-- ищет способность по индексу
		npc.ability5 = FindAbility(npc, 5)			-- ищет способность по индексу
		
	end

	local search_radius 							-- радиус поиска зависит от того, имеет ли юнит агр
	if npc.agro then
		search_radius = npc.fMaxDist * 1.5			-- расшираяется
	else
		search_radius = npc.fMaxDist				-- становится обычным
	end
	
	-- Как далеко юнит находится от своей точки спавна ?
	local fDist = ( npc:GetOrigin() - npc.vInitialSpawnPos ):Length2D()
	if fDist > search_radius then
		RetreatHome()			-- если юнит слишком далеко, то идет на точку спавна
		return 3
	end
	
	local enemies = FindUnitsInRadius( 
						npc:GetTeamNumber(),		--команда юнита
						npc.vInitialSpawnPos,		--местоположение юнита
						nil,	--айди юнита (необязательно)
						search_radius + 50,	--радиус поиска
						DOTA_UNIT_TARGET_TEAM_ENEMY,	-- юнитов чьей команды ищем вражеской/дружественной
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	--юнитов какого типа ищем 
						DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	--поиск по флагам
						FIND_CLOSEST,	--сортировка от ближнего к дальнему 
						false )

	if #enemies == 0 then	-- если найденных юнитов нету
		if npc.agro then
			RetreatHome()	-- если юнит под действием агра
		end		
		return 0.5
	end
	
	local enemy = enemies[1]	-- врагом выбирается первый близжайший
	
	
	if npc.agro then	-- если юнит находится под действием агра
		
		AttackMove(npc, enemy)
--		npc:MoveToPositionAggressive(enemy:GetAbsOrigin())

		TryCastAbility(npc.ability0, npc, enemy)	-- попытка использовать способность
		TryCastAbility(npc.ability1, npc, enemy)	-- попытка использовать способность
		TryCastAbility(npc.ability2, npc, enemy)	-- попытка использовать способность
		TryCastAbility(npc.ability3, npc, enemy)	-- попытка использовать способность
		TryCastAbility(npc.ability4, npc, enemy)	-- попытка использовать способность
		TryCastAbility(npc.ability5, npc, enemy)	-- попытка использовать способность
	else
		local allies = FindUnitsInRadius(	-- ищет всех союзных братков в радиусе 
				npc:GetTeamNumber(), 
				npc.vInitialSpawnPos, 
				nil, 
				npc.fMaxDist, 
				DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
				FIND_CLOSEST, 
				false )
				
		for i=1,#allies do	-- заставляет братков быть агрессивными и атаковать врага
			local ally = allies[i]
			ally.agro = true	-- накладывает действие агра
			AttackMove(ally, enemy)	
		end	
	end	
	return 1
	
end

function FindAbility(unit, index)
	local ability = unit:GetAbilityByIndex(index)
	
	if ability then
		local ability_behavior = ability:GetBehavior()
		
		if bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_PASSIVE ) == DOTA_ABILITY_BEHAVIOR_PASSIVE then
			ability.behavior = "passive"	-- способность пассивна
		elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET ) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
			ability.behavior = "target"		-- способность направлена на юнита
		elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET ) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
			ability.behavior = "no_target"	-- способность без цели
		elseif bit.band( ability_behavior, DOTA_ABILITY_BEHAVIOR_POINT ) == DOTA_ABILITY_BEHAVIOR_POINT then
			ability.behavior = "point"		-- способность направлена на точку
		end
--		print("ability #"..index.." name = "..ability:GetAbilityName())
--		print("ability behavior = "..ability.behavior)
		
		return ability
	else
--		print("ability #"..index.."not found !!!")
		return nil
	end
	
end

function TryCastAbility(ability, caster, enemy)
	
	if ability == nil -- способность существует ?
	or  not ability:IsFullyCastable() 	-- способность можно использовать?
	or ability.behavior == "passive" 	-- способность пассивна ?
	or  enemy:IsMagicImmune()  then		-- цель имеет уммунитет к магии ?
		return
	end
	
	local order_type
--[[	
	print("CAST ABIITY")
	print("ability behavior = "..ability.behavior)
	print("enemy = "..enemy:GetUnitName())
	print("caster = "..caster:GetUnitName())
]]	
	-- теперь определяется каким образом будет использованна способность 
	
	if ability.behavior == "target" then
		order_type = DOTA_UNIT_ORDER_CAST_TARGET	-- на цель
	elseif ability.behavior == "no_target" then
		order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET	-- без цели
	elseif ability.behavior == "point" then
		order_type = DOTA_UNIT_ORDER_CAST_POSITION	-- на точку
	elseif ability.behavior == "passive" then
		return 
	end
	
	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),		-- индекс кастера
		OrderType = order_type,				-- тип приказа
		AbilityIndex = ability:entindex(),	-- индекс способности
		TargetIndex = enemy:entindex(), 	-- индекс врага
		Position = enemy:GetOrigin(),	 	-- положение врага
		Queue = false,						-- ждать очереди ?
	})
	caster:SetContextThink( "NeutralAutoCasterThink", NeutralAutoCasterThink, 1 ) -- если способность использована, то поведение начинается заного
	
end

function AttackMove( unit, enemy )
	if enemy == nil then
		return
	end
--	print("ATTACK MOVE")
	ExecuteOrderFromTable({
		UnitIndex = unit:entindex(),				--индекс кастера
		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,	-- тип приказа атака
		Position = enemy:GetOrigin(),				-- пощиция врага
		Queue = false,
	})

	return 1
end

function RetreatHome()
	thisEntity.agro = false	-- снимается действие агра

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity.vInitialSpawnPos		
	})
end

