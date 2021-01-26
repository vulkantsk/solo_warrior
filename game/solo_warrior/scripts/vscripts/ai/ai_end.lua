if AI_END == nil then
	_G.AI_END = class({})
	
	AI_END.THINK_DELAY = 0.5
    AI_END.List = {}
end

--common functions
function AI_END:Start()
    Timers:CreateTimer(0.0, function()
        AI_END:Think()

        return AI_END.THINK_DELAY
    end)
end

function AI_END:AddUnit(unit)
    unit.cast_cd = 0.0
	unit.move_cd = 3.0
	
    AI_END.List[#AI_END.List+1] = unit
end

function AI_END:Think()
	for i = 1, #AI_END.List do
		local ai = AI_END.List[i]
        if ai ~= nil and ai:IsNull() == false and ai:IsAlive() then
			if ai.cast_cd <= 0.0 then
				AI_END:UnitThink(ai)
			else
				ai.cast_cd = ai.cast_cd - AI_END.THINK_DELAY
			end
        end
    end
end

function AI_END:FindUnits(team, pos, radius)
	return FindUnitsInRadius(team, pos, nil, radius or 3500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
end

function AI_END:GetAbility(unit, name)
	local ability = unit:FindAbilityByName(name)
	
	if ability and ability:IsTrained() and not ability:IsPassive() and ability:GetAbilityType() < 2 and ability:IsFullyCastable() then
		return ability
	end
	
	return false
end
--

--hardcode
AI_END.UnitEqualsHero = 
{
	dazzl = "npc_sw_ending_unit_dire_1",
	rasta = "npc_sw_ending_unit_dire_2",
	lycan = "npc_sw_ending_unit_dire_3",
	beast = "npc_sw_ending_unit_dire_4",
	huskr = "npc_sw_ending_unit_dire_5",
}

function AI_END:UnitThink(unit)
	local ability = false
	local name = unit:GetUnitName()
	
	--DAZZLE
	if name == AI_END.UnitEqualsHero.dazzl then --если даззл
		--dazzle 1 poison
		ability = AI_END:GetAbility(unit, "dazzle_poison_touch")
		if ability then
			local enemies = AI_END:FindUnits(DOTA_TEAM_GOODGUYS, unit:GetAbsOrigin())
			for _,enemy in pairs(enemies) do
				if enemy then
					CastTarget( unit, ability, enemy )
					break;
				end
			end
		end		
		--
		
		--dazzle 2 grave
		ability = AI_END:GetAbility(unit, "dazzle_shallow_grave")
		if ability then
			local mates = AI_END:FindUnits(unit:GetTeam(), unit:GetAbsOrigin())
			for _,mate in pairs(mates) do
				if mate and mate:GetHealth() <= (mate:GetMaxHealth() / 100 * 25) then
					CastTarget( unit, ability, mate )
					break;
				end
			end
		end
		--
		
		--dazzle 3 heal
		ability = AI_END:GetAbility(unit, "dazzle_shadow_wave")
		if ability then
			local mates = AI_END:FindUnits(unit:GetTeam(), unit:GetAbsOrigin())
			for _,mate in pairs(mates) do
				if mate and mate:GetHealth() <= (mate:GetMaxHealth() / 100 * 90) then
					CastTarget( unit, ability, mate )
					break;
				end
			end
		end
		--
	--
	
	--SHADOW SHAMAN
	elseif name == AI_END.UnitEqualsHero.rasta then --если шаман		
		-- shaman 4 zmei
		ability = AI_END:GetAbility(unit, "shadow_shaman_mass_serpent_ward")
		if ability and Ending.ancient and DistanceUnitTo(unit, Ending.ancient:GetAbsOrigin()) < 1000 then
			CastPosition( unit, ability, Ending.ancient:GetAbsOrigin() )
		end
		--
		
		local enemies = AI_END:FindUnits(DOTA_TEAM_GOODGUYS, unit:GetAbsOrigin())
		for _, enemy in pairs(enemies) do
			-- shaman 1 molnija
			ability = AI_END:GetAbility(unit, "shadow_shaman_ether_shock")
			if ability and enemy then
				CastTarget( unit, ability, enemy )
				goto continue;
			end
			--
			
			-- shaman 2 hex
			ability = AI_END:GetAbility(unit, "shadow_shaman_voodoo")
			if ability and enemy then
				CastTarget( unit, ability, enemy )
				goto continue;
			end
			--
			
			--shaman 3 setka
			ability = AI_END:GetAbility(unit, "shadow_shaman_shackles")
			if ability and enemy then
				CastTarget( unit, ability, enemy )
				unit.cast_cd = ability:GetDuration()
				return;
			end	
			--
			
			::continue::
		end
	--
	
	--LYCAN
	elseif name == AI_END.UnitEqualsHero.lycan then --если ликан
		-- lycan 1 summon
		ability = AI_END:GetAbility(unit, "lycan_summon_wolves")
		if ability then
			CastNoTarget( unit, ability )
		end
		--
		
		-- lycan 2 howl
		ability = AI_END:GetAbility(unit, "lycan_howl")
		if ability then
			CastNoTarget( unit, ability )
		end		
		--
		
		-- lycan 4 ult
		ability = AI_END:GetAbility(unit, "lycan_shapeshift")
		if ability then
			CastNoTarget( unit, ability )
		end	
		--
	--
	
	--BEASTMASTER
	elseif name == AI_END.UnitEqualsHero.beast then --если бм
		--beast 1 axes
		ability = AI_END:GetAbility(unit, "beastmaster_wild_axes")
		if ability then
			local enemies = AI_END:FindUnits(DOTA_TEAM_GOODGUYS, unit:GetAbsOrigin())
			for _,enemy in pairs(enemies) do
				if enemy then
					CastPosition( unit, ability, enemy:GetAbsOrigin() )
					break;
				end
			end
		end		
		--
		
		--beast 4 ult
		ability = AI_END:GetAbility(unit, "beastmaster_primal_roar")
		if ability and unit:GetHealth() < unit:GetMaxHealth() then
			local enemies = AI_END:FindUnits(DOTA_TEAM_GOODGUYS, unit:GetAbsOrigin())
			for _,enemy in pairs(enemies) do
				if enemy then
					CastTarget( unit, ability, enemy )
					break;
				end
			end
		end		
		--
	--
	
	--HUSKAR
	elseif name == AI_END.UnitEqualsHero.huskr then --если хускар
		--huskar 1 fire
		ability = AI_END:GetAbility(unit, "huskar_inner_fire")
		if ability then
			if #AI_END:FindUnits(DOTA_TEAM_GOODGUYS, unit:GetAbsOrigin(), 400) >= 2 then
				CastNoTarget( unit, ability )
			end
		end
		--
		
		--huskar 2 spear
		ability = AI_END:GetAbility(unit, "huskar_burning_spear")
		if ability and ability:GetAutoCastState() == false then
			ability:ToggleAutoCast()
		end
		--
		
		--huskar 4 ult
		ability = AI_END:GetAbility(unit, "huskar_life_break")
		if ability then
			local enemies = AI_END:FindUnits(DOTA_TEAM_GOODGUYS, unit:GetAbsOrigin())
			for _,enemy in pairs(enemies) do
				if enemy then
					CastTarget( unit, ability, enemy )
					break;
				end
			end
		end		
		--
	end
	--
	
	--keep moving to target
	if unit.cast_cd <= 0.0 then 
		if unit.move_cd <= 0.0 then
			AggressiveMoveUnitTo(unit, unit.initialGoal)
			unit.move_cd = 5.0
		else
			unit.move_cd = unit.move_cd - AI_END.THINK_DELAY
		end
	end
end
--

--orders
function DistanceUnitTo( unit, position )
    return (unit:GetAbsOrigin() - position):Length2D()
end

function MoveUnitTo( unit, position, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = position,
        Queue = queue
    })
end

function AggressiveMoveUnitTo( unit, position, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        Position = position,
        Queue = queue
    })
end

function UnitAttackTarget( unit, target, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
        TargetIndex = target:GetEntityIndex(),
        Queue = queue
    })
end

function UnitLevelUpAbility( unit, ability, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_TRAIN_ABILITY,
        AbilityIndex = ability:GetEntityIndex(),
        Queue = queue
    })
end

function CastNoTarget( unit, ability, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = ability:GetEntityIndex(),
        Queue = queue
    })
end

function CastPosition( unit, ability, position, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = ability:GetEntityIndex(),
        Position = position,
        Queue = queue
    })
end

function CastTarget( unit, ability, target, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        AbilityIndex = ability:GetEntityIndex(),
        TargetIndex = target:entindex(),
        Queue = queue
    })
end

function UnitStop( unit, queue )
    if queue == nil then queue = false end
    ExecuteOrderFromTable({
        UnitIndex = unit:GetEntityIndex(),
        OrderType = DOTA_UNIT_ORDER_STOP,
        Queue = queue
    })
end
--