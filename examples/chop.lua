--chop will Trans ".inic" into ".ini" which can simply be `Wnd.OpenWindow`
--the filename is stored in "workspace" or "LastOpen"
require "loadf"

function chop(filename,suf)
	local fin,fout
	local filefull=(suf and filename.."."..suf or filename)
	print("check..",filefull)
	fin=io.open(filefull..".inic")
	if fin then
		fin:close()
		print(filefull..".ini")
		fout=io.open(filefull..".ini","w")
		--print(str:byte(1,50))
		--print((function(...)return ("%2x "):rep(select('#',...)):format(...)end)(str:byte(1,50)))
		local str=loadf(filefull..".inic")
		fout:write(str:sub(str:find('\n')+1,-1))
		fout:close()
	end
end

local filename=getfilename(arg[1])
	print(arg[1],filename)
if type(filename)=="table" then
	for i,v in ipairs(filename) do
		chop(v)
	end
else
	chop(filename)
end
