Clouds_Debug = {
	tMsgChannel = {
		"MSG_DEBUG",	--INFO
		"MSG_DEBUG",	--LUA_ERROR
		"MSG_SYS",		--MSG
		"MSG_SYS",		--ERROR
		"MSG_ANNOUNCE_YELLOW",	--ANNOUNCE
	},
	nDefaultChannel = 1,
}

RegisterCustomData("Clouds_Debug.nDefaultChannel")

--Clouds_API.CustomData("Clouds_Debug.tMsgChannel", "GLOBAL")

setmetatable(Clouds_Debug,{__call=function(t,head,tb)t.GenOutput(head,tb)end})

function Clouds_Debug.Msg(head, msg)
	Clouds_Debug.GetOutput(head,"MSG_SYS")(msg)
end

function Clouds_Debug.Debug(head, msg, level)
	Clouds_Debug.GetOutput(head,level)(msg)
end

function Clouds_Debug.GetOutput(head,level,font,tcolor)
	level = level or Clouds_Debug.nDefaultChannel
	channel = type(level)=="string" and level or Clouds_Debug.tMsgChannel[level] or "MSG_DEBUG"
	if channel == "MSG_DEBUG" and not font then
		font,tcolor=10,{255,255,0}
	end
	head=head and ("["..head.."] ") or ""
	return function(msg,rich)
		msg=tostring(msg):gsub("\n$","")
		OutputMessage(channel,head..msg.."\n",rich and true or false,font,tcolor)
	end
end

function Clouds_Debug.GenOutput(head,t)
	t=t or _G[head]
	if not t then
		_G[head]={}
		t=_G[head]
	end
	t.Debug=Clouds_Debug.GetOutput(head, 1)
	t.Msg=Clouds_Debug.GetOutput(head, 3)
end

Clouds_Debug.DDebug=Clouds_Debug.GetOutput("Clouds_Debug",Clouds_Debug.nDefaultChannel)
Clouds_Debug.DMsg=Clouds_Debug.GetOutput("Clouds_Debug","MSG_SYS")

Hotkey.AddBinding("Clouds_Reload", "重启界面","流云",function()
	Clouds_Debug.DMsg("Reloading@"..GetLogicFrameCount())
	ReloadUIAddon()
end,nil)
Hotkey.Set("Clouds_Reload",1,458944,true,true,true)

function Clouds_Debug.init()
	local bInited=false
	RegisterMsgMonitor(function()end,{"MSG_DEBUG"})
	RegisterMsgMonitor(function(msg)Log(msg)end,{"MSG_LOG"})
	for _,v in ipairs(Chat_GetMonitorMsg("系统")or{}) do
		if v=="MSG_DEBUG" then
			return
		end
	end
	Chat_AddMonitorMsg("系统","MSG_DEBUG")
	Clouds_Debug.DDebug=Clouds_Debug.GetOutput("Clouds_Debug",Clouds_Debug.nDefaultChannel)
	Clouds_Debug.DMsg=Clouds_Debug.GetOutput("Clouds_Debug","MSG_SYS")
end

local tErr={}
function Clouds_Debug.Error()
	local szErr=arg0
	local count=tErr[szErr] or 0
	tErr[szErr]=count+1
	if count<10 or (count<1000 and count%100==0) or count%1000==0 then
		Clouds_Debug.DDebug(szErr)
	end
end

function Clouds_Debug.GetFocusItemName() 
	local Item = Station.GetMouseOverWindow()
	local frame = Item:GetRoot()
	return Item:GetTreePath()
end


RegisterEvent("PLAYER_ENTER_GAME",Clouds_Debug.init)
RegisterEvent("CALL_LUA_ERROR", Clouds_Debug.Error)


