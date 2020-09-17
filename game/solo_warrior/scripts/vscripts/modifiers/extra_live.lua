LinkLuaModifier("modifier_meepo_down_up", "heroes/hero_meepo/down_up", LUA_MODIFIER_MOTION_NONE)


meepo_down_up = meepo_down_up or class({})

function meepo_down_up:IsHiddenWhenStolen() 	return false end
function meepo_down_up:IsRefreshable() 			return true end
function meepo_down_up:IsStealable() 			return true end
function meepo_down_up:IsNetherWardStealable() 	return false end
--

function meepo_down_up:GetIntrinsicModifierName()
	return "modifier_meepo_down_up"
end


modifier_meepo_down_up =class({
	IsHidden = function(self) return true end,
	IsDebuff = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsPurgeException = function(self)  return false end,
	IsStunDebuff = function(self) return false end,
})

function modifier_meepo_down_up:RemoveOnDeath()
	if self:GetCaster():IsRealHero() then
		return false 
	else
		return true
	end
end
function modifier_meepo_down_up:IsPermanent() 				return true end
function modifier_meepo_down_up:AllowIllusionDuplicate() 	return true end

function modifier_meepo_down_up:DeclareFunctions()
    local decFuncs = 	{
		  MODIFIER_EVENT_ON_DEATH,
		  MODIFIER_PROPERTY_REINCARNATION,                      
		  MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

    return decFuncs
end

function modifier_meepo_down_up:OnCreated()    
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

function modifier_meepo_down_up:OnIntervalThink()
    -- If caster has sufficent mana and the ability is ready, apply
    if (self.caster:GetMana() >= self.ability:GetManaCost(-1)) and (self.ability:IsCooldownReady()) and (not self.caster:HasModifier("modifier_item_imba_aegis")) then
        self.can_die = false
    else
        self.can_die = true
    end

end

function modifier_meepo_down_up:ReincarnateTime()
    if IsServer() then  
        if not self.can_die and self.caster:IsRealHero() then
            return self.reincarnate_delay
--            return FrameTime()
        end

        return nil
    end
end

function modifier_meepo_down_up:GetActivityTranslationModifiers()
    if self.can_die then
        return "reincarnate"
    end

    return nil
end


function modifier_meepo_down_up:OnDeath(keys)
    if IsServer() then
        local unit = keys.unit
        local reincarnate = keys.reincarnate

        -- Only apply if the caster is the unit that died
        if self:GetParent() == unit and reincarnate then            
            self:Reincarnate()
         end
    end
end
function modifier_meepo_down_up:Reincarnate()
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
		
		if not ability:IsCooldownReady() or manaHave < manaCost then
			self.reincarnation_death = false
		else
			self.reincarnation_death = true
		
			ability:UseResources(true,false,true)
		end
	end
end