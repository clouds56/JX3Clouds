--chop will Trans ".inic" into ".ini" which can simply be `Wnd.OpenWindow`
--the filename is stored in "LastOpen"
filename= io.open("LastOpen","r"):read("*a"):match([["(.-)"]])
filename = filename:match("^(.-)\t.*$") or filename
function chop(filename)
	print(filename..".ini")
	fin,fout=io.open(filename..".inic"),io.open(filename..".ini","w")
	if not fin then return end
	local str=fin:read("*a")
	fin:close()
	loadstring(str:sub(str:sub(1,30):find("data"),-1))()
	fout:write(data:sub(data:find('\n')+1,-1))
	fout:close()
end
chop(filename)
chop(filename..".1")