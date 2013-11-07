function getfilename(key)
	if type(key)=="string" and key~="all" and not tonumber(key) then
		return key
	else
		local workspace = loadf("workspace")
		if not workspace then
			local lastopen = loadf("LastOpen")
			if lastopen then
				return lastopen:match("^(.-)\t.*$") or lastopen
			end
		end
		if key=="all" and workspace and workspace.projects then
			return workspace.projects
		elseif key then
			local ki=tonumber(key)
			if ki and workspace and workspace.projects then
				return workspace.projects[ki]
			end
		end
		return workspace.lastopen
	end
end

function loadf(filename)
	local fin=io.open(filename,"rb")
	if not fin then
		return nil
	end
	local str=fin:read("*a")
	fin:close()
	-- local data = ...
	if not str then
		return nil
	end
	return loadstring("local "..str:sub(str:sub(1,30):find("data"),-1).." return data")()
end

return loadf
