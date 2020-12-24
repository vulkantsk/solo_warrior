function SetModStackCount(event)
    local caster = event.caster
	local modname = event.Modifier
    local stacks = event.Stacks
    caster:FindModifierByName(modname):SetStackCount(stacks)
end