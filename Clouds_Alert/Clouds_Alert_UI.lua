Clouds_Alert_UI = {
	szIni = "interface\\Clouds_Alert\\Clouds_Alert_UI.ini",
	tMapTypeColor = {
		[MAP_TYPE.NORMAL_MAP] = 3,
		[MAP_TYPE.DUNGEON] = 1,
		[MAP_TYPE.BATTLE_FIELD] = 4,
		[MAP_TYPE.BIRTH_MAP] = 3,
		[MAP_TYPE.TONG_DUNGEON] = 3,
		[MAP_TYPE.CITY] = 3,
		[MAP_TYPE.PLAYER] = 2,
	},
	tSelect = {
		map = nil,
		boss = {},
		skill = {},
	},
}

Clouds_Alert.UI=Clouds_Alert_UI

Clouds_Alert_UI.create = function()
	local frame = Station.Lookup("Topmost/Clouds_Alert_UI")
	if not frame then
		frame = Wnd.OpenWindow(Clouds_Alert_UI.szIni,"Clouds_Alert_UI")
		local map=frame:Lookup("Wnd_Map",""):Lookup("Handle_MapList")
		local boss=frame:Lookup("Wnd_Boss",""):Lookup("Handle_BossList")
		local skill=frame:Lookup("Wnd_Skill",""):Lookup("Handle_SkillList")
		Clouds_UI.newPool(map,Clouds_Alert_UI,"Handle_MapInstance",1)
		Clouds_UI.newPool(boss,Clouds_Alert_UI,"Handle_BossInstance",1)
		Clouds_UI.newPool(skill,Clouds_Alert_UI,"Handle_SkillInstance",1)
	end
end

Clouds_Alert_UI.update = function(tag)
	local frame = Station.Lookup("Topmost/Clouds_Alert_UI")
	local tselect = Clouds_Alert_UI.tSelect
	if tag=="map" then
		local map=frame:Lookup("Wnd_Map",""):Lookup("Handle_MapList")
		local mapselect = map:Lookup("Image_MapSelect")
		for i=1,map.nIndex-1 do
			map:Lookup(ii):Hide()
		end
		for i=1,#Clouds_Alert.tMap do
			local ii = math.floor((i-1)/2)
			local item = map:Lookup(ii)
			local image,text = item:Lookup("Image_Map_"..((i-1)%2)),item:Lookup("Text_Map_"..((i-1)%2))
			text:SetText(Clouds_API.EncodingMapName(map.id))
			image:SetFrame(Clouds_Alert_UI.tMapTypeColor[Clouds_API.GetMapType(map.id)])--2:白 4:红 1:黄 3:绿
			item:Show()
			text:Show()
			image:Show()
		end
		if #Clouds_Alert.tMap%2~=0 then
			local item = map:Lookup(math.floor(i/2))
			item:Lookup("Image_Map_1"):Hide()
			item:Lookup("Text_Map_1"):Hide()
		end
		if tselect.map then
			local sel=Clouds_Alert_UI:Lookup("map",tselect.map)
			if sel then
				mapselect:SetRelPos(sel:GetRelPos())
				mapselect:Show()
			else
				mapselect:Hide()
			end
		end
	elseif tag=="boss" then
		local boss=frame:Lookup("Wnd_Boss",""):Lookup("Handle_BossList")
		local bossselect = boss:Lookup("Image_BossSelect")
		for i=1,#Clouds_Alert.tMap do
			local item = map:Lookup(i)
			local image,text = item:Lookup("Image_Boss"),item:Lookup("Text_Boss")
			text:SetText(Clouds_API.EncodingMapName(map.id))
			image:SetFrame(Clouds_Alert_UI.tMapTypeColor[Clouds_API.GetMapType(map.id)])--2:白 4:红 1:黄 3:绿
		end
		if tselect.map then
			local sel=Clouds_Alert_UI:Lookup("map",tselect.map)
			if sel then
				mapselect:SetRelPos(sel:GetRelPos())
				mapselect:Show()
			else
				mapselect:Hide()
			end
		end
	end
end
