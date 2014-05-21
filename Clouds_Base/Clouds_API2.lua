Clouds_API = Clouds_API or {}

local map = {
	szFormat = "%s(%d)",
	szDefault = "ÆäËû",
	GetName = function(dwID)
		local szName = Table_GetMapName(dwID)
		if not szName or szName == "" then
			return map.szDefault
		end
		return szName
	end,
	GetUniqueName = function(dwID)
		local szName = Table_GetMapName(dwID)
		if not szName or szName == "" then
			return ("%s¡¤%d"):format(map.szDefault,id)
		end
		return szName
	end,
	EncodeName = function(dwID,szFormat)
		szFormat = szFormat or map.szFormat
		return szFormat:format(map.GetName(dwID))
	end,
	GetNameLink = function(dwID)
		--TODO: font=nFont (r,g,b,a)
		return '<text> text='..
			EncodeComponentsString(('"%s"'):format(map.GetUniqueName(dwID)))..
			' name="maplink" eventid=513 script='..
			EncodeComponentsString(("this.dwID=%d"):format(dwID))..
			'</text>'
	end,
	GetType = function(dwID)
		local r,tp = GetMapParams(dwID)
		if r then return tp end
		return -1
	end,
}
Clouds_API.Map = map


local npc = {
	szFormat = "%s(%d)",
	szDefault = "Î´Öª",
	GetName = function(dwID)
		local szName = Table_GetNpcTemplateName(dwID)
		if not szName or szName == "" then
			return npc.szDefault
		end
		return szName
	end,
	GetUniqueName = function(dwID)
		local szName = Table_GetNpcTemplateName(dwID)
		if not szName or szName == "" then
			return ("%s¡¤%d"):format(npc.szDefault,id)
		end
		return szName
	end,
	EncodeName = function(dwID,szFormat)
		szFormat = szFormat or npc.szFormat
		return szFormat:format(npc.GetName(dwID))
	end,
	GetNameLink = function(dwID)
		--TODO: font=nFont (r,g,b,a)
		return '<text> text='..
			EncodeComponentsString(('"%s"'):format(npc.GetUniqueName(dwID)))..
			' name="npclink" eventid=513 script='..
			EncodeComponentsString(("this.dwID=%d"):format(dwID))..
			'</text>'
	end,
	GetType = function(dwID)
		local npc = GetNpcTemplate(dwID)
		if npc then return npc.nIntensity end
		return -1
	end,
}
Clouds_API.Npc = npc

local achievement = {
	MakeLink = function(dwAchievementID)
		local szFont = " font=10 "
		local me = GetClientPlayer()
		if me then
			if me.IsAchievementAcquired(dwAchievementID) then
				szFont = szFont .. " r=0 g=255 b=0 "
			else
				szFont = szFont .. " r=255 g=0 b=0 "
			end
		end
		local szName = g_tTable.Achievement:Search(dwAchievementID).szName
		return Clouds_API.Achievement.MakeRawLink("["..szName.."]", szFont, dwAchievementID)
	end,
	MakeRawLink = function(szName, szFont, dwAchievementID)
		local szLink = "<text>text="..EncodeComponentsString(szName)..
			szFont.."name=\"achievementlink\" eventid=513 script="..
			EncodeComponentsString("this.dwID="..dwAchievementID).."</text>"
		return szLink
	end,
	Search = function(szName)
		local tAll,tFinish,tNot={},{},{}
		local nCount=g_tTable.Achievement:GetRowCount()
		local me=GetClientPlayer()
		for i=2,nCount do
			local aInfo=g_tTable.Achievement:GetRow(i)
			local str=aInfo.szName..aInfo.szShortDesc..aInfo.szDesc
			if str:find(szName) then
				local id=aInfo.dwID
				table.insert(tAll,id)
				if me.IsAchievementAcquired(id) then
					table.insert(tFinish,id)
				else
					table.insert(tNot,id)
				end
			end
		end
		return tAll,tFinish,tNot
	end,
}
Clouds_API.Achievement = achievement
