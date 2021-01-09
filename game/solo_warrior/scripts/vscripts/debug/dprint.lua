-- принты для дебага шобы можно было отключать без закоменчивания тысячи строк DPRINT("") DPRINTTABLE(table)
--[[включить true, отключить false]] DEBUG_PRINT_ENABLED = true --false

function DPRINT(msg)
	if DEBUG_PRINT_ENABLED then
		print("(debug/dprint.lua) | DEBUG PRINT: "..msg)
	end
end

function DPRINTTABLE(t, indent, done)
	if DEBUG_PRINT_ENABLED then
	  if not indent then print("(debug/dprint.lua) | PRINTING TABLE: ") end
	  
	  if type(t) ~= "table" then return end

	  done = done or {}
	  done[t] = true
	  indent = indent or 0

	  local l = {}
	  for k, v in pairs(t) do
		table.insert(l, k)
	  end

	  table.sort(l)
	  for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
		  local value = t[v]

		  if type(value) == "table" and not done[value] then
			done [value] = true
			print(string.rep ("\t", indent)..tostring(v)..":")
			DPRINTTABLE (value, indent + 2, done)
		  elseif type(value) == "userdata" and not done[value] then
			done [value] = true
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
			DPRINTTABLE ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		  else
			if t.FDesc and t.FDesc[v] then
			  print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
			else
			  print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
			end
		  end
		end
	  end
	  if not indent then print("(debug/dprint.lua) | TABLE PRINTED") end
	end
end

function GetTalentValue(unit, talentName, valueName)
	return unit:FindAbilityByName(talentName):GetSpecialValueFor(valueName)
end

function DPRINTSID(sid, msg)
	if PlayerResource:GetSteamAccountID(0) == sid then
		DPRINTCLIENT(msg)
	end
end

function DPRINTCLIENT(msg)
	CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(0), "dprint_client", {msg = msg} )
end