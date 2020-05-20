
LinkLuaModifier( "modifier_axe_berserk_form", "heroes/hero_axe/berserk_form", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_berserk_form_passive", "heroes/hero_axe/berserk_form", LUA_MODIFIER_MOTION_NONE ) 
LinkLuaModifier( "modifier_axe_berserkers_call_armor", "heroes/hero_axe/berserk_form", LUA_MODIFIER_MOTION_NONE ) 

axe_berserk_form = class({})

function axe_berserk_form:GetIntrinsicModifierName()
	return "modifier_axe_berserk_form_passive"
end

function axe_berserk_form:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end

	return self.BaseClass.GetBehavior( self )
end

function axe_berserk_form:OnSpellStart()
	local caster = self:GetCaster()
	local point = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")

	caster:AddNewModifier(caster, self, "modifier_axe_berserk_form", {duration = duration})

	local enemies = caster:FindEnemyUnitsInRadius(point,250, nil)
	for _, enemy in pairs (enemies) do	
		local kv = {
		should_stun = 1,
		knockback_duration = 0.75,
		duration = 0.75,
		knockback_distance = 150,
		knockback_height = 200,
		center_x = point.x,
		center_y = point.y,
		center_z = point.z
		}
		enemy:AddNewModifier( caster, self, "modifier_knockback", kv )
	end	
end

modifier_axe_berserk_form_passive = class({
	IsHidden = function(self) return true end,
})

function modifier_axe_berserk_form_passive:OnCreated()
	self:StartIntervalThink(0.1)
end

function modifier_axe_berserk_form_passive:OnIntervalThink()
	local caster = self:GetCaster()
	local ability =self:GetAbility()

	
	if caster:HasScepter() and caster:IsAlive() then
		caster:AddNewModifier(caster, ability, "modifier_axe_berserk_form", {duration = 0.2})
	end
end

modifier_axe_berserk_form = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return false end,
    DeclareFunctions        = function(self) return 
        {           
        	MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
 --           MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT_ADJUST,
        } end,
})

function modifier_axe_berserk_form:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_axe_berserkers_call_armor", {})

		local model =  "models/items/axe/ti9_jungle_axe/axe_bare.vmdl"
--		local projectile_model = "particles/units/heroes/hero_dragon_knight/dragon_knight_elder_dragon_fire.vpcf"

		caster:EmitSound("Hero_Axe.BerserkersCall.Item.Shoutmask")
	  	local effect = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
		local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(pfx)

	  	local effect = "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_cullingblade_sprint_axe.vpcf"
		local pfx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN_FOLLOW, caster)
		self:AddParticle(pfx, true, true, 100, true, false)

		-- Saves the original model and attack capability
		if caster.caster_model == nil then 
			caster.caster_model = caster:GetModelName()
		end
		caster.caster_attack = caster:GetAttackCapability()

		-- Sets the new model and projectile
		caster:SetOriginalModel(model)
--		caster:SetRangedProjectileName(projectile_model)

		-- Sets the new attack type
--		caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

		caster.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
	    local model = caster:FirstMoveChild()
	    while model ~= nil do
	        if model:GetClassname() == "dota_item_wearable" then
	            model:AddEffects(EF_NODRAW) -- Set model hidden
	            table.insert(caster.hiddenWearables, model)
	        end
	        model = model:NextMovePeer()
	    end		
	end
end

function modifier_axe_berserk_form:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		caster:RemoveModifierByName("modifier_axe_berserkers_call_armor")

		caster:SetRenderColor(255, 255 , 255 )
		caster:SetModel(caster.caster_model)
		caster:SetOriginalModel(caster.caster_model)
		caster:SetAttackCapability(caster.caster_attack)

		-- Sets the new attack type
		caster:SetAttackCapability(caster.caster_attack)

		for i,v in pairs(caster.hiddenWearables) do
			v:RemoveEffects(EF_NODRAW)
		end
	end
end

function modifier_axe_berserk_form:GetActivityTranslationModifiers()
	return "axe_recall"
end
function modifier_axe_berserk_form:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("decrease_armor")*(-1)
end

function modifier_axe_berserk_form:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_axe_berserk_form:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_ms")
end


function modifier_axe_berserk_form:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("bonus_bat")
end

function modifier_axe_berserk_form:GetModifierBaseAttackTimeConstant_Adjust()
    return self:GetAbility():GetSpecialValueFor("bonus_bat")
end

function modifier_axe_berserk_form:GetEffectName()
	return "particles/econ/items/axe/ti9_jungle_axe/ti9_jungle_axe_misc_ambient.vpcf"
end

function modifier_axe_berserk_form:OnAttackLanded( params )
    if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then

			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
				local cleave_damage = params.damage * self:GetAbility():GetSpecialValueFor("cleave_damage_pct") / 100.0
				local cleave_radius = self:GetAbility():GetSpecialValueFor("cleave_radius")
				local effect = "particles/units/heroes/hero_magnataur/magnataur_empower_cleave_effect.vpcf"

				DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleave_damage, cleave_radius, cleave_radius, cleave_radius, effect )
			end
		end
    end
    return 0
end


