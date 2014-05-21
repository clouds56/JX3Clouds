Clouds_JX3_Engine = {
	RegisterCustomData = function(name)
	end,

	tEvent={},
	RegisterEvent = function(name, fun)
		if not tEvent[name] then
			tEvent[name]={}
		end
		for i,v in ipairs(tEvent[name]) do
			if v==fun then
				return
			end
		end
		table.insert(tEvent[name],fun)
	end,

	UnRegisterEvent = function(name, fun)
		if not tEvent[name] then
			tEvent[name]={}
		end
		for i,v in ipairs(tEvent[name]) do
			if v==fun then
				tEvent[name][i]=nil
			end
		end
	end,

	GetLogicFrameCount = function()
		return math.floor(os.clock()*16)
	end,

	SysLog = function(head,msg)
		local s = os.date("%Y%m%d-%H%M%S")
		io.write(s..("<%s>:%s\n"):format(head,msg))
	end,

	Hotkey = {
		AddBinding = function(name, head, title, fun, none)
		end,
		Set = function(name, index, key, isctrl, isalt, isshift)
		end,
	},

	xxd = function(a,unit,line)
		-- %0do : address offset
		-- %0dl	: line number
		-- %0d.dx	: context with 1d for unit and 2d for repeats
		-- %da	:	ascii index
		--[[
		f=f or "%3l %08.4x"
		for i in f:gmatch("%%([%d.]*)([olxa])") do

		end
		]]
		local s=""
		unit = unit or 4
		line = line or 4
		for k=0,math.ceil(a:len()/unit/line)-1 do
			for i=k*line,(k+1)*line-1 do
				for j=i*unit+1,(i+1)*unit do
					local v=a:byte(j)
					s=s..(v and ("%02x"):format(v) or "  ")
				end
				s=s..' '
			end
			s=s..'\t'
			s=s..(a:sub(k*line*unit+1,(k+1)*line*unit):gsub("[^%w]","."))
			s=s..'\n'
		end
		return s
	end,

	var2str = function(t,suffix,index,first,tab,fun,multi)
		index =  index or 0
		suffix = suffix or "\t"
		if type(t)=="function" then
			return fun and "[[\n"..xxd(string.dump(t)).."]]" or tostring(t)
		elseif type(t)=="string" then
			return '"'..t:gsub("\n",multi and "\\\n" or "\\n")..'"'
		elseif type(t)=="number" then
			return tostring(t)
		elseif type(t)=="nil" or type(t)=="boolean" then
			return tostring(t)
		elseif type(t)=="userdata" then
			return tostring(t)
		elseif type(t)=="table" then
			if tab then
				return tostring(t)
			end
			local s=(first and suffix:rep(index) or "").."{"..("\t-- # : %d"):format(#t)
			local used=false
			for i=1,#t do
				local v,key=t[i]
				used=true
				s=s.."\n"..suffix:rep(index+1)..var2str(v,suffix,index+1,false,tab,fun,multi)..","
			end
			for i,v in pairs(t) do
				local key
				if type(i)=="number" then
					if i>#t then
						key=("[%d]"):format(i)
					end
				elseif type(i)=="string" then
					key=i
				else
					key=("[%s]"):format(i)
				end
				if key then
					used=true
					s=s..'\n'..suffix:rep(index+1)..key.." = "..var2str(v,suffix,index+1,false,tab,fun,multi)..","
				end
			end
			if not used then
				s=s..'}'
			else
				s=s..'\n'..suffix:rep(index).."}"
			end
			return s
		end
	end,

	Output = function(...)
		print(var2str({...}," "))
	end,

	AppendCommand = function(name, func)
	end,

	Wnd = {
		OpenWindow = function(ini, name)
			return {}
		end,
	},

	OutputMessage = function(head, msg)
		io.write(("[%s]%s"):format(head,msg))
	end,
}
 
local tEvent = Clouds_JX3_Engine.tEvent

local _class={}
class = function(super)
	local class_type={}
	class_type.ctor=false
	class_type.super=super
	class_type.new=function(...) 
			local obj={}
			do
				local create
				create = function(c,...)
					if c.super then
						create(c.super,...)
					end
					if c.ctor then
						c.ctor(obj,...)
					end
				end
 
				create(class_type,...)
			end
			setmetatable(obj,{ __index=_class[class_type] })
			return obj
		end
	local vtbl={}
	_class[class_type]=vtbl
 
	setmetatable(class_type,{__newindex=
		function(t,k,v)
			vtbl[k]=v
		end
	})
 
	if super then
		setmetatable(vtbl,{__index=
			function(t,k)
				local ret=_class[super][k]
				vtbl[k]=ret
				return ret
			end
		})
	end
 
	return class_type
end

var2str = Clouds_JX3_Engine.var2str
for i,v in pairs(Clouds_JX3_Engine) do
	if i:find("[A-Z]") then
		_G[i] = Clouds_JX3_Engine[i]
	end
end

local event = coroutine.create(function()
		while true do
			GetLogicFrameCount()
		end
		SysLog("DEBUG","init [Event]")
	end)
