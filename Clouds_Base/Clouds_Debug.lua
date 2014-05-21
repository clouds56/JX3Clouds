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

function Clouds_Debug.Check(frame,pos)
	local xx,yy = frame:GetAbsPos()
	local w,h = frame:GetSize()
	local x,y = unpack(pos)
	if x>=xx and x<xx+w and y>=yy and y<yy+h then
		return true
	end
	return false
end

function Clouds_Debug.CanGetIndex(item)
	if item:GetType():sub(1,3)=="Wnd" then
		return false
	elseif item:GetType()=="Handle" and item:GetParent():GetType():sub(1,3)=="Wnd" then
		return false
	end
	return type(item.GetIndex)=="function"
end

function Clouds_Debug.Lookup(frame,pos,t)
	t = t or {}
	if Clouds_Debug.Check(frame,pos) then
		table.insert(t,frame)
	end
	if frame:GetType():sub(1,3) == "Wnd" then
		local item = frame:Lookup("","")
		if item then
			Clouds_Debug.Lookup(item,pos,t)
		end
		item = frame:GetFirstChild()
		while item do
			Clouds_Debug.Lookup(item,pos,t)
			item = item:GetNext()
		end
	elseif frame:GetType() == "Handle" then
		for i=0,frame:GetItemCount()-1 do
			local item = frame:Lookup(i)
			if item then
				Clouds_Debug.Lookup(item,pos,t)
			end
		end
	end
	return t
end

function Clouds_Debug.GetFocusItemName() 
	local Item = Station.GetMouseOverWindow()
	local frame = Item:GetRoot()
	local x,y = Cursor.GetPos()
	local t=Clouds_Debug.Lookup(frame,{x,y})
	return Item:GetTreePath(),algo.table.map(algo.table.copy(t),function(item) return item:GetTreePath()..item:GetName()end),t
end

function Clouds_Debug.ItemMenu(list)
	local function genOptionNumber(v, szHead,szFormat,szFn1,szFn2,bDisable)
		return {
			szOption = szHead..":\t"..
				(szFn2 and szFormat:format(v["Get"..szFn1](v),v["Get"..szFn2](v))
					or szFormat:format(v["Get"..szFn1](v))),
			fnAction=not bDisable and function()
				Clouds_API.GetUserInputNumber(("Set%s"):format(szFn1)..(szFn2 and (",Set%s:"):format(szFn2) or ""),
				szFn2 and function(x,y)
					if x then v["Set"..szFn1](v,x) end
					if y then v["Set"..szFn2](v,y) end
				end or function(...)
					v["Set"..szFn1](v,...)
				end,(szFn2 and szFormat:format(v["Get"..szFn1](v),v["Get"..szFn2](v))
					or szFormat:format(v["Get"..szFn1](v))))
			end or nil,
			bDisable = bDisable and true or false,
		}
	end
	local function genOptionText(v, szHead,szFormat,szFn,bDisable)
		return {
			szOption = szHead..":\t"..szFormat:format(v["Get"..szFn](v)),
			fnAction=not bDisable and function()
				Clouds_API.GetUserInputText(("Set%s"):format(szFn),
				function(...)
					v["Set"..szFn](v,...)
				end,szFormat:format(v["Get"..szFn](v)))
			end or nil,
			bDisable = bDisable and true or false,
		}
	end
	local menu={
		{szOption = ("Cursor:\t(%.2f,%.2f)"):format(Cursor.GetPos()),bDisable=true},
		{bDevide=true},
	}
	for i,v in ipairs(list) do
		local name,szType = '"'..tostring(v)..'"',v:GetType()
		local treepath = {v:GetTreePath()}
		if v then
			if v.szName~="" then
				name = v:GetName()
			elseif v:GetType():sub(1,3)~="Wnd" then
				name = "index:" .. v:GetIndex()
			elseif v.___id then
				name = item.___id
			end
			local mm={
				szOption = szType..":\t"..name,
				szTip = Clouds_API.GetItemPathName(v),
				bCheck = true,
				bChecked = v:IsVisible(),
				fnAction = function(u,b)
					if b then
						v:Show()
					else
						v:Hide()
					end
				end,
				fnMouseEnter = function()
					local x,y = Cursor.GetPos()
					OutputTip("<text>text="..EncodeComponentsString("Path:"..table.concat({v:GetTreePath()})).." font=0 r=255 g=255 b=255</text>",400,{x,y,0,200})
				end,
				{szOption = treepath[1], bDisable=true},
				{szOption = treepath[2]~="" and treepath[2] or name, bDisable=true},
				{bDevide = true},
				{szOption = ("Type:\t%s"):format(szType).. 
					(Clouds_Debug.CanGetIndex(v) and ("(%d)"):format(v:GetIndex()or -1) or ""),bDisable=true},
				--genOption("Type","%s","Type",nil,true),
				genOptionNumber(v, "Pos","%.2f,%.2f","AbsPos"),
				genOptionNumber(v, "RelP","%.2f,%.2f","RelPos"),
				genOptionNumber(v, "Size","%.2f,%.2f","Size"),
				
				--{szOption = ("Pos:\t(%.2f,%.2f)"):format(v:GetAbsPos()),fnAction=function()Clouds_API.GetUserInputNumber("SetAbsPos:",function(x,y)v:SetAbsPos(x,y)end,("%.2f,%.2f"):format(v:GetAbsPos()),nil,2)end},
				--{szOption = ("RelP:\t(%.2f,%.2f)"):format(v:GetRelPos()),fnAction=function()Clouds_API.GetUserInputNumber("SetAbsPos:",function(x,y)v:SetRelPos(x,y)end,("%.2f,%.2f"):format(v:GetRelPos()),nil,2)end},
				--{szOption = ("Size:\t%.2f,%.2f"):format(v:GetSize()),fnAction=function()Clouds_API.GetUserInputNumber("SetAbsPos:",function(x,y)v:SetSize(x,y)end,("%.2f,%.2f"):format(v:GetSize()),nil,2)end},
				{bDevide = true},
			}
			
			if szType == "Text" then
				--table.insert(mm,{szOption = ("Scheme:\t%d,%.2f"):format(v:GetFontID(),v:GetFontScale()),fnAction=function()Clouds_API.GetUserInputNumber("SetAbsPos:",function(x,y)v:SetAbsPos(x,y)end,("%d,%.2f"):format(v:GetFontID(),v:GetFontScale()),nil,2)end})
				table.insert(mm,genOptionNumber(v, "Scheme","%d,%.2f","FontID","FontScale"))
				table.insert(mm,genOptionNumber(v, "Color","%d,%d,%d","FontColor"))
				table.insert(mm,genOptionText(v, "Text","%s","Text"))
				table.insert(mm,genOptionNumber(v, "Length","%d,%.2f","TextPosExtent","TextExtent",true))

			elseif szType == "Image" then
				table.insert(mm,genOptionNumber(v, "Type","%d,%d","ImageType","ImageID",true))
				table.insert(mm,genOptionNumber(v, "Frame","%d","Frame"))
			elseif szType == "Handle" then
				table.insert(mm,genOptionNumber(v, "Count","%d","ItemCount",nil,true))
			elseif szType == "WndFrame" then
				table.insert(mm,{
					szOption = "bDragable"..":\t"..("%s"):format(v["IsDragable"](v)and "true" or "false"),
					bCheck = true, bChecked = v["IsDragable"](v),
					fnAction = function(u,b)
						if not b then
							Clouds_API.GetUserInputNumber("fX,fY,fW,fH",
							function(...)
								v["SetDragArea"](v,...)
							end,"0,0,20,20")
							v["EnableDrag"](v,not b)
						else
							v["EnableDrag"](v,not b)
						end
					end
				})
			end

			table.insert(menu,mm)
		end
	end
	PopupMenu(menu)
end

local hooklist={}
local cpuusage={}
local hookused={}
Clouds_Debug.hooklist = hooklist
Clouds_Debug.hookused = hookused
Clouds_Debug.cpuusage = cpuusage

function Clouds_Debug.SetTable(t,name,value)
	t=t or _G
	for i in name:gmatch("(%S+)%.") do
		t=t[i]
	end
	t[("."..name):match("%.([^.]*)$")]=value
end

function Clouds_Debug.SetGlobal(name,value)
	Clouds_Debug.SetTable(_G,name,value)
end

function Clouds_Debug.hookfun(name,old)
	local tabname=name:match("^(.-)%.")
	cpuusage[tabname]=cpuusage[tabname] or {name=tabname,nfun=0,ncall=0,ntop=0,topname=""}
	local t,tt={name=name,old=old,called=0},cpuusage[tabname]
	local new=function(...)
		tt.ncall = tt.ncall+1
		t.called=t.called+1
		if t.called>tt.ntop then
			tt.ntop = t.called
			tt.topname = t.name
		end
		pcall(old,...)
	end
	t.new=new
	hookused[old]=name.."_old@"..GetLogicFrameCount()
	hookused[new]=name.."_new@"..GetLogicFrameCount()
	Clouds_Debug.SetGlobal(name,new)
	tt.nfun=tt.nfun+1
	table.insert(hooklist,t)
end

function Clouds_Debug.hookall(head)
	head = head or "^Clouds"
	for i,v in pairs(_G) do
		if i:find(head) and i~="Clouds_Debug" and not hookused[i] and not hookused[v] then
			if type(v)=="function" then
				Clouds_Debug.hookfun(i,v)
			elseif type(v)=="table" then
				for ii,vv in pairs(v) do
					if type(vv)=="function" and not hookused[ii] and not hookused[vv] then
						Clouds_Debug.hookfun(i.."."..ii,vv)
					end
				end
			end
		end
	end
end

RegisterEvent("PLAYER_ENTER_GAME",Clouds_Debug.init)
RegisterEvent("CALL_LUA_ERROR", Clouds_Debug.Error)


