Clouds_Debug_UI = {
	szIni = "interface\\Clouds_UI\\Clouds_Debug_UI.ini",
}

if not Clouds_Debug then
	return
end

Clouds_Debug.ui=Clouds_Debug_UI

Clouds_Debug_UI.UpdateFrame = function()
	Clouds_Debug.hookall()
	local frame = Station.Lookup("Topmost/Clouds_Debug_UI")
	if not frame then
		frame = Wnd.OpenWindow(Clouds_Debug_UI.szIni, "Clouds_Debug_UI")
	end
	frame:Hide()
	return frame
end

Clouds_Debug_UI.OnFrameCreate = function()
	local handle = this:Lookup("","Handle_List")
	Clouds_UI.newPool(handle, Clouds_Debug_UI.szIni, "Handle_Instance")
end

Clouds_Debug_UI.OnFrameBreathe = function()
	if GetLogicFrameCount() % 8~=0 then
		return
	end

	local handle,i = this:Lookup("","Handle_List"),1
	for i=1,handle.nIndex-1 do
		local item = handle:Lookup(i)
		if item then
			item:Hide()
		end
	end
	for _, v in pairs(Clouds_Debug.cpuusage) do
		while i>=handle.nIndex do
			handle.new()
		end
		local item,name = handle:Lookup(i),v.name:match("Clouds_(.*)") or v.name
		if item then
			item:Lookup("Text_Name"):SetText(i..":"..name)
			item:Lookup("Text_Count"):SetText(tostring(v.ncall))
			item:Show()
		end
		i=i+1
	end
	handle:FormatAllItemPos()
end

