if (not _G.TalentTree) then
    _G.TalentTree = class({})
end

function TalentTree:Init()
    if (not IsServer() or TalentTree.initialized) then
        return
    end
    local data = LoadKeyValues("scripts/kv/hero_talents.txt")
    self.talentsData = {}
    self.talentsRequirements = {}
    if (not data) then
        print("[TalentTree] Error loading scripts/kv/hero_talents.txt.")
        return
    end
    if (not data.Talents) then
        print("[TalentTree] Can't find talents data.")
        return
    end
    if (not data.Requirements) then
        print("[TalentTree] Can't find talents requirements data.")
        return
    end
    if (not data.Settings) then
        print("[TalentTree] Can't load settings. Using default values.")
        self.maxTalentsPerRequest = 10
    else
        self.maxTalentsPerRequest = tonumber(data.Settings.MaxTalentsPerRequest) or 10
    end
    for talentId, talentData in pairs(data.Talents) do
        local convertedId = tonumber(talentId)
        if (convertedId < 1) then
            print("[TalentTree] Talent id must be greater than 0. Skipped.")
        else
            if (TalentTree:IsValidTalent(convertedId, talentData) == true) then
                self.talentsData[convertedId] = talentData
            end
        end
    end
    for key, requirementsData in pairs(data.Requirements) do
        if (TalentTree:IsValidRequirement(key, requirementsData) == true) then
            self.talentsRequirements[key] = requirementsData
        end
    end
    TalentTree:InitPanaromaEvents()
    TalentTree.initialized = true
end

function TalentTree:IsValidRequirement(id, requirementsData)
    if (not requirementsData) then
        return false
    end
    requirementsData.Row = tonumber(requirementsData.Row)
    if (not requirementsData.Row) then
        print("[TalentTree] Can't find row for requirement", id ". Skipped.")
        return false
    end
    requirementsData.Column = tonumber(requirementsData.Column)
    if (not requirementsData.Column) then
        print("[TalentTree] Can't find column for requirement", id ". Skipped.")
        return false
    end
    requirementsData.HeroLevel = tonumber(requirementsData.HeroLevel)
    if (not requirementsData.HeroLevel) then
        print("[TalentTree] Can't find hero level for requirement", id ". Skipped.")
        return false
    end
    requirementsData.RequiredPoints = tonumber(requirementsData.RequiredPoints)
    if (not requirementsData.RequiredPoints) then
        print("[TalentTree] Can't find required points for requirement", id ". Skipped.")
        return false
    end
    return true
end

function TalentTree:IsValidTalent(talentId, talentData)
    if (not talentData) then
        return false
    end
    if (not talentData.Icon) then
        print("[TalentTree] Can't find icon for talent", talentId ". Skipped.")
        return false
    end
    if (not talentData.Modifier) then
        print("[TalentTree] Can't find modifier for talent", talentId, ". Skipped.")
        return false
    end
    if (not talentData.MaxLevel) then
        print("[TalentTree] Can't find max level for talent", talentId, ". Skipped.")
        return false
    end
    if (not talentData.Row) then
        print("[TalentTree] Can't find row for talent", talentId, ". Skipped.")
        return false
    end
    if (talentData.Row < 1) then
        print("[TalentTree] Row for talent ", talentId, " must be greater than 0. Skipped.")
        return false
    end
    if (not talentData.Column) then
        print("[TalentTree] Can't find column for talent", talentId, ". Skipped.")
        return false
    end
    if (talentData.Column < 1) then
        print("[TalentTree] Column for talent ", talentId, " must be greater than 0. Skipped.")
        return false
    end
    return true
end

function TalentTree:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("talent_tree_get_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeTalentsRequest'))
    CustomGameEventManager:RegisterListener("talent_tree_level_up_talent", Dynamic_Wrap(TalentTree, 'OnTalentTreeLevelUpRequest'))
    CustomGameEventManager:RegisterListener("talent_tree_get_state", Dynamic_Wrap(TalentTree, 'OnTalentTreeStateRequest'))
    CustomGameEventManager:RegisterListener("talent_tree_reset_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeResetRequest'))
end

function TalentTree:OnTalentTreeTalentsRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local currentTalent = 0
    local talentsData = {}
    local talentsCount = GetTableLength(TalentTree.talentsData)
    for talentId, talentData in pairs(TalentTree.talentsData) do
        if (currentTalent > TalentTree.maxTalentsPerRequest) then
            CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", { talents = json.encode(talentsData), count = talentsCount })
            talentsData = {}
            currentTalent = 0
        end
        table.insert(talentsData, { id = talentId, data = talentData })
        currentTalent = currentTalent + 1
    end
    if (#talentsData > 0) then
        CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", { talents = json.encode(talentsData), count = talentsCount })
    end
end

function TalentTree:GetLatestTalentID()
    local id = -1
    for talentId, _ in pairs(TalentTree.talentsData) do
        local convertedId = tonumber(talentId)
        if (convertedId > id) then
            id = convertedId
        end
    end
    return id
end

function TalentTree:SetupForHero(hero)
    if (not hero) then
        return
    end
    hero.talents = {}
    hero.talents.level = {}
    hero.talents.modifiers = {}
    for i = 1, TalentTree:GetLatestTalentID() do
        hero.talents.level[i] = 0
    end
    hero.talents.currentPoints = 0
end

function TalentTree:GetHeroCurrentTalentPoints(hero)
    if (not hero or not hero.talents) then
        return 0
    end
    return hero.talents.currentPoints
end

function TalentTree:AddTalentPointsToHero(hero, points)
    if (not hero or not hero.talents) then
        return false
    end
    points = tonumber(points)
    if (not points) then
        return false
    end
    hero.talents.currentPoints = hero.talents.currentPoints + points
    local event = {
        PlayerID = hero:GetPlayerOwnerID()
    }
    TalentTree:OnTalentTreeStateRequest(event)
end

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    if (TalentTree:IsHeroHaveTalentTree(unit) == false and unit.IsRealHero and unit:IsRealHero()) then
        TalentTree:SetupForHero(unit)
    end
end, nil)

function TalentTree:IsHeroHaveTalentTree(hero)
    if (not hero) then
        return false
    end
    if (hero.talents) then
        return true
    end
    return false
end

function TalentTree:GetTalentRow(talentId)
    if (TalentTree.talentsData[talentId]) then
        return TalentTree.talentsData[talentId].Row
    end
    return -1
end

function TalentTree:GetTalentColumn(talentId)
    if (TalentTree.talentsData[talentId]) then
        return TalentTree.talentsData[talentId].Column
    end
    return -1
end

function TalentTree:GetTalentMaxLevel(talentId)
    if (TalentTree.talentsData[talentId]) then
        return TalentTree.talentsData[talentId].MaxLevel
    end
    return -1
end

function TalentTree:GetHeroTalentLevel(hero, talentId)
    if (TalentTree:IsHeroHaveTalentTree(hero) == true and talentId and talentId > 0) then
        return hero.talents.level[talentId]
    end
    return 0
end

function TalentTree:SetHeroTalentLevel(hero, talentId, level)
    level = tonumber(level)
    if (TalentTree:IsHeroHaveTalentTree(hero) == true and talentId > 0 and level and level > -1) then
        hero.talents.level[talentId] = level
        if (level == 0) then
            if (hero.talents.modifiers[talentId]) then
                hero.talents.modifiers[talentId]:Destroy()
                hero.talents.modifiers[talentId] = nil
            end
        else
            if (not hero.talents.modifiers[talentId]) then
                hero.talents.modifiers[talentId] = hero:AddNewModifier(hero, nil, TalentTree.talentsData[talentId].Modifier, { duration = -1 })
            end
            if(hero.talents.modifiers[talentId]) then
                hero.talents.modifiers[talentId]:SetStackCount(level)
            end
        end
        local event = {
            PlayerID = hero:GetPlayerOwnerID()
        }
        TalentTree:OnTalentTreeStateRequest(event)
    end
end

function TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, talentId)
    if (not TalentTree.talentsData[talentId]) then
        return false
    end
    local row = TalentTree:GetTalentRow(talentId)
    local column = TalentTree:GetTalentColumn(talentId)
    local totalRequiredPoints = 0
    for _, requirementsData in pairs(TalentTree.talentsRequirements) do
        if (requirementsData.Column == column and requirementsData.Row == row) then
            totalRequiredPoints = requirementsData.RequiredPoints
            break
        end
    end
    local pointsSpendedInColumn = 0
    for i = 1, TalentTree:GetLatestTalentID() do
        if (TalentTree:GetTalentColumn(i) == column and TalentTree:GetTalentRow(i) < row) then
            pointsSpendedInColumn = pointsSpendedInColumn + TalentTree:GetHeroTalentLevel(hero, i)
        end
    end
    if (pointsSpendedInColumn >= totalRequiredPoints) then
        return true
    end
    return false
end

function TalentTree:IsHeroCanLevelUpTalent(hero, talentId)
    if (not TalentTree.talentsData[talentId]) then
        return false
    end
    if (TalentTree:GetHeroTalentLevel(hero, talentId) >= TalentTree:GetTalentMaxLevel(talentId)) then
        return false
    end
    if (TalentTree:GetHeroCurrentTalentPoints(hero) == 0) then
        return false
    end
    local row = TalentTree:GetTalentRow(talentId)
    local column = TalentTree:GetTalentColumn(talentId)
    local heroLevel = hero:GetLevel()
    for _, requirementsData in pairs(TalentTree.talentsRequirements) do
        if (requirementsData.Column == column and requirementsData.Row == row and heroLevel < requirementsData.HeroLevel) then
            return false
        end
    end
    local canLevelUp = true
    for i = 1, TalentTree:GetLatestTalentID() do
        if (TalentTree:GetTalentColumn(i) == column and TalentTree:GetTalentRow(i) == row and TalentTree:GetHeroTalentLevel(hero, i) > 0 and i ~= talentId) then
            canLevelUp = false
            break
        end
    end
    return canLevelUp
end

function TalentTree:OnTalentTreeResetRequest(event)
    if (not IsServer()) then
        return
    end
    if (event == nil or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
        return
    end
    local pointsToReturn = 0
    for i = 1, TalentTree:GetLatestTalentID() do
        pointsToReturn = pointsToReturn + TalentTree:GetHeroTalentLevel(hero, i)
        TalentTree:SetHeroTalentLevel(hero, i, 0)
    end
    TalentTree:AddTalentPointsToHero(hero, pointsToReturn)
end

function TalentTree:OnTalentTreeLevelUpRequest(event)
    if (not IsServer()) then
        return
    end
    if (event == nil or not event.PlayerID) then
        return
    end
    local talentId = tonumber(event.id)
    if (not talentId or talentId < 1 or talentId > TalentTree:GetLatestTalentID()) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
        return
    end
    if (TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, talentId) and TalentTree:IsHeroCanLevelUpTalent(hero, talentId)) then
        local talentLvl = TalentTree:GetHeroTalentLevel(hero, talentId)
        TalentTree:AddTalentPointsToHero(hero, -1)
        TalentTree:SetHeroTalentLevel(hero, talentId, talentLvl + 1)
    end
end

function TalentTree:OnTalentTreeStateRequest(event)
    if (not IsServer()) then
        return
    end
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    Timers:CreateTimer(0,
            function()
                local hero = player:GetAssignedHero()
                if (hero == nil) then
                    return 1.0
                end
                if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
                    return 1.0
                end
                local resultTable = {}
                for i = 1, TalentTree:GetLatestTalentID() do
                    local talentLvl = TalentTree:GetHeroTalentLevel(hero, i)
                    local talentMaxLvl = TalentTree:GetTalentMaxLevel(i)
                    local isDisabled = (TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, i) == false) or TalentTree:IsHeroCanLevelUpTalent(hero, i) == false
                    if (talentLvl == talentMaxLvl) then
                        isDisabled = false
                    end
                    table.insert(resultTable, { id = i, disabled = isDisabled, level = talentLvl, maxlevel = talentMaxLvl })
                end
                if (TalentTree:GetHeroCurrentTalentPoints(hero) == 0) then
                    for _, talent in pairs(resultTable) do
                        if (TalentTree:GetHeroTalentLevel(hero, talent.talent_id) == 0) then
                            talent.disabled = true
                            talent.lvlup = false
                        end
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_state_from_server", { talents = json.encode(resultTable), points = TalentTree:GetHeroCurrentTalentPoints(hero) })
            end)
end

TalentTree:Init()