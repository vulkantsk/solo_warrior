require("game_settings")
require("game_spawner")
require("item_drop")
require("libraries")
require("gamemode")

function Precache( context )
	PrecacheResource("soundfile", "soundevents/game_sounds_misc.vsndevts", context)
	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_axe.vsndevts", context )
end

function Activate()
	GameSettings:InitGameSettings()
--	GameRules:SetUseUniversalShopMode( true )


	local GM = GameRules:GetGameModeEntity()
	GM:SetCustomGameForceHero("npc_dota_hero_axe")
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)

	Convars:SetBool("sv_cheats", true)
end
