modifier_talent_1 = class({
    IsHidden = function(self)
        return false
    end,
    IsDebuff = function(self)
        return false
    end,
    IsPurgable = function(self)
        return false
    end,
    IsPurgeException = function(self)
        return false
    end,
    IsStunDebuff = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
})