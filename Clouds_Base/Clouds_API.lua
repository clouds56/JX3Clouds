Clouds_API={}

MAP_TYPE={
	NORMAL_MAP = 0,
	DUNGEON = 1,
	BATTLE_FIELD = 2,
	BIRTH_MAP = 3,
	TONG_DUNGEON = 4,
	CITY = 5,
	PLAYER = 1000,
}

TARGET={
	NO_TARGET = 0,
	COORDINATION = 1,
	NPC = 2,
	DOODAD = 3,
	PLAYER = 4,
	ITEM = 5,
	ITEM_POS = 6,
	CHARACTER = 7
}

function Clouds_API.GetPNDByID(dwID)
	dwID=dwID or 0
	return GetPlayer(dwID) or GetNpc(dwID) or GetDoodad(dwID) or nil
end

function Clouds_API.GetDistance2(src,dst)
	return math.floor(((src.nX-dst.nX)^2+(src.nY-dst.nY)^2+(src.nZ/8-dst.nZ/8)^2)^0.5)/64
end

function Clouds_API.Get2dDistance(src,dst)
	return math.floor(((src.nX-dst.nX)^2+(src.nY-dst.nY)^2)^0.5)/64
end

--[[
function Clouds_API.GenOutputMessage(szChannel,nFont,tColor,DebugMode)
	local DebugHead=string.match(DebugMode,"<head>(.*)</head>") or "<Clouds_API>"
	return function(text,rich,font,color)
		if szChannel then 
			OutputMessage(szChannel,text,rich,font or nFont,color or tColor)
		end
		if DebugMode and DebugMode:find("DEBUG") then
			Log(DebugHead..(text:sub(-1)=="\n" and text:sub(1,-2) or text))
		end
	end
end

function Clouds_API.CloudsDebug_Init()
	local bInited=false
	RegisterMsgMonitor(function()end,{"CLOUDS_DEBUG"})
	for _,v in ipairs(Chat_GetMonitorMsg("流云")) do
		if v=="CLOUDS_DEBUG" then
			bInited=true
		end
	end
	if not bInited then Chat_AddMonitorMsg("流云","CLOUDS_DEBUG")end
	return Clouds_API.GenOutputMessage("CLOUDS_DEBUG",10,{255,255,255},"DEBUG")
end
--Clouds_API.OutputMessage=Clouds_API.CloudsDebug_Init()

function Clouds_API.Msg(szText)
	OutputMessage("MSG_SYS","<Clouds>"..szText.."\n")
end
]]

function Clouds_API.EncodingTimeStringByFrame(framecount)
	framecount=framecount or GetLogicFrameCount()
	local hh,mm,ss,ff=framecount/16/60/60,(framecount/16/60)%60,(framecount/16)%60,framecount%16
	return string.format("[%02d:%02d:%02d.%02d]",hh,mm,ss,ff)
end

function Clouds_API.EncodingTime(time)
	time=time or GetCurrentTime()
	if type(time)=="number" then
		time=TimeToDate(time)
	end
	if type(time)~="table" then
		return "[::]"
	else
		return string.format("[%02d:%02d:%02d]",time.hour or time.hh,time.minute or time.mm,time.second or time.ss)
	end
end

function Clouds_API.EncodingData(time)
	time=time or GetCurrentTime()
	if type(time)=="number" then
		time=TimeToDate(time)
	end
	if type(time)~="table" then
		return "[--]"
	else
		return string.format("[%02d-%02d-%02d]",time.year or time.Y,time.month or time.M,time.day or time.D)
	end
end

function Clouds_API.EncodingDateTime(time)
	time=time or GetCurrentTime()
	if type(time)=="number" then
		time=TimeToDate(time)
	end
	if type(time)~="table" then
		return "[-- ::]"
	else
		return string.format("[%02d-%02d-%02d %02d:%02d:%02d]",time.year or time.Y,time.month or time.M,time.day or time.D,time.hour or time.hh,time.minute or time.mm,time.second or time.ss)
	end
end

function Clouds_API.EncodingNameString(player)
	if not player then
		return ""
	end
	if type(player)=="number" then
		player=Clouds_API.GetPNDByID(player) or player
		if type(player)=="number" and Table_GetNpcTemplateName(player) then
			return Table_GetNpcTemplateName(player).."("..player..")"
		end
	end
	if type(player)~="table" and type(player)~="userdata" then
		return "未获取#"..tostring(player)
	end
	if not (player.dwTemplateID or player.dwID) and player.szName then
		return player.szName
	end
	if not player.szName or player.szName=="" and (player.dwTemplateID or player.dwID) then
		return "无名#"..(player.dwTemplateID or player.dwID)
	end
	if player.szName and (player.dwTemplateID or player.dwID) then
		return player.szName.."("..(player.dwTemplateID or player.dwID)..")"
	end
	return ""
end

function Clouds_API.GetItemPathName(item)
	if item==item:GetRoot() then
		return item:GetTreePath():sub(1,-2)
	end
	return item:GetTreePath()..item:GetName()
end

function Clouds_API.OutputName(channel, name)
  OutputMessage(channel, string.format('<text>text="[%s]\n" name="namelink" eventid=515</text>',name),true)
end

function Clouds_API.ChangeADTong(name)
	local frame=Station.Lookup("Normal/GuildListPanel")
	if not frame then
		OutputMessage("MSG_SYS","请先打开帮会推荐\n")
	end
	local item=frame:Lookup("PageSet_List/Page_AdList"):Lookup("", "Handle_AdList"):Lookup(0)
	if not item then
		return
	end
	item:Lookup("Text_GuildName"):SetText(name)
	item.szName=name
	OutputMessage("MSG_SYS","设置帮会["..name.."]成功\n")
end

function Clouds_API.EncodingSkillString(id,level)
	if not id or not level then
		return "("..(id or "")..","..(level or "")..")"
	end
	local name=Table_GetSkillName(id,level)
	if not name then
		return "("..id..","..level..")"
	end
	return name.."("..id..","..level..")"
end

function Clouds_API.EncodingMapName(id)
	if not id then
		return ""
	elseif id == -1 then
		return "基三(-1)"
	else
		return ("%s(%d)"):format(Table_GetMapName(id),id)
	end
end

function Clouds_API.GetMapType(id)
	if not id then
		return
	elseif id == -1 then
		return MAP_TYPE.PLAYER
	else
		local _,tp = GetMapParams(id)
		return tp
	end
end

function Clouds_API.GetSkillName(id,level)
	level=level or 1
	return Table_GetSkillName(id,level) or "无名"..(id and "#"..tostring(id) or "!*")
end

function Clouds_API.MsgSure(szString,fnSure,fnCancel,fnbClose,szTitle,szSure,szCancel,bRichText)
	local msg = {
		szMessage = szString or "(!!)No Information",
		bRichText = bRichText and true or false,
		szName = szTitle or "Clouds_".. GetTickCount(),
		fnAutoClose = type(fnbClose)=="function" and fnbClose or function()return fnbClose end,
		{szOption = szSure or "确认",fnAction=fnSure},
		{szOption = szCancel or "取消",fnAction=fnCancel}
	}
	MessageBox(msg,true)
end

function Clouds_API.MsgRich(szString,tOptions,fnbClose,szTitle,bRichText)
	local msg = {
		szMessage = szString or "(!!)No Information",
		bRichText = bRichText and true or false,
		szName = szTitle or "Clouds_".. GetTickCount(),
		fnAutoClose = type(fnbClose)=="function" and fnbClose or function()return fnbClose end,
	}
	for _,v in pairs(tOptions) do
		table.insert(msg,{szOption = v[1],fnAction=v[2]})
	end
	MessageBox(msg,true)
end

function Clouds_API.CheckQuest(szQuestName,szNpcName)
	local frame = Station.Lookup("Normal/DialoguePanel")
	if frame and frame:IsVisible() then
		if szNpcName then
			local npc=Clouds_API.GetPNDByID(frame.dwTargetId)
			if not npc or npc.szName~=szNpcName then
				return false
			end
		end
		local handle = frame:Lookup("", "Handle_Message")
--Output(1)
		local nCount = handle:GetItemCount()
		for i = 0, nCount-1 do
			local hI = handle:Lookup(i)
			if hI.bQuest then
--Output(hI,hI:Lookup("text"):GetText():match("^%s*(.-)%s*$"),szQuestName)
				if not szQuestName or hI.dwQuestId == szQuestName or hI:Lookup("text"):GetText():match("^%s*(.-)%s*$")==szQuestName then
					local x, y = hI:GetAbsPos()
					Cursor.SetPos(x+50,y+13)
					Clouds_Event.LastEvery(1,16*5,function()
						Clouds_API.QuestSure(szNpcName)
					end)
					break
				end
			end
		end
	end
end

function Clouds_API.MessageBoxSure(szWindow, i)
	local frame = Station.Lookup("Topmost2/MB_" .. szWindow) or Station.Lookup("Topmost/MB_" .. szWindow)
	if frame then
		i = i or 1
		local btn = frame:Lookup("Wnd_All/Btn_Option" .. i)
		if btn and btn:IsEnabled() then
			if btn.fnAction then
				btn.fnAction(i)
			elseif frame.fnAction then
				frame.fnAction(i)
			end
			CloseMessageBox(szName)
		end
	end
end

function Clouds_API.GetUserInputNumber(szMsg, fnSure, szDefault, fnCancel, nCount)
	local t={}
	GetUserInput(szMsg,function(str)
		local i=1
		for v in (str..","):gmatch("(%S-)%s*,") do
			t[i]=tonumber(v)
			i=i+1
		end
		fnSure(unpack(t))
	end,fnCancel,nil,nil,szDefault,nil,nil,nil)
end

function Clouds_API.GetUserInputText(szMsg, fnSure, szDefault, fnCancel, nCount)
	local t={}
	GetUserInput(szMsg,function(str)
		local i=1
		for v in (str..","):gmatch("(%S-)%s*,") do
			t[i]=v
			i=i+1
		end
		fnSure(unpack(t))
	end,fnCancel,nil,nil,szDefault,nil,nil,nil)
end

function Clouds_API.QuestSure(szNpcName)
	local frame = Station.Lookup("Normal/QuestAcceptPanel")
	if frame and frame:IsVisible() then
		if szNpcName then
			local npc=Clouds_API.GetPNDByID(frame.dwTargetId)
			if not npc or npc.szName~=szNpcName then
				return false
			end
		end
		local Btn = frame:Lookup("Btn_Sure")
		if Btn and Btn:IsEnabled() then
			Btn:SetCursorAbove()
		end
	end	
end

function Clouds_API.SearchTeam(szName)
	local team,me = GetClientTeam(),GetClientPlayer()
	if not team or not me or not team.IsPlayerInTeam(me.dwID) then return end
	for k = 0, team.nGroupNum - 1 do
		for i,id in ipairs(team.GetGroupInfo(k).MemberList) do
			local player=team.GetMemberInfo(id)
			if player and (player.szName==szName or player.szName:find(szName)) then
				return id
			end
		end
	end
	return 0
end

function Clouds_API.WindowSelect(nIndex, szString, szPattern)
	local n,me=0,GetClientPlayer()
	if not me then return end
	if type(szPattern)=="number" then
		return me.WindowSelect(nIndex, szPattern)
	end
	if not szString:find(szPattern) then
		return
	end
	for v in szString:gmatch("<%$C (.-)>") do
		if v:find(szPattern) then
			return me.WindowSelect(nIndex, n)
		end
		n=n+1
	end
end

function Clouds_API.UseBagItem(szName,bWarn)
	local me = GetClientPlayer()
	for i = 1, 5 do
		for j = 0, me.GetBoxSize(i) - 1 do
		local it = GetPlayerItem(me, i, j)
			if it and it.szName == szName then
				OnUseItem(i, j)
				return true
			end
		end
	end
	if bWarn then
		OutputMessage("MSG_SYS","[Clouds_API] 未找到"..tostring(szName).."\n")
	end
end

