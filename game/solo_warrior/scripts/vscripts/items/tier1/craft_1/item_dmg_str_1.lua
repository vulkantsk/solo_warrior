LinkLuaModifier("modifier_item_dmg_str_1", "items/tier1/craft_1/item_dmg_str_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_thinker_item_dmg_str_1", "items/tier1/craft_1/item_dmg_str_1", LUA_MODIFIER_MOTION_NONE)

item_dmg_str_1 = class({})

function item_dmg_str_1:GetIntrinsicModifierName()
	return "modifier_item_dmg_str_1"
end

item_dmg_str_1_1 = class(item_dmg_str_1)
item_dmg_str_1_2 = class(item_dmg_str_1)

modifier_item_dmg_str_1 = class({
	IsHidden 		= function(self) return true end,
	GetAttributes 	= function(self) return MODIFIER_ATTRIBUTE_MULTIPLE end,
	DeclareFunctions  = function(self) return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}end,
})

function modifier_item_dmg_str_1:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_dmg")
end

function modifier_item_dmg_str_1:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_str")
end

function modifier_item_dmg_str_1:OnCreated()
	local ability = self:GetAbility()
	if ability.thinkers == nil then
		ability.thinkers = {}
	end
	self:GetParent():EmitSound("DOTA_Item.Mjollnir.Activate")
end

function modifier_item_dmg_str_1:GetEffectName()
	return "particles/items2_fx/mjollnir_shield.vpcf"
end


function modifier_item_dmg_str_1:OnAttackLanded(data)
	local caster = self:GetCaster()
	local target = data.target
	local attacker = data.attacker

	if target == caster and not attacker:IsBuilding() and not attacker:IsMagicImmune() then
		local ability = self:GetAbility()
		local trigger_chance = ability:GetSpecialValueFor("trigger_chance")

		if RollPercentage(trigger_chance) then
			caster:EmitSound("Item.Maelstrom.Chain_Lightning")

			local thinker = CreateModifierThinker(caster, ability, "modifier_thinker_item_dmg_str_1", nil, caster:GetAbsOrigin(), caster:GetTeam(), false)
			thinker.id = thinker:entindex()
			table.insert(ability.thinkers, thinker.id, thinker)
			local thinker_modifier = thinker:FindModifierByName("modifier_thinker_item_dmg_str_1")
			thinker_modifier:ChainLight(caster, attacker)
		end
	end
end

modifier_thinker_item_dmg_str_1 = class({})

function modifier_thinker_item_dmg_str_1:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.bounce_damage = 	self.ability:GetSpecialValueFor("bounce_damage")
	self.bounce_count = 	self.ability:GetSpecialValueFor("bounce_count")
	self.bounce_radius = 	self.ability:GetSpecialValueFor("bounce_radius")
	self.bounce_interval = 	self.ability:GetSpecialValueFor("bounce_interval")
	
	self.target_count = 0
	self.bounced_targets = {}
end
function modifier_thinker_item_dmg_str_1:OnDestroy()
	table.remove(self.ability.thinkers, self.parent:entindex())
end

function modifier_thinker_item_dmg_str_1:ChainLight(target1, target2)
	self.bounced_targets[target2:entindex()] = true
	self.target_count = self.target_count + 1

	target2:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
--	ZapThem(caster, ability, caster, target, damage)

	local particle = "particles/items_fx/chain_lightning.vpcf"
--	if ability:GetAbilityName() == "item_imba_jarnbjorn" then
--		particle = "particles/items_fx/chain_lightning_jarnbjorn.vpcf"
--	end

	local bounce_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target1)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 0, target1, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(bounce_pfx, 1, target2, PATTACH_POINT_FOLLOW, "attach_hitloc", target2:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(bounce_pfx, 2, Vector(1, 1, 1))
	ParticleManager:ReleaseParticleIndex(bounce_pfx)

	ApplyDamage({
		attacker = self.caster, 
		victim = target2, 
		ability = self.ability, 
		damage = self.bounce_damage, 
		damage_type = DAMAGE_TYPE_MAGICAL})

	Timers:CreateTimer(self.bounce_interval, function()
		self.trigger = false
		if self.target_count >= self.bounce_count then
			self:Destroy()
			return
		end

		local nearby_enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), 
					target2:GetAbsOrigin(), 
					nil, 
					self.bounce_radius, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
					FIND_ANY_ORDER, 
					false)

		for _, enemy in pairs(nearby_enemies) do
			local enemy_index = enemy:entindex()
			if self.bounced_targets[enemy_index] == nil then
				self:ChainLight(target2, enemy)
				self.trigger = true
				break
			end
		end

		if self.trigger == false then
			self:Destroy()
		end
	end)
end

