local inifile = require "inifile"
--require "class"

dofile "Clouds_Base\\Clouds_JX3_Engine.lua"

Clouds_Addon={
	AddonList = {
		["Clouds_Alert"] = true,
		["Clouds_Base"] = true,
		["Clouds_Test"] = true,
		["Clouds_UI"] = true,
	},
	inilist={},
}

function Clouds_Addon.loadaddon(name)
	local list,i=Clouds_Addon.inilist[name][name],0
	SysLog("LOG",("Loading [%s]"):format(name))
	while list["lua_"..i] do
		local fn=list["lua_"..i]
		SysLog("LOG",("\t%d.%s"):format(i,fn))
		dofile("..\\"..fn)
		i=i+1
	end
end

function Clouds_Addon.update()
	local depend = {}
	for i,v in pairs(Clouds_Addon.AddonList) do
		if v then
			local fini=io.open(i.."\\info.ini")
			local sini=assert(fini):read("*a")
			local ini=inifile.parse(sini)
			Clouds_Addon.inilist[i]=ini
			local d,sd={},ini.denpendence or ""
			for dd in (sd..";"):gmatch("([_%w]*)%s-;") do
				if dd~="" then
					d[dd]=true
				end
			end
			depend[i]=d
		end
	end
	for _,_ in pairs(depend) do
		for i,v in pairs(depend) do
			if not next(v) then
				depend[i]=nil
				Clouds_Addon.loadaddon(i)
				for ii,vv in pairs(depend) do
					vv[i]=nil
				end
			end
		end
	end
end

function Clouds_Addon.reload()
	dofile "Clouds_Addon.lua"
	Clouds_Addon.update()
end

