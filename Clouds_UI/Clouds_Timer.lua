Clouds_Timer = {
	szIni = "interface\\Clouds_UI\\Clouds_Timer.ini",
	tAnchor = {},
	__REMOVE__={"remove"},
}

local timer={
	color = { 255, 0, 128 },
	list = {},
}
Clouds_Timer.timer = timer
Clouds_UI.timer=Clouds_Timer

RegisterCustomData("Clouds_Timer.tAnchor")

Clouds_Timer.UpdateFrame = function(name, enable, events)
	local frame = Station.Lookup("Normal/Clouds_Timer_"..name)
	if enable then
		if not frame then
			frame = Wnd.OpenWindow(Clouds_Timer.szIni, "Clouds_Timer_"..name)
			frame.szName = name
			for i,v in pairs(timer) do
				frame[i]=v
			end
			for i,v in pairs(events or {}) do
				frame[i]=v
			end
			frame.OnFrameBreathe = timer.OnFrameBreathe
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

timer.OnFrameCreate = function()
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("UI_SCALED")
	this.UpdateAnchor(this)
	UpdateCustomModeWindow(this, "µ¹¼ÆÊ±Ìõ_"..this.szName)
	local handle = this:Lookup("","")
	Clouds_UI.newPool(handle, Clouds_Timer.szIni, "Handle_Instance")
end

timer.OnFrameBreathe = function()
	local handle = this:Lookup("","")
	for i=#this.list,1,-1 do
		local data=this.list[i]
		data.last=data.last - 1
		this:update(i)
	end
end

timer.OnFrameDragEnd = function()
	this:CorrectPos()
	Clouds_Timer.tAnchor[this.szName] = GetFrameAnchor(this)
end

timer.UpdateAnchor = function(frame)
	local an = Clouds_Timer.tAnchor[frame.szName]
	if an then
		-- custom pos
		frame:SetPoint(an.s, 0, 0, an.r, an.x, an.y)
	end
	frame:CorrectPos()
end

timer.OnEvent = function(event)
	if event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "UI_SCALED" then
		this.UpdateAnchor(this)
	end
end

timer.clear = function(self)
	self.list={}
	self:update()
end

timer.add = function(self, name, time, text)
	text = text or name
	local handle=self:Lookup("","")
	local i=self:find(name)
	if i then
		self.list[i].text=text
		self.list[i].time=time
	else
		table.insert(self.list,{name=name,text=text,time=time,last=time})
	end
	while #self.list > handle.nIndex do
		handle.new()
	end
	self:update()
end

timer.find = function(self, name)
	local data=self.list[name]
	if data then
		return name
	end
	for i=1,#self.list do
		data=self.list[i]
		if data.name==name then
			return i
		end
	end
	return nil
end

timer.remove = function(self, name)
	local i=self:find(name)
	if i then
		table.remove(self.list,i)
	end
	self:update(__REMOVE__)
end

timer.update = function(self, name)
	local handle = self:Lookup("","")
	if name==__REMOVE__ then
		for i=#self.list,handle.nIndex-1 do
			handle:Lookup(i):Hide()
		end
	elseif not name then
		for i=1,#self.list do
			self:update(i)
		end
	else
		local i=self:find(name)
		if i then
			local item,data = handle:Lookup(i-1),self.list[i]
			if item then
				item:Lookup("Text_Name"):SetText(data.name)
				item:Lookup("Text_Time"):SetText(("%.2f\""):format(data.last/16))
				item:Lookup("Image_Timer"):SetPercentage(data.last/math.max(data.time,1))
				item:Show()
				if data.last <= 0  then
					self:remove(i)
				end
			end
		end
	end
end
