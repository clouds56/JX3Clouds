Clouds_UI = {}

function Clouds_UI.newPool(handle, ini, section, from)
	from = from or 0
	local item=handle:Lookup(from)
	if not item then
		item=handle:AppendItemFromIni(ini,section)
	end
	item.nIndex=from
	item:Hide()
	handle.nIndex = handle.nIndex or from + 1
	--handle.nUsed = handle.nUsed or 0
	function handle.new()
		local item = handle:AppendItemFromIni(ini, section, section..handle.nIndex)
		if item then
			item.nIndex= handle.nIndex
			handle.nIndex = handle.nIndex + 1
			handle:FormatAllItemPos()
			item:Hide()
		end
		return item
	end
	--[[function handle.add(name, time, text)
		local item = handle.nUsed<handle.nIndex and handle:Lookup(handle.nUsed) or handle.new()
		if item then
			handle.nUsed= handle.nUsed+1
			item:SetName(name)
			item.szName=name
			item:Show()
		end
		return item
	end]]
	--[[function handle.remove(name)
		name = name or handle.nUsed - 1
		OutputMessage("MSG_SYS",""..name)
		local item = handle.find(name)
		if item then
			for i=item.nIndex,handle.nUsed - 2 do
				handle.copy(i+1,i)
			end
		end
		item = handle.find(handle.nUsed - 1)
		if item then
			item:SetName(section..(item.nIndex==0 and "" or item.nIndex))
			item.szName = nil
			handle.nUsed = handle.nUsed - 1
			item:Hide()
		end
		return handle.nUsed
	end]]
	--[[function handle.find(name)
		local item = handle:Lookup(name)
		if item then
			return item
		end
		for i=0,handle.nIndex-1 do
			item = handle:Lookup(i)
			if item.szName == name then
				return item
			end
		end
		return nil
	end]]
	--[[function handle.copy(name1,name2)
		local item1,item2 = handle.find(name1),handle.find(name2)
		if not item1 or not item2 then return end
		for i,v in pairs(item2) do
			if i~="___id" and i~=nIndex then
				item2[i]=nil
			end
		end
		for i,v in pairs(item1) do
			if i~="___id" and i~=nIndex then
				item2[i]=v
			end
		end
	end]]
	return handle
end

Clouds_UI.AppendPoint = function(self,t,...)
	if t==TARGET.CHARACTER or t==TARGET.NPC or t==TARGET.PLAYER then
		self:AppendCharacterID(...)
	elseif t==TARGET.DOODAD then
		self:AppendDoodadID(...)
	end
end
