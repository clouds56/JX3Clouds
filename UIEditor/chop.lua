filename=io.open("LastOpen","r"):read("*a"):match([["(.-)"$]])
if filename:lower() == "uieditor" or filename:lower() == "info" then
	return
end
print(filename..".ini")
fin,fout=io.open(filename..".inic"),io.open(filename..".ini","w")
fin:seek("set",25) print(fin:read("*l"))
for line in fin:lines() do
	fout:write(line:sub(1,-2)..'\n')
end
fout:close()
