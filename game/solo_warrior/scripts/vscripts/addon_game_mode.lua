require("game_settings")
require("game_spawner")
require("item_drop")
require("talent_tree")
require("libraries")
require("gamemode")

--require zpr stuff
require("debug/commands")
require("debug/dprint")
require("stats/speedrun")
require("libraries/BigNum")
require("end")
--require("libraries/zbots")

function Precache( context )
	PrecacheResource("soundfile", "soundevents/game_sounds_misc.vsndevts", context)
	
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_axe.vsndevts", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context )
	
	PrecacheResource("particle", "particles/units/heroes/hero_dark_seer/dark_seer_attack_normal_punch.vpcf", context)
	
	Ending:precache(context)
end

function Activate()
	GameSettings:InitGameSettings()

	local GM = GameRules:GetGameModeEntity()
	GM:SetCustomGameForceHero("npc_dota_hero_axe")
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)

	Convars:SetBool("sv_cheats", true)
	
	--init zpr stuff
	Commands:init()
	Speedrun:init()
	Ending:init()
end
