Clouds_Circle = {
	szIni = "interface\\Clouds_UI\\Clouds_Circle.ini",

	drawtext = function(tar,data,shadow,clear)
		local r,g,b,a = unpack(data.color)
		shadow:SetTriangleFan(GEOMETRY_TYPE.TEXT)
		if clear then
			shadow:ClearTriangleFanPoint()
		end
		shadow:AppendPoint(tar.type,tar.dwID,false,r,g,b,a,0,data.scheme,data.text,0,1)
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
			for i,v in pairs(circle) do
				frame[i]=v
			end
			for i,v in pairs(events or {}) do
				frame[i]=v
			end
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
	handle:Lookup(0):Lookup("Shadow_Circle").AppendPoint=Clouds_UI.AppendPoint
	handle:Lookup(0):Lookup("Shadow_Text").AppendPoint=Clouds_UI.AppendPoint
end

circle.OnFrameBreathe = function()
	local handle = this:Lookup("","")
	this:update()
end

circle.OnEvent = function(event)
end

circle.clear = function(self)
	self.list={}
	self:update()
end

circle.add = function(self, name, data)
	text = text or name
	local handle=self:Lookup("","")
	if self.list[name] then
		for i,v in pairs(data) do
			self.list[name][i]=v
		end
	else
		self.list[name]=data
	end
	self:update()
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
			item:Lookup("Shadow_Circle").AppendPoint=Clouds_UI.AppendPoint
			item:Lookup("Shadow_Text").AppendPoint=Clouds_UI.AppendPoint
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
		type=TARGET_CHARACTER,
		dwID=src,
		radius=radius,
		precision=40,
		color=color or {255,0,128,100},
		draw=circle.draw,
	})
end

circle.new = function(self, name, type, src)
	local d={dwID=src,type=type,draw=circle.draw,frame=self}
	for i,v in pairs(app) do
		d[i]=v
	end
	self:add(name,d)
	return d
end

app.updatetext = function(self, text, color, scheme)
	if not self.Text then
		self.Text={
			enable = true,
			text = "",
			color = self.frame.text_color,
			scheme = 40,
		}
	end
	algo.table.updatem(self.Text,{text=text,color=color,scheme=scheme})
	return self
end

app.updatecircle = function(self, radius, color, color2, precision)
	if not self.Circle then
		self.Circle={
			enable = true,
			radius = 64,
			centercolor = self.frame.cir_color,
			edgecolor = self.frame.cir_color,
			precision = 40,
		}
	end
	algo.table.updatem(self.Circle,{radius=radius,centercolor=color,edgecolor=color2 or color,precision=precision})
	return self
end

app.addcake = function(self, ...)
	return self:addcakes("Cake",...)
end

app.addcakes = function(self, name, radius, angle, color, color2, precision)
	name = name or "Cake"
	if not self[name] then
		self[name]={
			enable = true,
			radius = 64,
			angle = math.pi / 3,
			centercolor = self.frame.cake_color,
			edgecolor = self.frame.cake_color,
			precision = 7,
		}
	end
	algo.table.updatem(self[name],{radius=radius,angle=angle,centercolor=color,edgecolor=color2 or color,precision=precision})
	return self
end

app.draw = function(self, item)
	if self.Text then
		local data,text=self.Text,item:Lookup("Shadow_Text")
		Clouds_Circle.drawtext(self,data,text,true)
	end
	if self.Circle then
		local data,circle=self.Circle,item:Lookup("Shadow_Circle")
		Clouds_Circle.drawcircle(self,data,circle)
	end
	item:Show()
end
