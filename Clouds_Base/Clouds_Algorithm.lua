Clouds_Algorithm={}
algo=Clouds_Algorithm

algo["nil"]={}
algo.table={}
algo.object={}
algo["function"]={}
algo.string={}

NIL={"NIL"}
algo["nil"].id=NIL

algo.table.copy=function(tSrc,bShallow)
	local tDst={}
	for i,v in pairs(tSrc or {}) do
		if not bShallow and type(v)=="table" then
			tDst[i]=algo.table.copy(v,bShallow)
		else
			tDst[i]=v
		end
	end
	return tDst
end

algo.table.update=function(tDst,tSrc,bShallow)
	if type(tSrc)=="userdata" then
		for i,v in pairs(tDst) do
			if tSrc[i]==NIL then
				tDst[i]=nil
			elseif not bShallow and type(tSrc[i])=="table" then
				if type(v)~="table" then
					tDst[i]={}
				end
				algo.table.update(tDst[i],tSrc[i],bShallow)
			elseif type(tSrc[i])=="userdata" and type(v)=="table" then
				algo.table.update(v,tSrc[i],bShallow)
			else
				tDst[i]=tSrc[i]
			end
		end
	elseif type(tSrc)=="table" then
		for i,v in pairs(tSrc) do
			if v==NIL then
				tDst[i]=nil
			elseif not bShallow and type(v)=="table" then
				if type(tDst[i])~="table" then
					tDst[i]={}
				end
				algo.table.update(tDst[i],v,bShallow)
			elseif type(v)=="userdata" and type(tDst[i])=="table" then
				algo.table.update(tDst[i],v,bShallow)
			else
				tDst[i]=v
			end
		end
	end
	return tDst
end

algo.table.updatem=function(tDst,tSrc)
	if type(tSrc)=="userdata" then
		for i,v in pairs(tDst) do
			if not bShallow and type(tSrc[i])=="table" then
				if type(v)~="table" then
					tDst[i]={}
				end
				tDst[i]=algo.table.merge(tDst[i],tSrc[i])
			elseif type(tSrc[i])=="userdata" and type(v)=="table" then
				tDst[i]=algo.table.merge(v,tSrc[i])
			else
				tDst[i]=tSrc[i]
			end
		end
	elseif type(tSrc)=="table" then
		for i,v in pairs(tSrc) do
			if not bShallow and type(v)=="table" then
				if type(tDst[i])~="table" then
					tDst[i]={}
				end
				tDst[i]=algo.table.merge(tDst[i],v)
			elseif type(v)=="userdata" and type(tDst[i])=="table" then
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

algo.table.to_s=function(t,mode)
	if mode and mode.table then
		return mode:table(t) or ""
	end
	local s="{"
	for i,v in pairs(t) do
		s=s.."["..algo.object.to_s(i,mode).."]".."="..algo.object.to_s(v,mode)..","
	end
	s=s:sub(1,-2).."}"
	return s
end

algo.string.to_s=function(str,mode)
	if mode and mode.string then
		return mode:string(str) or ""
	end
	return '"'..str..'"'
end

algo["function"].to_s=function(func)
	if mode and mode["function"] then
		return mode["function"](mode,func) or ""
	end
	return tostring(func)
end


algo.object.to_s=function(obj,mode)
	if mode and mode[type(obj)] then
		return mode[type(obj)](mode,obj) or ""
	elseif type(obj)=="string" or type(obj)=="function" or type(obj)=="table" then
		return algo[type(obj)].to_s(mode,obj)
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
