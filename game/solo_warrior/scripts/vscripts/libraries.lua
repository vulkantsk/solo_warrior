
require_list = {
	"libraries/utility",
	"libraries/timers",
	"libraries/sounds",
}

for key, value in pairs(require_list) do
	require(value)
end 

modifier_list = {
	"modifier_extra_life"
}

for key, value in pairs(modifier_list) do
	LinkLuaModifier(value, "modifiers/"..value, 1)
end