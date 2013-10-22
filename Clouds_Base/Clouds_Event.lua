Clouds_Event={
	tMonitor={},
	tDelay={},
	szINI="interface\\Clouds_Base\\Clouds_Event.ini",
}

function Clouds_Event.GenNewMonitor(event)
	if not Clouds_Event.tMonitor or Clouds_Event.tMonitor[event] then
		return
	end
	if event and event:find("^MESSAGE") then
		Clouds_Event.GenNewMsgMonitor(event)
	end
	Clouds_Event.tMonitor[event]={}
	RegisterEvent(event,function(...)
		for _,v in pairs(Clouds_Event.tMonitor[event]) do
			if v[2] then
				local b,s=pcall(v[1],...)
				v[3]=v[3]+1
				if not b then
					FireUIEvent("CALL_LUA_ERROR",s)
					v[4]=v[4]+1
					v[5]=s
				end
			end
		end
	end)
end

function Clouds_Event.Add(event,func,name)
	name=name or func
	if not Clouds_Event.tMonitor then
		return
	end
	if not Clouds_Event.tMonitor[event] then
		Clouds_Event.GenNewMonitor(event)
	end
	Clouds_Event.tMonitor[event][name]={func,true,0,0}
end

function Clouds_Event.Remove(event,name)
	name=name or "test"
	if not Clouds_Event.tMonitor or not Clouds_Event.tMonitor[event] then
		return
	end
	Clouds_Event.tMonitor[event][name]=nil
end

function Clouds_Event.RemoveAdd(name)
	name=name or "test"
	if not Clouds_Event.tMonitor then
		return 
	end
	for i,v in pairs(Clouds_Event.tMonitor) do
		Clouds_Event.Remove(i,name)
	end
end

function Clouds_Event.Last(event,lasttime,func,name)
	Clouds_Event.Add(event,func,name)
	Clouds_Event.Delay(lasttime,function()Clouds_Event.Remove(event,name or func)end,"Clouds_Delay_"..tostring(name or func)..GetLogicFrameCount())
end

function Clouds_Event.LastEvery(everytime,lasttime,func,name)
	local n,k=lasttime/everytime,0
	Clouds_Event.Every(everytime,function(...)
		k=k+1
		if n>k then
			local b,s=pcall(func,...)
			if not b then
				FireUIEvent("CALL_LUA_ERROR",s)
			end
		else
			Clouds_Event.Remove("CLOUDS_FRAME_BREATHE",name or func)
		end
	end,name)
end

function Clouds_Event.Every(everytime,func,name)
	local starttime=GetLogicFrameCount()
	Clouds_Event.Add("CLOUDS_FRAME_BREATHE",func and function(...)
		if (GetLogicFrameCount()-starttime)%everytime==0 then
			pcall(func,...)
		end
	end or nil,name or func)
end

function Clouds_Event.Delay(time,func,name)
	time=time or 0
	if time<0 then
		return
	end
	func=func or function()end
	name=name or GetLogicFrameCount()
	Clouds_Event.tDelay[name]={func,GetLogicFrameCount()+time}
end

function Clouds_Event.RemoveDelay(name)
	Clouds_Event.tDelay[name]=nil
end

function Clouds_Event.OnFrameBreathe()
	FireUIEvent("CLOUDS_FRAME_BREATHE")
	local now=GetLogicFrameCount()
	for i,v in pairs(Clouds_Event.tDelay) do
		if v[2]<=now then
			pcall(v[1])
			Clouds_Event.tDelay[i]=nil
		end
	end
end

function Clouds_Event.AddSelect(npc, string, pattern, name)
	Clouds_Event.Add("OPEN_WINDOW",function()
		if npc and arg3~=npc then
			local target=Clouds_API.GetPNDByID(arg3)
			if not target or target.szName~=npc then return end
		end
		if string and not arg1:find(string) then return end
		Clouds_API.WindowSelect(arg0, arg1, pattern)
	end,name or tostring(npc).."::"..tostring(string).."<<"..tostring(pattern))
end

function Clouds_Event.RemoveSelect(name)
	Clouds_Event.Remove("OPEN_WINDOW",name)
end

function Clouds_Event.GenNewMsgMonitor(event)
	channel=event:gsub("MESSAGE","MSG",1)
	if not Clouds_Event.tMonitor or Clouds_Event.tMonitor[event] then
		return 
	end
	Clouds_Event.tMonitor[event]={}
	RegisterMsgMonitor(function(message,font,rich,r,g,b)
		FireUIEvent(event,message,rich,font,{r,g,b})
	end,{channel})
end

RegisterEvent("LOADING_END",function()
	Clouds_Event.ui=Station.Lookup("Lowest/Clouds_Event") or Wnd.OpenWindow(Clouds_Event.szINI, "Clouds_Event")
	Clouds_Event.tDelay={}
end)

Clouds_Event.AddEvent=Clouds_Event.Add
Clouds_Event.RemoveEvent=Clouds_Event.Remove

Clouds_Event.Output=Clouds_Debug.GetOutput("Clouds_Event","MSG_SYS")

Clouds_Event.UI={}

function Clouds_Event.UI.GetMenu(name)
	local menu={}
	name="tDelay"
	local submenu={szOption=name}
	for i,v in pairs(Clouds_Event.tDelay) do
		table.insert(submenu,{
			szOption=i,
			{szOption=tostring((v[2]-now)/16)},
			{szOption=tostring(v[1])},
		})
	end
	table.insert(menu,submenu)
	for name,t in pairs(Clouds_Event.tMonitor) do
		submenu={szOption=name}
		for i,v in pairs(t or {}) do
			table.insert(submenu,{
				szOption=string.format("[%d]%s",v[4],tostring(i)),
				bCheck=true,
				bChecked=v[2],
				fnAction=function()
					v[2]=not v[2]
				end,
				{szOption=tostring(v[1])},
				{szOption=v[4].."/"..v[3]},
				v[5] and {szOption=v[5]:sub(1,50),bCheck=true,fnAction=function()Clouds_Event.Output(v[5]) v[5]=nil end},
			})
		end
		table.insert(menu,submenu)
	end
	return menu
end

