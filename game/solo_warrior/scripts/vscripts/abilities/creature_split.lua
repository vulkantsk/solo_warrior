function SplitterInit(data)
	local caster = data.caster
--	local split_count = self:GetSpecialValueFor("split_count")
	print("caster = "..caster:GetUnitName())

	if data.split_name then
		caster.split_name = data.split_name
		caster.split_count = data.split_count
		print("split name = "..caster.split_name)
		print("split count = "..caster.split_count)
	else
		print("split name = "..data.split_name.."doesnt exist !")
	end
end


