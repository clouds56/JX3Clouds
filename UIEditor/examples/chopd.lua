--chop will Trans ".ini" into ".inic" for "UIEditor" to analyse
--the filename is stored in "LastOpen"
require "loadf"

function chopd(filename,suf)
	local fin,fout
	for _,pre in ipairs({filename,".","old"}) do
		local filefull=pre.."/"..(suf and filename.."."..suf or filename)
		print("check..",filefull)
		fin=io.open(filefull..".ini")
		if fin then
			print(filefull..".inic")
			fout=io.open(filefull..".inic","w")
			--print(str:byte(1,50))
			--print((function(...)return ("%2x "):rep(select('#',...)):format(...)end)(str:byte(1,50)))
			local str=fin:read("*a")
			fin:close()
			fout:write(("data=\"# Import from %s.ini (written by Clouds)\\\n"):format(filename))
			fout:write((str:gsub("\\","\\\\"):gsub("\'","\\\'"):gsub("\"","\\\""):gsub("\n","\\\n")))
			fout:write("\"")
		end
	end
end

local filename=getfilename(arg[1])
	print(arg[1],filename)
if type(filename)=="table" then
	for i,v in ipairs(filename) do
		chopd(v)
	end
else
	chopd(filename)
end
