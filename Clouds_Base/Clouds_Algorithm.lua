Clouds_Algorithm={}
algo=Clouds_Algorithm

algo["nil"]={}
algo.arg={}
algo.table={}
algo.object={}
algo["function"]={}
algo.string={}
algo.userdata={}
algo.ini={}

NIL={"NIL"}
algo["nil"].id=NIL

algo.arg.select = function(x,...)
	local t={...}
	if x=='#' then
		return #t
	end
	for i=1,x-1 do
		table.remove(t,1)
	end
	return unpack(t)
end
select = select or algo.arg.select

algo.table.is=function(tSrc)
	if type(tSrc)=="table" and not tSrc.___id and not tSrc._type then
		return true
	end
	return false
end

algo.table.copy=function(tSrc,bShallow)
	local tDst={}
	for i,v in pairs(tSrc or {}) do
		if not bShallow and algo.table.is(v) then
			tDst[i]=algo.table.copy(v,bShallow)
		else
			tDst[i]=v
		end
	end
	return tDst
end

algo.table.update=function(tDst,tSrc,bShallow)
	if algo.userdata.is(tSrc) then
		for i,v in pairs(tDst) do
			if tSrc[i]==NIL then
				tDst[i]=nil
			elseif not bShallow and algo.table.is(tSrc[i]) then
				if not algo.table.is(v) then
					tDst[i]={}
				end
				algo.table.update(tDst[i],tSrc[i],bShallow)
			elseif algo.userdata.is(tSrc[i]) and algo.table.is(v) then
				algo.table.update(v,tSrc[i],bShallow)
			else
				tDst[i]=tSrc[i]
			end
		end
	elseif algo.table.is(tSrc) then
		for i,v in pairs(tSrc) do
			if v==NIL then
				tDst[i]=nil
			elseif not bShallow and algo.table.is(v) then
				if not algo.table.is(tDst[i]) then
					tDst[i]={}
				end
				algo.table.update(tDst[i],v,bShallow)
			elseif algo.userdata.is(v) and algo.table.is(tDst[i]) then
				algo.table.update(tDst[i],v,bShallow)
			else
				tDst[i]=v
			end
		end
	end
	return tDst
end

algo.table.updatem=function(tDst,tSrc)
	if algo.userdata.is(tSrc) then
		for i,v in pairs(tDst) do
			if not bShallow and algo.table.is(tSrc[i]) then
				if not algo.table.is(v) then
					tDst[i]={}
				end
				tDst[i]=algo.table.merge(tDst[i],tSrc[i])
			elseif algo.userdata.is(tSrc[i]) and algo.table.is(v) then
				tDst[i]=algo.table.merge(v,tSrc[i])
			else
				tDst[i]=tSrc[i]
			end
		end
	elseif algo.table.is(tSrc) then
		for i,v in pairs(tSrc) do
			if not bShallow and algo.table.is(v) then
				if not algo.table.is(tDst[i]) then
					tDst[i]={}
				end
				tDst[i]=algo.table.merge(tDst[i],v)
			elseif algo.userdata.is(v) and algo.table.is(tDst[i]) then
				tDst[i]=algo.table.merge(tDst[i],v)
			else
				tDst[i]=v
			end
		end
	end
	return tDst
end

algo.table.merge=function(tDst,tSrc,bShallow)
	return algo.table.update(algo.table.copy(tDst,bShallow),tSrc,bShallow)
end

algo.table.select=function(tSrc,func,nIndex)
	nIndex = nIndex or 1
	for i=#tSrc,1,-1 do
		if nIndex == 1 then
			if not func(tSrc[i]) then
				table.remove(tSrc,i)
			end
		else
			algo.table.select(tSrc,func,nIndex-1)
		end
	end
	for i,v in pairs(tSrc) do
		if type(i)~="number" or i>#tSrc then
			if nIndex == 1 then
				if not func(v) then
					tSrc[i]=nil
				end
			else
				algo.table.select(tSrc,func,nIndex-1)
			end
		end
	end
	--Output(tSrc)
	return tSrc
end

algo.table.map=function(tSrc,func,nIndex)
	nIndex=nIndex or 1
	for i,v in pairs(tSrc) do
		if nIndex == 1 then
			tSrc[i] = func(v)
		else
			algo.table.map(v,func,nIndex - 1)
		end
	end
	return tSrc
end

algo.var2str = function(t,suffix,index,first,tab,fun,multi)
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
		local s=(first and suffix:rep(index) or "").."{"
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
			s=s..'\n'..("\t-- # : %d"):format(#t)..'\n'..suffix:rep(index).."}"
		end
		return s
	end
end

algo.print = function(...)
	local t={...}
	OutputMessage("MSG_SYS",algo.object.to_s(#t>1 and t or t[1])..'\n')
end


algo.table.to_s=function(t,mode,index)
	index=index or 0
	mode = mode or {suffix="  ",tab=false,fun=false,multi=true,}
	if mode.table then
		return mode:table(t) or ""
	end
	if mode.tab then
		return tostring(t)
	end
	local s="{"
	local used=false
	for i=1,#t do
		local v,key=t[i]
		used=true
		s=s.."\n"..mode.suffix:rep(index+1)..algo.object.to_s(v,mode,index+1)..","
	end
	if used then
		s=s..'\n'..mode.suffix:rep(index+1)..("-- # : %d"):format(#t)
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
			key=("[%s]"):format(tostring(i))
		end
		if key then
			used=true
			s=s..'\n'..mode.suffix:rep(index+1)..key.." = "..algo.object.to_s(v,mode,index+1)..","
		end
	end
	if not used then
		s=s..'}'
	else
		s=s..'\n'..mode.suffix:rep(index).."}"
	end
	return s
end

algo.string.xxd = function(a,unit,line)
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
end

algo.string.encoding=function(str,mode)
	mode = mode or {bshowt=false,multi=false}
	str = str:gsub("\\","\\\\")
	--str = str:gsub("[\000-\010]",function(a)return ("\\%03o"):format(a:byte(1)) end)
	str = str:gsub("\"","\\\""):gsub("\'","\\\'")
	if mode.bshowt then
		str = str:gsub("\t","\\t")
	end
	str = str:gsub("\n",mode.multi and "\\\n" or "\\n")
	return str
end

algo.string.to_s=function(str,mode)
	if mode and mode.string then
		return mode:string(str) or ""
	end
	return '"'..algo.string.encoding(str)..'"'
end

algo["function"].to_s=function(func,mode)
	Output(mode)
	if mode and mode["function"] then
		return mode["function"](mode,func) or ""
	elseif mode and mode.fun then
		return tostring(func).."  --[[\n"..algo.string.xxd(string.dump(func)).."]]"
	end
	return tostring(func)
end

algo.object.to_s=function(obj,mode,index)
	local modeex={suffix="  ",tab=false,fun=false,multi=true,}
	local mode=algo.table.merge(modeex,mode or {})
	if mode[type(obj)] then
		return mode[type(obj)](mode,obj) or ""
	elseif type(obj)=="string" or type(obj)=="function" then
		return algo[type(obj)].to_s(obj,mode)
	elseif type(obj)=="table" then
		return algo.table.to_s(obj,mode,index or 0)
	else
		return tostring(obj) or ""
	end
end

--print(algo.object.to_s {{1},function()end})

function algo.string.tgmatch(str,tpat,b)
	str = str or ""
	tpat = tpat or {}--such as {"hello   world","."}
	local k=0
	local tFind={}
	local tNow={0,0}

	local function sgmatch()
		local lastp,lastq=tNow[1],tNow[2]
		if lastp==#str+1 then
			return
		end
		--print("sgmatch "..lastp.." "..lastq.." "..str.."("..#str..")")
		for i,v in pairs(tpat) do
			--print("<LOG>[FIND]",i,tpat[i],tFind[i] and table.concat(tFind[i],"|"))
			if not tFind[i] or tFind[i][1]<=lastq then
				local p,q = string.find(str,v,k)
				if p then
					--print("<LOG>","Find",p,q,string.sub(str,p,q),v)
					tFind[i]={p,q,string.sub(str,p,q),v}
				else
					tFind[i]={#str+1}
				end
			end
		end
		tNow={#str+1}
		for i,t in pairs(tFind) do
			--print("<LOG>"..i,table.concat(t,"|"))
			if t[1]<tNow[1] then
				tNow=t
			end
		end
		if tNow[1]==#str+1 then
			return
		end
		str = string.sub(str,tNow[2]+1)
		--print("<LOG>",tNow[2],str)
		for i,t in pairs(tFind) do
			--print("- -",i,table.concat(t,"|"),#str)
			if t~=tNow then
				t[1]=t[1]-tNow[2]
				if t[1]~=#str+1 then
					t[2]=t[2]-tNow[2]
				end
			end
		end
		--print(table.concat(tNow,'*'))
		if b then
			return {string.match(tNow[3],tNow[4])}
		else
			return string.match(tNow[3],tNow[4])
		end
	end
	return sgmatch
end
string.tgmatch=algo.string.tgmatch

function algo.string.formatpattern(str, change)
	str = str or ""
	change = change or {{"%%%%","^^"},{"%%",""},{"^^","%"}}

	for _,t in pairs(change) do
		str = string.gsub(str, t[1], t[2])
	end
	return str
end

function algo.string.splitexclude(str, change, divstr, pattern, divide)
	str = str or ""
	change = change or {{"¡¾¡¾","[["},{"¡¿¡¿","]]"},{"£¬",","},{"\n",","},{" ",""},{",,",","},{",$",""},{"^,",""}}
		--Other Version: {{"£¬",","},{"%s*,%s*",","},{",+",","},{",+$",""},{"^,+",""}}
	pattern = pattern or "%-%-%[%[(.-)%]%]"
	divide = divide or ","
	divstr = divstr or "" --Other Version "\n"

	for _,t in pairs(change) do
		str = string.gsub(str, t[1], t[2])
	end
	local szExcludeString = ""
	for v in string.gmatch(str, pattern) do
		szExcludeString = szExcludeString .. divide .. v
	end
	str = string.gsub(str, pattern, ",")
	for _,t in pairs(change) do
		str = string.gsub(str, t[1], t[2])
		szExcludeString = string.gsub(szExcludeString, t[1], t[2])
	end
	if szExcludeString~="" then
		pattern = algo.string.formatpattern(pattern)
		local l,r=string.find(pattern, "%(%.%-%)")
		szExcludeString = string.sub(pattern,1,l-1) .. szExcludeString .. string.sub(pattern,r+1)
	end
	return str..divstr..szExcludeString
end

function algo.string.asub(str,l,r,append)
	local len=#str
	l=l or 1
	r=r or l
	append=append or " "
	if l>=1 and r<=len then
		return string.sub(str,l,r)
	elseif r>len then
		str=str..append
		return algo.string.asub(str,l,r,append)
	elseif l<0 then
		local lenapp=#append
		str=append..str
		return algo.string.asub(str,l+lenapp,r>=0 and r+lenapp or r,append)
	elseif l==0 then
		return algo.string.asub(str,1,r,append)
	end
	return str
end
string.asub=algo.string.asub

algo.userdata.is=function(uSrc)
	if type(uSrc)=="userdata" then
		return true
	elseif type(uSrc)=="table" and (uSrc.___id or uSrc._type) then
		return true
	end
	return false
end

inifile = {}

function algo.ini.parse(str)
	local t,i = {},{}
	local section
	for line in (str.."\n"):gmatch("(.-)\n") do
		local s = line:match("^%[([^%]]+)%]$")
		if s then
			section = s
			t[section] = t[section] or {}
			i[section] = {}
			table.insert(i,section)
		end
		if line:match("^;") or line:match("^#") then
			line = ""
		end
		local key, value = line:match("^([._$%w]+)%s-=%s-(.+)$")
		if key and value then
			if tonumber(value) then value = tonumber(value) end
			if value == "true" then value = true end
			if value == "false" then value = false end
			t[section][key] = value
			table.insert(i[section],key)
		end
	end
	return t, i
end

function algo.ini.save(t, i)
	local contents = ""
	if i then
		for _,section in ipairs(i) do
			contents = contents .. ("[%s]\n"):format(section)
			for _, key in ipairs(i[section]) do
				contents = contents .. ("%s=%s\n"):format(key, tostring(t[section][key]))
			end
			contents = contents .. "\n"
		end
	else
		for section, s in pairs(t) do
			contents = contents .. ("[%s]\n"):format(section)
			for key, value in pairs(s) do
				contents = contents .. ("%s=%s\n"):format(key, tostring(value))
			end
			contents = contents .. "\n"
		end
	end
	return contents
end

return inifile

