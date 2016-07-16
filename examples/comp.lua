--Debug for decide if 2 tables are the same
--the filename is stored in "LastOpen"
local filename=io.open("LastOpen","r"):read("*a"):match([["(.-)"$]])
filename = filename:match("^(.-)\t.*$") or filename
print(filename..".ini")
local fin1,fin2=io.open(filename..".end"),io.open(filename..".std")
local str1,str2=fin1:read("*a"),fin2:read("*a")
fin1:close() fin2:close()
loadstring("x"..str1:sub(str1:sub(1,30):find("data"),-1))()--xdata={...}
loadstring("y"..str2:sub(str2:sub(1,30):find("data"),-1))()--ydata={...}

ydata={{ydata}}
function comp(x,y)
	if type(x)~="table" then
		if x==y then
			return true
		else
			return false,"\n"..tostring(x)..' != '..tostring(y)
		end
	end
	if type(x)~=type(y) then
		return false,"\n"..tostring(x)..' != '..tostring(y)
	end
	for i,v in pairs(x) do
		local b,s=comp(v,y[i])
		if not b then
			s = tostring(i).." "..s
			return false,s
		end
	end
	return true
end

print(xdata,ydata)
print(comp(xdata,ydata))
print(comp(ydata,xdata))
io.read()
