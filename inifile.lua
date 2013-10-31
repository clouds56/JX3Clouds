inifile = {}

function inifile.parse(str)
	local t,i = {},{}
	local section
	for line in (str.."\n"):gmatch("(.-)\n") do
		local s = line:match("^%[([^%]]+)%]$")
		if s then
			section = s
			t[section] = t[section] or {}
			i[section] = {}
			table.insert(i,section)
		end
		if line:match("^;") or line:match("^#") then
			line = ""
		end
		local key, value = line:match("^([._$%w]+)%s-=%s-(.+)$")
		if key and value then
			if tonumber(value) then value = tonumber(value) end
			if value == "true" then value = true end
			if value == "false" then value = false end
			t[section][key] = value
			table.insert(i[section],key)
		end
	end
	return t, i
end

function inifile.save(t, i)
	local contents = ""
	if i then
		for _,section in ipairs(i) do
			contents = contents .. ("[%s]\n"):format(section)
			for _, key in ipairs(i[section]) do
				contents = contents .. ("%s=%s\n"):format(key, tostring(t[section][key]))
			end
			contents = contents .. "\n"
		end
	else
		for section, s in pairs(t) do
			contents = contents .. ("[%s]\n"):format(section)
			for key, value in pairs(s) do
				contents = contents .. ("%s=%s\n"):format(key, tostring(value))
			end
			contents = contents .. "\n"
		end
	end
	return contents
end

return inifile
