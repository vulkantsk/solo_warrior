
modifier_extra_life =class({
	IsHidden = function(self) return false end,
	IsDebuff = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsPurgeException = function(self)  return false end,
	IsStunDebuff = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
})

function modifier_extra_life:GetTexture()
    return "item_aegis"
end

function modifier_extra_life:DeclareFunctions()
    local decFuncs = 	{
		  MODIFIER_EVENT_ON_DEATH,
		  MODIFIER_PROPERTY_REINCARNATION,                      
		  MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

    return decFuncs
end

function modifier_extra_life:OnCreated()    
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()    
        -- Ability specials
        self.reincarnate_delay = self.ability:GetSpecialValueFor("duration")

--	self.reincarnate_delay = self:GetAbility:GetSpecialValueFor("duration")
    if IsServer() then
        -- Set WK as immortal!
        self.can_die = false

        -- Start interval think
        self:StartIntervalThink(0.05)
    end
end

function modifier_extra_life:OnIntervalThink()
    -- If caster has sufficent mana and the ability is ready, apply
    if (self.caster:GetMana() >= self.ability:GetManaCost(-1)) and (self.ability:IsCooldownReady()) and (not self.caster:HasModifier("modifier_item_imba_aegis")) then
        self.can_die = false
    else
        self.can_die = true
    end

end

function modifier_extra_life:ReincarnateTime()
    if IsServer() then  
        if not self.can_die and self.caster:IsRealHero() then
            return self.reincarnate_delay
--            return FrameTime()
        end

        return nil
    end
end

function modifier_extra_life:GetActivityTranslationModifiers()
    if self.can_die then
        return "reincarnate"
    end

    return nil
end


function modifier_extra_life:OnDeath(keys)
    if IsServer() then
        local unit = keys.unit
        local reincarnate = keys.reincarnate

        -- Only apply if the caster is the unit that died
        if self:GetParent() == unit and reincarnate then            
            self:Reincarnate()
         end
    end
end
function modifier_extra_life:Reincarnate()
	if not  IsServer() then 
		return
	end
--	if not self:GetCaster():HasScepter() then
--		return
--	end
	if  not self:GetCaster():IsRealHero() then
		return
	end

	if not self:GetCaster():HasModifier("modifier_item_imba_aegis") then

		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local manaHave = caster:GetMana()
		local manaCost = ability:GetManaCost(-1)
		local stack_count = self:GetStackCount()
        
        if stack_count <= 1 then
            self:Destroy()
        else
            self:DecrementStackCount()
        end
	end
end