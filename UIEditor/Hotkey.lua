Hotkey.AddBinding("UIEditor_ShowHide", "開啟·關閉界面", "【界面編輯器】",
	function()
		local frame = Station.Lookup("Topmost/UIEditor")
		if frame and frame:IsVisible() then
			UIEditor.ClosePanel(true)
		else
			UIEditor.OpenPanel()
		end
	end, nil)

Hotkey.AddBinding("UIEditor_Undo", "操作：撤銷", "",
	function()
		UIEditor.RefreshTree(-1)
	end, nil)

Hotkey.AddBinding("UIEditor_Redo", "操作：恢復", "",
	function()
		UIEditor.RefreshTree(1)
	end, nil)

Hotkey.AddBinding("UIEditor_Refresh", "操作：刷新", "",
	function()
		UIEditor.RefreshTree()
	end, nil)

Hotkey.AddBinding("UIEditor_PosLeft", "位置：向左", "",
	function()
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_PosX", true)
		UIEditor.szPressDownName = "Edit_SC_PosX"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_PosRight", "位置：向右", "",
	function()
		UIEditor.ModifyPosOrSize(1, "Edit_SC_PosX", true)
		UIEditor.szPressDownName = "Edit_SC_PosX"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_PosUp", "位置：向上", "",
	function()
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_PosY", true)
		UIEditor.szPressDownName = "Edit_SC_PosY"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_PosDown", "位置：向下", "",
	function()
		UIEditor.ModifyPosOrSize(1, "Edit_SC_PosY", true)
		UIEditor.szPressDownName = "Edit_SC_PosY"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_SizeWLeft", "尺寸·寬度：增加", "",
	function()
		UIEditor.ModifyPosOrSize(1, "Edit_SC_SizeW", true)
		UIEditor.szPressDownName = "Edit_SC_SizeW"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_SizeWRight", "尺寸·寬度：減少", "",
	function()
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_SizeW", true)
		UIEditor.szPressDownName = "Edit_SC_SizeW"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_SizeHDown", "尺寸·高度：增加", "",
	function()
		UIEditor.ModifyPosOrSize(1, "Edit_SC_SizeH", true)
		UIEditor.szPressDownName = "Edit_SC_SizeH"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = 1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)

Hotkey.AddBinding("UIEditor_SizeHUp", "尺寸·高度：減少", "",
	function()
		UIEditor.ModifyPosOrSize(-1, "Edit_SC_SizeH", true)
		UIEditor.szPressDownName = "Edit_SC_SizeH"
		UIEditor.nPressDownFrame = 10
		UIEditor.nPressDownValue = -1
	end,
	function()
		if UIEditor.szPressDownName ~= "" then
			UIEditor.RecordPosOrSize()

			UIEditor.szPressDownName = ""
			UIEditor.nPressDownFrame = 0
			UIEditor.nPressDownValue = 0
		end
	end)
