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
			end

				--[[unpack(algo.table.map(algo.table.select(
				{
					{{"Text"},"Scheme:\t%d,%.2f",v.GetFontID,v.GetFontScale},
					{{"Text"},"Color:\t%3d,%3d,%3d",v.GetFontColor},
					{{"Text"},"Text:\t%s",v.GetText},
					{{"Text"},"Length\t%2d,%.2f",v.GetTextPosExtent,v.GetTextExtent},

					{{"Image"},"Type:\t%d,%d",v.GetImageType,v.GetImageID},
					{{"Image"},"Frame:\t%d",v.GetFrame},

					{{"Handle"},"ItemCount:\t%d",v.GetItemCount},
				},function(t)
					for _,tp in ipairs(t[1]) do
						if tp==v:GetType() or tp==v:GetType():sub(1,3) then
							return true
						end
					end
					return false
				end),function(tt)
					local str,t=tt[2],{select(3,unpack(tt))}
					if #t==1 then
						t={t[1](v)}
					else
						algo.table.map(t,function(f)return f(v) end)
					end
					return {szOption = str:format(unpack(t)),bDisable=true}
				end
				))]]
			table.insert(menu,mm)
		end
	end
	PopupMenu(menu)
end

RegisterEvent("PLAYER_ENTER_GAME",Clouds_Debug.init)
RegisterEvent("CALL_LUA_ERROR", Clouds_Debug.Error)


