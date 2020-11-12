if (not _G.TalentTree) then
    _G.TalentTree = class({})
end

function TalentTree:Init()
    if (not IsServer()) then
        return
    end
    self.data = LoadKeyValues("scripts/kv/hero_talents.txt")
    self.talents = {}
    self.maxTalentsPerRequest = 5
    if (not self.data) then
        print("[TalentTree] Error loading scripts/kv/hero_talents.txt.")
        return
    end
    if (not self.data.Talents) then
        print("[TalentTree] Can't find talents data.")
        return
    end
    for talentId, talentData in pairs(self.data.Talents) do
        if (TalentTree:IsValidTalent(talentId, talentData) == true) then
            self.talents[talentId] = talentData
        end
    end
    TalentTree:InitPanaromaEvents()
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
    if (not talentData.RequiredPoints) then
        print("[TalentTree] Can't find required talent points for talent", talentId, ". Skipped.")
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
    if (not talentData.Column) then
        print("[TalentTree] Can't find column for talent", talentId, ". Skipped.")
        return false
    end
    return true
end

function TalentTree:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("talent_tree_get_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeTalentsRequest'))
end

function TalentTree:OnTalentTreeTalentsRequest(event)
    if(not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if(not player) then
        return
    end
    local currentTalent = 0
    local talentsData = {}
    print("TalentTree.maxTalentsPerRequest", TalentTree.maxTalentsPerRequest)
    for talentId, talentData in pairs(TalentTree.talents) do
        if (currentTalent > TalentTree.maxTalentsPerRequest) then
            CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", { talents = json.encode(talentsData) })
            talentsData = {}
            currentTalent = 0
        end
        table.insert(talentsData, { id = talentId, data = talentData })
        currentTalent = currentTalent + 1
    end
    if (#talentsData > 0) then
        CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", { talents = json.encode(talentsData) })
    end
end

TalentTree:Init()