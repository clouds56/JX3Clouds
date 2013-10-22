PlaySound(SOUND.UI_SOUND, "interface\\Clouds_Base\\Clouds.mp3")
--Clouds_Engine.OutputError(5)
--Clouds_Engine.OutputMessage("Playing...\n")

if not Clouds_Addon then
	Clouds_Addon={}
end

Clouds_Event.Add("PLAYER_ENTER_GAME",function()
	local frame = Station.Lookup("Lowest/Clouds_Addon")
	if frame then Wnd.CloseWindow(frame) end
	Wnd.OpenWindow("interface\\Clouds_Base\\Clouds_Addon.ini", "Clouds_Addon")
end,"Clouds_ADDON")

--[[
Clouds_Event.Add("PLAYER_ENTER_SCENE",function()
	if arg0==883296 or arg0==1129615 then
		Clouds_Addon.lastSeentime=Clouds_Addon.lastSeentime or 0
		if Clouds_Addon.lastSeentime and GetCurrentTime()-Clouds_Addon.lastSeentime<1800 then
			return
		end
		Clouds_Addon.lastSeentime=GetCurrentTime()
		PlaySound(SOUND.UI_SOUND, "interface\\Clouds_Base\\Clouds.mp3")
	end
end,"Clouds_ERHUO")
]]

findxiaobaishe=true
Clouds_Event.Add("NPC_ENTER_SCENE",function()
	if not findxiaobaishe then
		return
	end
	local npc=GetNpc(arg0)
	if npc.szName=="齐纤女" or npc.szName=="许先" or npc.szName=="潘君怜" then
		local me=GetClientPlayer()
		OutputMessage("MSG_ANNOUNCE_YELLOW","找到"..npc.szName.."\n")
		--me.Talk(1,me.szName,{{type="text",text="找到"},{type="name",text="["..npc.szName.."]",name=npc.szName}})
	end
end,"Clouds_SHU")

Clouds_Event.Add("ON_USE_CHAT",function()
	if arg0==PLAYER_TALK_CHANNEL.WORLD then
		Clouds_API.StartNewSkillTimer("世界喊话",101,9,60*16)
	elseif arg0==PLAYER_TALK_CHANNEL.CAMP then
		Clouds_API.StartNewSkillTimer("阵营喊话",101,9,15*16)
	end
end,"Clouds_HANHUA")

--Clouds_Engine.OutputMessage("Clouds_Addon\n")
--[[function Clouds_Addon.OnFrameCreate()
	Clouds_Addon.handle=this:Lookup("","")
	Clouds_Addon.shape=Clouds_Shapes.new(Clouds_Addon.handle)
	Clouds_Engine.OutputMessage("Clouds_Addon.OnFrameCreate\n")
	this:RegisterEvent("DOODAD_ENTER_SCENE")
end

function Clouds_Addon.OnEvent(event)
	if event=="DOODAD_ENTER_SCENE" then
		local doodad,name=GetDoodad(arg0),""
		if doodad then
			name=doodad.szName
		end
		--Clouds_Engine.OutputMessage("Clouds_Addon->Doodad:"..name.."("..arg0..")@"..string.format("<%.2f,%.2f,%.2f>",doodad and doodad.nX or -1,doodad and doodad.nY or -1,doodad and doodad.nZ or -1).."\n")
	end
end]]

function Clouds_Addon.SaveMail()
local aMail = GetMailClient().GetMailList("all") or {}
local _,dwtar=GetClientPlayer().GetTarget()
local time=TimeToDate(GetCurrentTime())
local mailfn="interface\\Clouds_Base\\mail\\"..GetClientPlayer().szName.."\\"..string.format("%02d%02d%02d",time.year,time.month,time.day)..".log"
local t=LoadLUAData(mailfn) or {}
for i, dwID in ipairs(aMail) do
	local mailinfo=GetMailClient().GetMailInfo(dwID)
	mailinfo.RequestContent(dwtar)
	szTitle=(mailinfo.bMoneyFlag and "M:"..string.format("%d.%02d.%02d",mailinfo.nMoney/10000,mailinfo.nMoney/100%100,mailinfo.nMoney%100) or "")
	if mailinfo.bItemFlag then
		if szTitle~="" then
			szTitle=szTitle..","
		end
		szTitle=szTitle.."I:"
		for i=0,7 do
			local item=mailinfo.GetItem(i)
			if item then
				szTitle=szTitle.."["..item.szName..(item.nStackNum~=1 and ":"..item.nStackNum or "").."]"
			end
		end
	end
	if szTitle~="" then
		szTitle="("..szTitle..")"
	end
	szTitle=mailinfo.szTitle..szTitle
	--OutputMessage("MSG_CLOUDS","Left:"..Clouds_API.EncodingDateTime(GetCurrentTime()-mailinfo.GetLeftTime()).."\n")
	local msg={channel="<MSG_MAIL>",name=mailinfo.szSenderName,time=Clouds_API.EncodingDateTime(GetCurrentTime()+mailinfo.GetLeftTime()-30*24*3600),title=mailinfo.szTitle}
	msg.money=(mailinfo.bMoneyFlag and string.format("%d.%02d.%02d",mailinfo.nMoney/10000,mailinfo.nMoney/100%100,mailinfo.nMoney%100)) or nil
	local szItem=""
	if mailinfo.bItemFlag then
		for i=0,7 do
			local item=mailinfo.GetItem(i)
			if item then
				szItem=szItem.."["..item.szName..(item.nStackNum~=1 and ":"..item.nStackNum or "").."]"
			end
		end
	end
	msg.item=szItem~="" and szItem or nil
	msg.msg=string.gsub(mailinfo.GetText(),"\n","\\n").."\\n"
	if msg.msg=="\\n" then
		msg.msg=nil
	end
	local add=true
	for _,v in ipairs(t) do
		if v.name==msg.name and v.time==msg.time and v.title==msg.title and v.msg==msg.msg then
			add=false
		end
	end
	if add then
		table.insert(t,msg)
	end
end
table.sort(t,function(a,b) return a.time<b.time end)
SaveLUAData(mailfn,t)
end

--[[local bguihuaon=false
local function guihua()
	local time=6*60*60-GetLogicFrameCount()/16%(6*60*60)
	--Output(time)
	if bguihuaon then return end
	bguihuaon=true
	Clouds_Event.Delay(time*16,function()bguihuaon=false;guihua()end,"guihua"..GetLogicFrameCount())
	if time>5*60 then
		Clouds_Event.Delay((time-5*60)*16,function()Clouds_API.StartNewSkillTimer("桂花最后5min",137,8,5*60*16)end,"guihua5min")
	else
		Clouds_API.StartNewSkillTimer("桂花最后"..time.."s",137,8,time*16)
	end
	Clouds_API.StartNewSkillTimer("桂花",137,8,time*16)
end

Clouds_Event.Add("LOADING_END",guihua,"guihuaing")]]
