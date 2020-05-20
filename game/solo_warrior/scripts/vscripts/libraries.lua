
require_list = {
	"libraries/utility",
	"libraries/timers",
	"libraries/sounds",
}

for key, value in pairs(require_list) do
	require(value)
end 

