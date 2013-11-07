function getfilename(key)
	if type(key)=="string" and key~="all" and key~="tmp" and key~="projects"
		and not tonumber(key) then
		return key
	else
		local workspace = loadf("workspace")
		if not workspace then
			local lastopen = loadf("LastOpen")
			if lastopen then
				return lastopen:match("^(.-)\t.*$") or lastopen
			end
		end
		local t={}
		if key=="all" or key=="projects" and workspace then
			for i,v in ipairs(workspace.projects or {}) do
				table.insert(t,v.."\\"..v)
			end
		end
		if key=="all" or key=="tmp" then
			for i,v in ipairs(workspace.tmp or {}) do
				table.insert(t,"tmp\\"..v)
			end
			return t
		end
		if key=="projects" then
			return t
		end
		if key then
			local ki=tonumber(key)
			if ki and workspace and workspace.projects then
				local fn=workspace.projects[ki]
				return fn and fn.."\\"..fn or fn
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
