--Output(pcall(dofile, "Interface\\UIEditor\\UIEditor.lua"))
OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\UIEditor.lua" 开始加载 ...]] .. "\n"))

UIEditor = UIEditor or {}

---------------------------------------------------------------------------------------------------------------
-- 主界面通常變量定義
---------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
-- 主界面系統回調
---------------------------------------------------------------------------------------------------------------
function UIEditor.OnFrameBreathe()
	UIEditor.OnFrameBreathe_SettingPanel()
end

function UIEditor.OnRegFrameRender()
	UIEditor.OnFrameRender_UIContent()
end

function UIEditor.OnItemLButtonDown()
	UIEditor.OnItemLButtonDown_UIContent()
end

function UIEditor.OnItemLButtonUp()
end

function UIEditor.OnItemLButtonClick()
	UIEditor.OnItemLButtonClick_TreeNode()
	UIEditor.OnItemLButtonClick_UIContent()
end

function UIEditor.OnItemLButtonDBClick()
	UIEditor.OnItemLButtonDBClick_TreeNode()
end

function UIEditor.OnItemRButtonDown()
	UIEditor.OnItemRButtonDown_UIContent()
end

function UIEditor.OnItemRButtonClick()
	UIEditor.OnItemRButtonClick_TreeNode()
	UIEditor.OnItemRButtonClick_UIContent()
end

function UIEditor.OnItemMouseEnter()
	UIEditor.OnItemMouseEnter_TreeNode()
	UIEditor.OnItemMouseEnter_UIContent()
end

function UIEditor.OnItemMouseLeave()
	UIEditor.OnItemMouseLeave_TreeNode()
	UIEditor.OnItemMouseLeave_UIContent()
end

function UIEditor.OnCheckBoxCheck()
	if UIEditor.bCheckBoxSystemAction then
		return
	end
	
	UIEditor.OnCheckBoxCheck_SettingPanel()
end

function UIEditor.OnCheckBoxUncheck()
	if UIEditor.bCheckBoxSystemAction then
		return
	end

	UIEditor.OnCheckBoxUncheck_SettingPanel()
end

function UIEditor.OnLButtonDown()
	UIEditor.OnLButtonDown_SettingPanel()
end

function UIEditor.OnLButtonUp()
	UIEditor.OnLButtonUp_SettingPanel()
end

function UIEditor.OnLButtonClick()
	local szName = this:GetName()


	if szName == "Btn_Close" then
		UIEditor.ClosePanel(true)
	elseif szName == "Btn_CloseINIHandle" then
		UIEditor.wndINI:Hide()
	elseif szName == "Btn_Undo" then
		UIEditor.RefreshTree(-1)
	elseif szName == "Btn_Refresh" then
		UIEditor.SaveTableTmp()
		UIEditor.RefreshTree()
	elseif szName == "Btn_Redo" then
		UIEditor.RefreshTree(1)
	elseif szName == "Btn_File" then
		UIEditor.CalculateINIText()
		UIEditor.PopFileMenu()
	elseif szName == "Btn_Tool" then
		UIEditor.PopToolMenu()
	end
	
	UIEditor.OnLButtonClick_SettingPanel()
end

function UIEditor.OnEditChanged()
end

function UIEditor.OnEditSpecialKeyDown()
	UIEditor.OnEditSpecialKeyDown_SettingPanel()
end

function UIEditor.OnSetFocus()
end

function UIEditor.OnKillFocus()
	UIEditor.OnKillFocus_SettingPanel()
end

function UIEditor.OnItemLButtonDrag()
	UIEditor.OnItemLButtonDrag_UIContent()
end

function UIEditor.OnItemLButtonDragEnd()
	UIEditor.OnItemLButtonDragEnd_UIContent()
end

-------------------------------------------------------------------------------------------------------------------
function UIEditor.OnFrameCreate()
	this:RegisterEvent("RENDER_FRAME_UPDATE")
end

function UIEditor.OnEvent(szEvent)
	if szEvent == "RENDER_FRAME_UPDATE" then
		UIEditor.OnRegFrameRender()
	end
end

function UIEditor.OpenPanel()
	local frame = Station.Lookup("Topmost/UIEditor")
	if not frame then
		frame = Wnd.OpenWindow("Interface\\UIEditor\\UIEditor.ini", "UIEditor")
	end
	frame:Show()

	UIEditor.frameSelf = frame
	
	-- 容器
	UIEditor.handleMain = frame:Lookup("", "")
	UIEditor.handleBG = frame:Lookup("", "Handle_BG")
	UIEditor.handleImageSelector = frame:Lookup("", "Handle_ImageSelector")
	UIEditor.handleFontSelector = frame:Lookup("", "Handle_FontOrColorSelector")
	UIEditor.handleHoverSelectEffect = frame:Lookup("", "Handle_HoverSelectEffect")
	UIEditor.handleHelpGridLine = frame:Lookup("", "Handle_HelpGridLine")
	
	UIEditor.handleUITree = frame:Lookup("", "Handle_UITree")
	UIEditor.handleUIContent = frame:Lookup("", "Handle_UIContent")
	
	UIEditor.imageHoverBox = UIEditor.handleHoverSelectEffect:Lookup("Image_HoverSelectBox")
	UIEditor.imageSelectedMask = UIEditor.handleHoverSelectEffect:Lookup("Image_SelectedNodeMask")

	-- 虛窗口
	UIEditor.wndSetting = frame:Lookup("Wnd_Setting")
	UIEditor.wndSettingCommon = UIEditor.wndSetting:Lookup("Wnd_Setting_Common")
	
	UIEditor.wndSCCommon = UIEditor.wndSettingCommon:Lookup("Wnd_SC_Common")
	UIEditor.wndSCPos = UIEditor.wndSettingCommon:Lookup("Wnd_SC_Pos")
	UIEditor.wndSCSize = UIEditor.wndSettingCommon:Lookup("Wnd_SC_Size")
	UIEditor.wndSCEvent = UIEditor.wndSettingCommon:Lookup("Wnd_SC_Event")
	
	UIEditor.wndSettingImage = UIEditor.wndSetting:Lookup("Wnd_Setting_Image")
	UIEditor.wndSICommon = UIEditor.wndSettingImage:Lookup("Wnd_SI_Common")
	
	UIEditor.wndSettingText = UIEditor.wndSetting:Lookup("Wnd_Setting_Text")
	UIEditor.wndSTCommon = UIEditor.wndSettingText:Lookup("Wnd_ST_Common")
	
	UIEditor.wndSettingShadow = UIEditor.wndSetting:Lookup("Wnd_Setting_Shadow")
	UIEditor.wndSSCommon = UIEditor.wndSettingShadow:Lookup("Wnd_SS_Common")

	-- INI顯示容器
	UIEditor.wndINI = frame:Lookup("Wnd_INI")
	UIEditor.editINI = UIEditor.wndINI:Lookup("Edit_INI")

	-- 事件表控件集合
	UIEditor.tWndSCEventCheckBox = {}
	for key, value in pairs(UIEditor.tEventIndex) do
		local checkBox = UIEditor.wndSCEvent:Lookup("CheckBox_" .. key)
		if checkBox then
			UIEditor.tWndSCEventCheckBox[value] = checkBox
		end
	end

	-- 这里用标准的 Table 来建立内容
	UIEditor.LoadTable()

	UIEditor.handleHelpGridLine:Clear()
	UIEditor.handleFontSelector:Clear()
	UIEditor.wndINI:Hide()
end

function UIEditor.ClosePanel(bHide)
	local frame = Station.Lookup("Topmost/UIEditor")
	if frame then
		if bHide then
			frame:Hide()
		else
			Wnd.CloseWindow(frame:GetName())
		end
	end
end

UIEditor.ClosePanel()
UIEditor.OpenPanel()
OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\UIEditor.lua" 加载完成 ...]] .. "\n"))
