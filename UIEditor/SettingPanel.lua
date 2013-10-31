--Output(pcall(dofile, "Interface\\UIEditor\\SettingPanel.lua"))
--OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\SettingPanel.lua" 开始加载 ...]] .. "\n"))

UIEditor = UIEditor or {}

---------------------------------------------------------------------------------------------------------------
-- 配置界面通常變量定義
---------------------------------------------------------------------------------------------------------------
UIEditor.szPressDownName = ""						-- 按下的左右數值修改按鈕所對應的 edit 控件名字
UIEditor.nPressDownValue = 0						-- 處理按下不動後 edit 控件變化值大小
UIEditor.nPressDownFrame = 0						-- 處理按下不動後 edit 控件內容變化的時間依據

---------------------------------------------------------------------------------------------------------------
-- 配置界面系統回調
---------------------------------------------------------------------------------------------------------------
function UIEditor.OnFrameBreathe_SettingPanel()
	UIEditor.nPressDownFrame = UIEditor.nPressDownFrame - 1
	UIEditor.ModifyPosOrSize()
end

function UIEditor.OnCheckBoxCheck_SettingPanel()
	local szName = this:GetName():gsub("CheckBox_", "")

	if not UIEditor.treeNodeSelected then
		return
	end

	if UIEditor.tEventIndex[szName] then
		UIEditor.RecordEventID(nil)
	elseif szName == "Text_ShowAll" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bShowAll = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "AutoEtc" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bAutoEtc = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "CenterEachRow" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bCenterEachRow = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "MultiLine" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bMultiLine = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "MlAutoAdj" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bMlAutoAdj = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "NoRichText" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bNoRichText = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	end
end

function UIEditor.OnCheckBoxUncheck_SettingPanel()
	local szName = this:GetName():gsub("CheckBox_", "")

	if not UIEditor.treeNodeSelected then
		return
	end

	if UIEditor.tEventIndex[szName] then
		UIEditor.RecordEventID(nil)
	elseif szName == "Text_ShowAll" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bShowAll = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "AutoEtc" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bAutoEtc = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "CenterEachRow" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bCenterEachRow = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "MultiLine" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bMultiLine = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "MlAutoAdj" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bMlAutoAdj = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	elseif szName == "NoRichText" then
		UIEditor.UndoScopeStart()
		UIEditor.treeNodeSelected.tInfo.bNoRichText = this:IsCheckBoxChecked()
		UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
	end
end

function UIEditor.OnLButtonDown_SettingPanel()
	local szName = this:GetName()

	if not UIEditor.treeNodeSelected then
		return
	end

	if szName == "Btn_PosX_L" then
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_PosX", true)
		UIEditor.szPressDownName = "Edit_SC_PosX"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	elseif szName == "Btn_PosX_R" then
		UIEditor.ModifyPosOrSize(1, "Edit_SC_PosX", true)
		UIEditor.szPressDownName = "Edit_SC_PosX"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	elseif szName == "Btn_PosY_L" then
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_PosY", true)
		UIEditor.szPressDownName = "Edit_SC_PosY"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	elseif szName == "Btn_PosY_R" then
		UIEditor.ModifyPosOrSize(1, "Edit_SC_PosY", true)
		UIEditor.szPressDownName = "Edit_SC_PosY"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1

	elseif szName == "Btn_SizeW_L" then
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_SizeW", true)
		UIEditor.szPressDownName = "Edit_SC_SizeW"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	elseif szName == "Btn_SizeW_R" then
		UIEditor.ModifyPosOrSize(1, "Edit_SC_SizeW", true)
		UIEditor.szPressDownName = "Edit_SC_SizeW"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	elseif szName == "Btn_SizeH_L" then
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_SizeH", true)
		UIEditor.szPressDownName = "Edit_SC_SizeH"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	elseif szName == "Btn_SizeH_R" then
		UIEditor.ModifyPosOrSize(1, "Edit_SC_SizeH", true)
		UIEditor.szPressDownName = "Edit_SC_SizeH"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	end
end

function UIEditor.OnLButtonUp_SettingPanel()
	local szName = this:GetName()
	if not UIEditor.treeNodeSelected then
		return
	end

	if szName == "Btn_PosX_L" or szName == "Btn_PosX_R" or szName == "Btn_PosY_L" or szName == "Btn_PosY_R"
		or szName == "Btn_SizeW_L" or szName == "Btn_SizeW_R" or szName == "Btn_SizeH_L" or szName == "Btn_SizeH_R" then
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end
end

function UIEditor.OnLButtonClick_SettingPanel()
	local szName = this:GetName()
	if not UIEditor.treeNodeSelected then
		return
	end

	if szName == "Btn_ImagePath" then
		UIEditor.PopImageSelectMenu()
	elseif szName == "Btn_ImageFrame" then
		if UIEditor.treeNodeSelected.tInfo.szType == "Image" then
			UIEditor.LoadUITexToImageSelectorPanel(UIEditor.wndSICommon:Lookup("Edit_SI_Path"):GetText())
		else
			UIEditor.LoadUITexToImageSelectorPanel(UIEditor.wndSICommon:Lookup("Edit_SI_Path"):GetText(), true)
		end
	elseif szName == "Btn_ImageSelectorClose" then
		UIEditor.CloseAllSelector()
	elseif szName == "Btn_ImageType" then
		if UIEditor.treeNodeSelected.tInfo.szType == "Image" then
			UIEditor.PopImageTypeMenu()
		end
	elseif szName == "Btn_ImageResize" then
		local nW = UIEditor.treeNodeSelected.tInfo.nImageWOrg or 0
		local nH = UIEditor.treeNodeSelected.tInfo.nImageHOrg or 0
		if nW and nH then
			UIEditor.wndSCSize:Lookup("Edit_SC_SizeW"):SetText(nW)
			UIEditor.wndSCSize:Lookup("Edit_SC_SizeH"):SetText(nH)
			UIEditor.RecordPosOrSize()
		end

	elseif szName == "Btn_TextFont" then
		UIEditor.LoadTextDummyToFontSelectorPanel()
	elseif szName == "Btn_HAlignType" then
		if UIEditor.treeNodeSelected then
			local szAlignType = this:Lookup("", "Text_HAlignType"):GetText()
			UIEditor.UndoScopeStart()
			if szAlignType == UIEditor.tTextHAlignTypes[1] then
				UIEditor.treeNodeSelected.tInfo.szHAlignType = UIEditor.tTextHAlignTypes[2]
			elseif szAlignType == UIEditor.tTextHAlignTypes[2] then
				UIEditor.treeNodeSelected.tInfo.szHAlignType = UIEditor.tTextHAlignTypes[3]
			else
				UIEditor.treeNodeSelected.tInfo.szHAlignType = UIEditor.tTextHAlignTypes[1]
			end
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		end
	elseif szName == "Btn_VAlignType" then
		if UIEditor.treeNodeSelected then
			local szAlignType = this:Lookup("", "Text_VAlignType"):GetText()
			UIEditor.UndoScopeStart()
			if szAlignType == UIEditor.tTextVAlignTypes[1] then
				UIEditor.treeNodeSelected.tInfo.szVAlignType = UIEditor.tTextVAlignTypes[2]
			elseif szAlignType == UIEditor.tTextVAlignTypes[2] then
				UIEditor.treeNodeSelected.tInfo.szVAlignType = UIEditor.tTextVAlignTypes[3]
			else
				UIEditor.treeNodeSelected.tInfo.szVAlignType = UIEditor.tTextVAlignTypes[1]
			end
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		end

	elseif szName == "Btn_ShadowColor" then
		UIEditor.LoadColorDummyToFontSelectorPanel()
	end
end

function UIEditor.OnEditSpecialKeyDown_SettingPanel()
	local szName = this:GetName()
	local szKey = GetKeyName(Station.GetMessageKey())

	if not UIEditor.treeNodeSelected then
		return
	end

	if szKey == "Enter" then
		if szName == "Edit_EventID" then
			local nEventID = tonumber(this:GetText())
			if nEventID then
				UIEditor.bCheckBoxSystemAction = true
				for i = 1, 22 do
					local bChecked = true
					if UIEditor.GetEventIDState(nEventID or 0, i) ~= 1 then
						bChecked = false
					end
					UIEditor.tWndSCEventCheckBox[i]:Check(bChecked)
				end
				UIEditor.bCheckBoxSystemAction = false
				UIEditor.RecordEventID(nEventID)
			end
		elseif szName == "Edit_SC_Name" then
			local nNewName = this:GetText()
			if nNewName ~= UIEditor.treeNodeSelected.tInfo.szName then
				nNewName = UIEditor.CalculateNodeName(nNewName)
				this:SetText(nNewName)
				UIEditor.UndoScopeStart()
				UIEditor.treeNodeSelected.tInfo.szName = nNewName
				UIEditor.UndoScopeEnd(nNewName)
			end
		elseif szName == "Edit_SC_Comment" then
			UIEditor.UndoScopeStart()
			local szComment = this:GetText()
			if not szComment or szComment == "" then
				UIEditor.treeNodeSelected.tInfo.szComment = nil
			else
				UIEditor.treeNodeSelected.tInfo.szComment = szComment
			end
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_SC_Tip" then
			UIEditor.UndoScopeStart()
			local szTip = this:GetText()
			if not szTip or szTip == "" then
				UIEditor.treeNodeSelected.tInfo.szTip = nil
			else
				UIEditor.treeNodeSelected.tInfo.szTip = szTip
			end
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_SC_PosX" or szName == "Edit_SC_PosY" or szName == "Edit_SC_SizeW" or szName == "Edit_SC_SizeH" then
			UIEditor.ModifyPosOrSize(0, "Edit_SC_SizeW", true)
			UIEditor.RecordPosOrSize()


		elseif szName == "Edit_SI_Path" then
			local szImagePath = this:GetText()
			UIEditor.UndoScopeStart()
			UIEditor.treeNodeSelected.tInfo.szImagePath = szImagePath
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_SI_Frame" then
			local nFrame = tonumber(this:GetText()) or 0
			UIEditor.UndoScopeStart()
			if UIEditor.treeNodeSelected.tInfo.szType == "Image" then
				UIEditor.treeNodeSelected.tInfo.nFrame = nFrame
			else
				UIEditor.treeNodeSelected.tInfo.nAniGroup = nFrame
			end
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_SI_Alpha" then
			UIEditor.UndoScopeStart()
			local nAlpha = math.min(tonumber(this:GetText()) or 255, 255)
			UIEditor.treeNodeSelected.tInfo.nAlpha = nAlpha
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)

		elseif szName == "Edit_ST_Text" then
			UIEditor.UndoScopeStart()
			local szText = this:GetText() or ""
			UIEditor.treeNodeSelected.tInfo.szText = szText
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_ST_Alpha" then
			UIEditor.UndoScopeStart()
			local nAlpha = math.min(tonumber(this:GetText()) or 255, 255)
			UIEditor.treeNodeSelected.tInfo.nAlpha = nAlpha
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_ST_FontSpacing" then
			UIEditor.UndoScopeStart()
			local nFontSpacing = math.min(tonumber(this:GetText()) or 0, 24)
			UIEditor.treeNodeSelected.tInfo.nFontSpacing = nFontSpacing
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_ST_RowSpacing" then
			UIEditor.UndoScopeStart()
			local nRowSpacing = math.min(tonumber(this:GetText()) or 0, 24)
			UIEditor.treeNodeSelected.tInfo.nRowSpacing = nRowSpacing
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		elseif szName == "Edit_ST_FontScheme" then
			UIEditor.UndoScopeStart()
			local nFontScheme = math.min(tonumber(this:GetText()) or 0, 255)
			UIEditor.treeNodeSelected.tInfo.nFontScheme = nFontScheme
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)

		elseif szName == "Edit_SS_Alpha" then
			UIEditor.UndoScopeStart()
			local nAlpha = math.min(tonumber(this:GetText()) or 255, 255)
			UIEditor.treeNodeSelected.tInfo.nAlpha = nAlpha
			UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
		end
	elseif szKey == "Esc" then
	end
end

function UIEditor.OnKillFocus_SettingPanel()
	local szName = this:GetName()

	if not UIEditor.treeNodeSelected then
		return
	end

    if szName == "Edit_EventID" then
		local tBitTab = {}
		for i = 1, 22 do
			tBitTab[i] = 0
			if UIEditor.tWndSCEventCheckBox[i]:IsCheckBoxChecked() then
				tBitTab[i] = 1
			end
		end
		UIEditor.wndSCEvent:Lookup("Edit_EventID"):SetText(UIEditor.BitTable2UInt(tBitTab) or 0)
	elseif szName == "Edit_SC_Name" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.szName or "")
	elseif szName == "Edit_SC_Comment" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.szComment or "")
	elseif szName == "Edit_SC_Tip" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.szTip or "")
	elseif szName == "Edit_SC_PosX" or szName == "Edit_SC_PosY" or szName == "Edit_SC_SizeW" or szName == "Edit_SC_SizeH" then
		UIEditor.wndSCPos:Lookup("Edit_SC_PosX"):SetText(UIEditor.treeNodeSelected.tInfo.nLeft or 0)
		UIEditor.wndSCPos:Lookup("Edit_SC_PosY"):SetText(UIEditor.treeNodeSelected.tInfo.nTop or 0)
		UIEditor.wndSCSize:Lookup("Edit_SC_SizeW"):SetText(UIEditor.treeNodeSelected.tInfo.nWidth or 0)
		UIEditor.wndSCSize:Lookup("Edit_SC_SizeH"):SetText(UIEditor.treeNodeSelected.tInfo.nHeight or 0)

	elseif szName == "Edit_SI_Path" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.szImagePath or "")
	elseif szName == "Edit_SI_Frame" then
		if UIEditor.treeNodeSelected.tInfo.szType == "Image" then
			this:SetText(UIEditor.treeNodeSelected.tInfo.nFrame or 0)
		else
			this:SetText(UIEditor.treeNodeSelected.tInfo.nAniGroup or -1)
		end
	elseif szName == "Edit_SI_Alpha" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.nAlpha or 255)

	elseif szName == "Edit_ST_Text" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.szText or "")
	elseif szName == "Edit_ST_Alpha" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.nAlpha or 255)
	elseif szName == "Edit_ST_FontSpacing" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.nFontSpacing or 0)
	elseif szName == "Edit_ST_RowSpacing" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.nRowSpacing or 0)
	elseif szName == "Edit_ST_FontScheme" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.nFontScheme or 0)

	elseif szName == "Edit_SS_Alpha" then
		this:SetText(UIEditor.treeNodeSelected.tInfo.nAlpha or 255)
    end
end

---------------------------------------------------------------------------------------------------------------
-- 配置界面功能函數
---------------------------------------------------------------------------------------------------------------
function UIEditor.CloseAllSelector()
	UIEditor.handleImageSelector:Clear()
	UIEditor.handleFontSelector:Clear()
	UIEditor.handleUIContent:Show()
	UIEditor.imageSelectedMask:Show()
end

function UIEditor.RefreshSettingPanel(treeNode)
	local tNodeInfo = {}
	if treeNode and treeNode.tInfo then
		tNodeInfo = treeNode.tInfo or {}
	end

	-- 屏蔽CheckBox事件
	UIEditor.bCheckBoxSystemAction = true

	-- Wnd_SC_Common
	UIEditor.wndSCCommon:Lookup("Edit_SC_Type"):SetText(tNodeInfo.szType or "")
	UIEditor.wndSCCommon:Lookup("Edit_SC_Comment"):SetText(tNodeInfo.szComment or "")
	UIEditor.wndSCCommon:Lookup("Edit_SC_Name"):SetText(tNodeInfo.szName or "")
	UIEditor.wndSCCommon:Lookup("Edit_SC_Tip"):SetText(tNodeInfo.szTip or "")
	UIEditor.wndSCCommon:Lookup("Btn_TipPos"):Lookup("", "Text_TipPos"):SetText(tNodeInfo.szTipPos or "固定")		-- TODO:

	UIEditor.wndSCCommon:Lookup("CheckBox_Visible"):Check(not tNodeInfo.bInvisible)
	UIEditor.wndSCCommon:Lookup("CheckBox_AllowScale"):Check(not tNodeInfo.bDisableScale)

	-- Wnd_SC_Pos
	UIEditor.wndSCPos:Lookup("Edit_SC_PosX"):SetText(tNodeInfo.nLeft or 0)
	UIEditor.wndSCPos:Lookup("Edit_SC_PosY"):SetText(tNodeInfo.nTop or 0)
	UIEditor.wndSCPos:Lookup("Btn_PosMode"):Lookup("", "Text_PosMode"):SetText(tNodeInfo.szPosMode or "指定")		-- TODO:

	-- Wnd_SC_Size
	UIEditor.wndSCSize:Lookup("Edit_SC_SizeW"):SetText(tNodeInfo.nWidth or 0)
	UIEditor.wndSCSize:Lookup("Edit_SC_SizeH"):SetText(tNodeInfo.nHeight or 0)

	-- Wnd_SC_Event
	UIEditor.wndSCEvent:Lookup("Edit_EventID"):SetText(tNodeInfo.nEventID or 0)
	for i = 1, 22 do
		local bChecked = true
		if UIEditor.GetEventIDState(tNodeInfo.nEventID or 0, i) ~= 1 then
			bChecked = false
		end
		UIEditor.tWndSCEventCheckBox[i]:Check(bChecked)
	end

	-- 下面就是專項類型的設置窗口
	if tNodeInfo.szType == "Image" or tNodeInfo.szType == "Animate" then
		UIEditor.wndSICommon:Lookup("Edit_SI_Path"):SetText(tNodeInfo.szImagePath or "")
		UIEditor.wndSICommon:Lookup("Edit_SI_Alpha"):SetText(tNodeInfo.nAlpha or 255)
		if tNodeInfo.szType == "Image" then
			UIEditor.wndSICommon:Lookup("Edit_SI_Frame"):SetText(tNodeInfo.nFrame or 0)
		else
			UIEditor.wndSICommon:Lookup("Edit_SI_Frame"):SetText(tNodeInfo.nAniGroup or -1)
		end
		UIEditor.wndSICommon:Lookup("Btn_ImageType"):Lookup("", "Text_ImageType"):SetText(tNodeInfo.szImageType or UIEditor.tImageTypes[1])

		UIEditor.wndSettingImage:Show()
	else
		UIEditor.wndSettingImage:Hide()
	end

	if tNodeInfo.szType == "Text" then
		UIEditor.wndSTCommon:Lookup("Edit_ST_Text"):SetText(tNodeInfo.szText or "")
		UIEditor.wndSTCommon:Lookup("Edit_ST_Alpha"):SetText(tNodeInfo.nAlpha or 255)
		UIEditor.wndSTCommon:Lookup("Edit_ST_FontSpacing"):SetText(tNodeInfo.nFontSpacing or 0)
		UIEditor.wndSTCommon:Lookup("Edit_ST_RowSpacing"):SetText(tNodeInfo.nRowSpacing or 0)
		UIEditor.wndSTCommon:Lookup("Edit_ST_FontScheme"):SetText(tNodeInfo.nFontScheme or 0)

		UIEditor.wndSTCommon:Lookup("Btn_TextFont"):Lookup("", "Text_TextFont"):SetFontScheme(tNodeInfo.nFontScheme or 0)
		UIEditor.wndSTCommon:Lookup("Btn_TextFont"):Lookup("", "Text_TextFont"):SetHAlign(UIEditor.tTextHAlignTypes[tNodeInfo.szHAlignType] or 0)
		UIEditor.wndSTCommon:Lookup("Btn_TextFont"):Lookup("", "Text_TextFont"):SetVAlign(UIEditor.tTextVAlignTypes[tNodeInfo.szVAlignType] or 0)
		UIEditor.wndSTCommon:Lookup("Btn_TextFont"):Lookup("", "Text_TextFont"):SetCenterEachLine(tNodeInfo.bCenterEachRow or false)
		UIEditor.wndSTCommon:Lookup("Btn_TextFont"):Lookup("", "Text_TextFont"):SetMultiLine(tNodeInfo.bMultiLine or false)
		UIEditor.wndSTCommon:Lookup("Btn_HAlignType"):Lookup("", "Text_HAlignType"):SetText(tNodeInfo.szHAlignType or UIEditor.tTextHAlignTypes[1])
		UIEditor.wndSTCommon:Lookup("Btn_VAlignType"):Lookup("", "Text_VAlignType"):SetText(tNodeInfo.szVAlignType or UIEditor.tTextVAlignTypes[1])

		UIEditor.bCheckBoxSystemAction = true
		UIEditor.wndSTCommon:Lookup("CheckBox_Text_ShowAll"):Check(tNodeInfo.bShowAll or true)
		UIEditor.wndSTCommon:Lookup("CheckBox_AutoEtc"):Check(tNodeInfo.bAutoEtc or false)
		UIEditor.wndSTCommon:Lookup("CheckBox_CenterEachRow"):Check(tNodeInfo.bCenterEachRow or false)
		UIEditor.wndSTCommon:Lookup("CheckBox_MultiLine"):Check(tNodeInfo.bMultiLine or false)
		UIEditor.wndSTCommon:Lookup("CheckBox_MlAutoAdj"):Check(tNodeInfo.bMlAutoAdj or false)
		UIEditor.wndSTCommon:Lookup("CheckBox_NoRichText"):Check(tNodeInfo.bNoRichText or false)
		UIEditor.bCheckBoxSystemAction = false

		UIEditor.wndSettingText:SetRelPos(440, 0)
		UIEditor.wndSettingText:Show()
	else
		UIEditor.wndSettingText:Hide()
	end

	if tNodeInfo.szType == "Shadow" then
		UIEditor.wndSSCommon:Lookup("Edit_SS_Alpha"):SetText(tNodeInfo.nAlpha or 255)
		UIEditor.wndSSCommon:Lookup("", "Shadow_ColorShow"):SetShadowColor(tNodeInfo.szColorName or "black")
		UIEditor.wndSSCommon:Lookup("", "Shadow_ColorShow"):SetAlpha(tNodeInfo.nAlpha or 255)

		UIEditor.wndSettingShadow:SetRelPos(440, 0)
		UIEditor.wndSettingShadow:Show()
	else
		UIEditor.wndSettingShadow:Hide()
	end

	-- 恢復CheckBox事件
	UIEditor.bCheckBoxSystemAction = false

	-- 更新Mask圖片
	if treeNode then
		UIEditor.imageSelectedMask:SetRelPos(UIEditor.CalculateShownPos(treeNode))
	end
	UIEditor.imageSelectedMask:SetSize(tNodeInfo.nWidth or 0, tNodeInfo.nHeight or 0)
	UIEditor.handleHoverSelectEffect:FormatAllItemPos()
end

-- 保存事件ID
function UIEditor.RecordEventID(nEventID)
	if not UIEditor.treeNodeSelected then
		UIEditor.wndSCEvent:Lookup("Edit_EventID"):SetText(0)
		return
	end

	if not nEventID then
		local tBitTab = {}
		for i = 1, 22 do
			tBitTab[i] = 0
			if UIEditor.tWndSCEventCheckBox[i]:IsCheckBoxChecked() then
				tBitTab[i] = 1
			end
		end
		nEventID = UIEditor.BitTable2UInt(tBitTab) or 0
	end
	UIEditor.wndSCEvent:Lookup("Edit_EventID"):SetText(nEventID)

	UIEditor.UndoScopeStart()
	if nEventID == 0 then
		UIEditor.treeNodeSelected.tInfo.nEventID = nil
	else
		UIEditor.treeNodeSelected.tInfo.nEventID = nEventID
	end
	UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
end

-- 保存坐標和大小
function UIEditor.RecordPosOrSize(nX, nY, nW, nH)
	if not UIEditor.treeNodeSelected then
		return
	end

	nX = nX or tonumber(UIEditor.wndSCPos:Lookup("Edit_SC_PosX"):GetText()) or 0
	nY = nY or tonumber(UIEditor.wndSCPos:Lookup("Edit_SC_PosY"):GetText()) or 0
	nW = nW or tonumber(UIEditor.wndSCSize:Lookup("Edit_SC_SizeW"):GetText()) or 0
	nH = nH or tonumber(UIEditor.wndSCSize:Lookup("Edit_SC_SizeH"):GetText()) or 0

	UIEditor.UndoScopeStart()
	UIEditor.treeNodeSelected.tInfo.nLeft = nX
	UIEditor.treeNodeSelected.tInfo.nTop = nY
	UIEditor.treeNodeSelected.tInfo.nWidth = nW
	UIEditor.treeNodeSelected.tInfo.nHeight = nH
	UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
end

function UIEditor.ModifyPosOrSize(nValue, szEditName, bNoCheckTime)
	szEditName = szEditName or UIEditor.szPressDownName
	nValue = nValue or UIEditor.nPressDownValue
	if not nValue then
		return
	end
	if szEditName == "" then
		return
	end
	if not bNoCheckTime and UIEditor.nPressDownFrame > 0 then
		return
	end
	local nPressDownFrame = UIEditor.nPressDownFrame
	if bNoCheckTime then
		nPressDownFrame = 8
	end

	local edit = UIEditor.wndSCPos:Lookup(szEditName) or UIEditor.wndSCSize:Lookup(szEditName)
	if not edit then
		return
	end

	local nV = tonumber(edit:GetText())
	if nV then
		local nSpeed = math.min(math.ceil(math.abs(nPressDownFrame) / 8), 10)
		nV = nV + nSpeed * nValue
		edit:SetText(nV)

		local nX = tonumber(UIEditor.wndSCPos:Lookup("Edit_SC_PosX"):GetText()) or 0
		local nY = tonumber(UIEditor.wndSCPos:Lookup("Edit_SC_PosY"):GetText()) or 0
		local nW = tonumber(UIEditor.wndSCSize:Lookup("Edit_SC_SizeW"):GetText()) or 0
		local nH = tonumber(UIEditor.wndSCSize:Lookup("Edit_SC_SizeH"):GetText()) or 0

		if UIEditor.treeNodeSelected then
			local nShownX, nShownY = UIEditor.CalculateShownPos(UIEditor.treeNodeSelected, nX, nY)

			UIEditor.imageSelectedMask:SetRelPos(nShownX, nShownY)
			UIEditor.imageSelectedMask:SetSize(nW, nH)
			UIEditor.handleHoverSelectEffect:FormatAllItemPos()

			UIEditor.TempInfoBarText = ("控件調整：{X= %d, Y= %d}, {W= %d, H= %d}, {ShownX= %d, ShownY= %d}"):format(nX, nY, nW, nH, nShownX, nShownY)
		else
			UIEditor.TempInfoBarText = "控件調整：沒有選中有效的控件節點，控件選擇框顯示會不正常。"
		end
	end
end

--OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\SettingPanel.lua" 加载完成 ...]] .. "\n"))
