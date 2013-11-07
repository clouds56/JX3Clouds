UIEditor_Debug = {}

UIEditor_Debug.szIni = "interface\\UIEditor\\UIEditor_Debug.ini"

function UIEditor_Debug.show()
	local frame = Station.Lookup("Topmost/UIEditor_Debug")
	if not frame then
		frame = Wnd.OpenWindow(UIEditor_Debug.szIni,"UIEditor_Debug")
	end
	frame:Show()
end

function UIEditor_Debug.hide()
	local frame = Station.Lookup("Topmost/UIEditor_Debug")
	if frame then
		frame:Hide()
	end
	local fui = Station.Lookup("Topmost/UIEditor")
	if fui then
		fui:Show()
	end
end

function UIEditor_Debug.OnItemLButtonClick()
	local name = this:GetName()
	if name == "Image_Hide" then
		UIEditor_Debug.hide()
	end
end

UIEditor_Debug.show()
UIEditor_Debug.hide()
