--chop will Trans ".ini" into ".inic" for "UIEditor" to analyse
--the filename is stored in "LastOpen"
filename=io.open("LastOpen","r"):read("*a"):match([["(.-)"]])
print(filename)
filename = filename:match("^(.-)%s+.*$") or filename
print(filename..".ini")
fin,fout=io.open(filename..".ini"),io.open(filename..".inic","w")
fout:write(("data=\"# Import from %s.ini (written by Clouds)\\\n"):format(filename))
fout:write((fin:read("*a"):gsub("\\","\\\\"):gsub("\'","\\\'"):gsub("\"","\\\""):gsub("\n","\\\n")))
fout:write("\"")
fout:close()

