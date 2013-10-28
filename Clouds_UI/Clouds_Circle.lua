Clouds_Circle = {
	szIni = "interface\\Clouds_UI\\Clouds_Circle.ini",

	drawtext = function(tar,data,shadow,clear)
		local r,g,b,a = unpack(data.color)
		shadow:SetTriangleFan(GEOMETRY_TYPE.TEXT)
		if clear then
			shadow:ClearTriangleFanPoint()
		end
		shadow:AppendPoint(tar.type,tar.dwID,data.top,r,g,b,a,0,data.scheme,data.text,0,1)
	end,
	drawcircle = function(tar,data,shadow)
		local r,g,b,a=unpack(data.edgecolor)
		shadow:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
		shadow:ClearTriangleFanPoint()
		shadow:AppendPoint(tar.type,tar.dwID,false,unpack(data.centercolor))
		for i=0,data.precision do
			local theta=2*i*math.pi/data.precision
			shadow:AppendPoint(tar.type,tar.dwID,false,r,g,b,a,
				{data.radius*math.cos(theta),0,data.radius*math.sin(theta),0,0})
		end
	end,
	drawcake = function(tar,data,shadow)
		local r,g,b,a=unpack(data.edgecolor)
		shadow:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
		shadow:ClearTriangleFanPoint()
		shadow:AppendPoint(tar.type,tar.dwID,false,unpack(data.centercolor))
		for i=-data.precision,data.precision do
			tar.face=GetPlayer(tar.dwID).nFaceDirection/128*math.pi
			local theta=tar.face+i*data.angle/(2*data.precision)
			shadow:AppendPoint(tar.type,tar.dwID,false,r,g,b,a,
				{data.radius*math.cos(theta),0,data.radius*math.sin(theta),0,0})
		end
	end,
}

local circle={
	text_color = {255,255,0,255},
	cir_color = {255,0,128,100},
	cake_color = {0,255,255,100},
	list = {},
}
local app={}
Clouds_Circle.circle = circle
Clouds_UI.circle=Clouds_Circle

Clouds_Circle.UpdateFrame = function(name, enable, events)
	local frame = Station.Lookup("Normal/Clouds_Circle_"..name)
	if enable then
		if not frame then
			frame = Wnd.OpenWindow(Clouds_Circle.szIni, "Clouds_Circle_"..name)
			frame.szName = name
			algo.table.update(frame,circle)
			algo.table.update(frame,events)
			frame.OnFrameBreathe = circle.OnFrameBreathe
			local _this = this
			this = frame
			pcall(frame.OnFrameCreate)
			this = _this
		end
	elseif frame then
		Wnd.CloseWindow(frame)
		frame = nil
	end
	return frame
end

circle.OnFrameCreate = function()
	local handle = this:Lookup("","")
	Clouds_UI.newPool(handle, Clouds_Circle.szIni, "Handle_Instance")
	circle.initinstance(handle:Lookup(0))
end

circle.OnFrameBreathe = function()
	local handle = this:Lookup("","")
	this:update()
end

circle.OnEvent = function(event)
end

circle.initinstance = function(handle)
	Clouds_UI.newPool(handle, Clouds_Circle.szIni, "Shadow_Text")
	handle:Lookup("Shadow_Text").AppendPoint=Clouds_UI.AppendPoint
end

circle.clear = function(self)
	self.list={}
	self:update()
end

circle.add = function(self, name, data)
	text = text or name
	local handle=self:Lookup("","")
	if self.list[name] then
		algo.table.update(self.list[name],data,true)
	else
		self.list[name]=data
	end
	self:update()
	return self.list[name]
end

circle.remove = function(self, name)
	self.list[name]=nil
	self:update()
end

circle.update = function(self)
	local handle,i = self:Lookup("",""),0
	for n,v in pairs(self.list) do
		local item=handle:Lookup(i)
		if not item then
			item=handle.new()
			self.initinstance(item)
		end
		v:draw(item)
		i=i+1
	end
end

circle.draw = function(self, item)
	local text=item:Lookup("Shadow_Text")
	local cir=item:Lookup("Shadow_Circle")
	local r,g,b,a=unpack(self.color)
	text:SetTriangleFan(GEOMETRY_TYPE.TEXT)
	text:ClearTriangleFanPoint()
	text:AppendPoint(self.type,self.dwID,true,255,255,255,255,0,40,self.text,0,1)
	cir:SetTriangleFan(GEOMETRY_TYPE.TRIANGLE)
	cir:ClearTriangleFanPoint()
	cir:AppendPoint(self.type,self.dwID,false,r,g,b,a)
	for i=0,self.precision do
		cir:AppendPoint(self.type,self.dwID,false,r,g,b,a,
			{self.radius*math.cos(2*i*math.pi/self.precision),0,self.radius*math.sin(2*i*math.pi/self.precision),0,0})
	end
	item:Show()
end

circle.simpleadd = function(self, src, radius, color)
	self:add(tostring(src),{
		name=tostring(src),
		text="",
		type=TARGET.CHARACTER,
		dwID=src,
		radius=radius,
		precision=40,
		color=color or {255,0,128,100},
		draw=circle.draw,
	})
end

circle.new = function(self, name, type, src)
	local d={dwID=src,type=type,draw=circle.draw,frame=self}
	algo.table.update(d,app)
	return self:add(name,d)
end

app.updatetext = function(self, ...)
	return self:addtext("Text",...)
end

app.addtext = function(self, name, text, color, scheme, top)
	name = name or "Text"
	if not self[name] then
		self[name]={
			enable = true,
			type = "text",
			text = "",
			color = self.frame.text_color,
			scheme = 40,
			top = false
		}
	end
	algo.table.updatem(self[name],{text=text,color=color,scheme=scheme,top=top})
	return self
end

app.updatecircle = function(self, ...)
	return self:addcircle("Circle",...)
end

app.addcircle = function(self, name, radius, color, color2, precision)
	name = name or "Circle"
	if not self[name] then
		self[name]={
			enable = true,
			type = "circle",
			radius = 64,
			centercolor = self.frame.cir_color,
			edgecolor = self.frame.cir_color,
			precision = 40,
		}
	end
	algo.table.updatem(self.Circle,{radius=radius,centercolor=color,edgecolor=color2 or color,precision=precision})
	return self
end

app.updatecake = function(self, ...)
	return self:addcake("Cake",...)
end

app.addcake = function(self, name, radius, angle, color, color2, precision)
	name = name or "Cake"
	if not self[name] then
		self[name]={
			enable = true,
			type = "cake",
			radius = 160,
			angle = math.pi / 3,
			centercolor = self.frame.cake_color,
			edgecolor = self.frame.cake_color,
			precision = 3,
		}
	end
	algo.table.updatem(self[name],{radius=radius,angle=angle,centercolor=color,edgecolor=color2 or color,precision=precision})
	return self
end

app.draw = function(self, item)
	if self.Text then
		local data,text=self.Text,item:Lookup("Shadow_Text")
		Clouds_Circle.drawtext(self,data,text,true)
		text:Show()
	end
	local index=1
	for i,v in pairs(self) do
		if type(v)=="table" and i~="Text" then
			while index>=item.nIndex do
				local shadow=item.new()
				shadow.AppendPoint = Clouds_UI.AppendPoint
			end
			local shadow=item:Lookup(index)
			if v.type == "cake" then
				Clouds_Circle.drawcake(self,v,shadow)
			elseif v.type == "circle" then
				Clouds_Circle.drawcircle(self,v,shadow)
			elseif v.type == "text" then
				Clouds_Circle.drawtext(self,v,shadow)
			end
			shadow:Show()
			index = index + 1
		end
	end
	item:Show()
end
