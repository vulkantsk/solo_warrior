if (not _G.TalentTree) then
    _G.TalentTree = class({})
end

function TalentTree:Init()
    if (not IsServer()) then
        return
    end
    self.data = LoadKeyValues("scripts/kv/hero_talents.txt")
    if (not self.data.TalentTree) then
        print("[TalentTree] Error loading scripts/kv/hero_talents.txt.")
        return
    end
    if (not self.data.TalentTree.Talents) then
        print("[TalentTree] Can't find talents data.")
        return
    end
    for talentId, talentData in pairs(self.data.TalentTree.Talents) do
        if (TalentTree:IsValidTalent(talentId, talentData)) then
            CustomNetTables:SetTableValue("talent_tree", tostring(talentId), talentData)
        end
    end
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

TalentTree:Init()