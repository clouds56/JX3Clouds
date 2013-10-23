--Output(pcall(dofile, "Interface\\UIEditor\\PopMenu.lua"))
OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\PopMenu.lua" 开始加载 ...]] .. "\n"))

UIEditor = UIEditor or {}

---------------------------------------------------------------------------------------------------------------
-- 樹節點右鍵菜單
---------------------------------------------------------------------------------------------------------------
function UIEditor.PopTreeNodeMenu(treeNode)
	if not treeNode then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end
	local szTreeNodeType = tNodeInfo.szType
	if not szTreeNodeType then
		return
	end
	
	local tOptions = {}
	if szTreeNodeType == "Frame" or szTreeNodeType:match("^Wnd") then
		table.insert(tOptions, {
			szOption = "★添加子窗口：",
			{szOption = "虚窗口　　　WndWindow", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndWindow") end},
			{szOption = "滚动条　　　WndScrollBar", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndScrollBar") end},
			{szOption = "按钮　　　　WndButton", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndButton") end},
			{szOption = "复选框　　　WndCheckBox", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndCheckBox") end},
			{szOption = "输入框　　　WndEdit", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndEdit") end},
			{szOption = "标签页面　　WndPage", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndPage") end},
			{szOption = "标签页面集　WndPageSet", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndPageSet") end},		
			{szOption = "小地图　　　WndMiniMap", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndMiniMap") end},		
			{szOption = "场景　　　　WndScene", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndScene") end},
			{szOption = "内嵌网页　　WndWebPage", fnAction = function() UIEditor.AppendTreeNode(treeNode, "WndWebPage") end},
		})
		
		-- 只能拥有一个主容器组件
		local bEnableHandle = true
		if tNodeInfo.tChild then
			for i = 1, #tNodeInfo.tChild do
				if tNodeInfo.tChild[i].szType == "Handle" then
					bEnableHandle = false
					break
				end
			end
		end
		table.insert(tOptions, {
			szOption = "★添加主容器组件", bDisable = not bEnableHandle, r = 255, g = 255, b = 255, fnAction = function() UIEditor.AppendTreeNode(treeNode, "Handle") end
		})
	end
	
	if szTreeNodeType == "Frame" then
		table.insert(tOptions, {
			szOption = "　更改窗口层级：",
			{szOption = "Lowest", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Lowest") end},
			{szOption = "Lowest1", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Lowest1") end},
			{szOption = "Lowest2", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Lowest2") end},
			{szOption = "Normal", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Normal") end},
			{szOption = "Normal1", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Normal1") end},
			{szOption = "Normal2", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Normal2") end},
			{szOption = "Topmost", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Topmost") end},		
			{szOption = "Topmost1", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Topmost1") end},		
			{szOption = "Topmost2", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Topmost2") end},
			{szOption = "Texture", fnAction = function() UIEditor.ModifyWindowLayer(treeNode, "Texture") end},
		})
		table.insert(tOptions, {
			bDevide = true
		})
	end

	if szTreeNodeType == "Handle" then
		table.insert(tOptions, {
			szOption = "★添加组件：",
			{szOption = "空组件　　　Null", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Null") end},
			{szOption = "文本组件　　Text", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Text") end},
			{szOption = "图片组件　　Image", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Image") end},
			{szOption = "阴影组件　　Shadow", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Shadow") end},
			{szOption = "动画组件　　Animate", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Animate") end},
			{szOption = "格子组件　　Box", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Box") end},
			{szOption = "场景组件　　Scene", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Scene") end},		
			{szOption = "树节点组件　TreeLeaf", fnAction = function() UIEditor.AppendTreeNode(treeNode, "TreeLeaf") end},		-- TODO: 只有树容器才应该允许这个
			{szOption = "容器组件　　Handle", fnAction = function() UIEditor.AppendTreeNode(treeNode, "Handle") end},
		})
		table.insert(tOptions, {
			bDevide = true
		})
	end
	
	table.insert(tOptions, {
		szOption = "　置於底層", r = 150, g = 150, b = 255, fnAction = function() UIEditor.MoveTreeNode(treeNode, -999) end
	})
	
	table.insert(tOptions, {
		szOption = "　置於頂層", r = 150, g = 255, b = 150, fnAction = function() UIEditor.MoveTreeNode(treeNode, 999) end
	})	
	
	table.insert(tOptions, {
		szOption = "　上移位置", r = 255, g = 255, b = 255, fnAction = function() UIEditor.MoveTreeNode(treeNode, -1) end
	})
	
	table.insert(tOptions, {
		szOption = "　下移位置", r = 255, g = 255, b = 255, fnAction = function() UIEditor.MoveTreeNode(treeNode, 1) end
	})	
	
	table.insert(tOptions, {
		szOption = "　删除节点", r = 255, g = 50, b = 75, fnAction = function() UIEditor.DeleteTreeNode(treeNode) end
	})
	
	table.insert(tOptions, {
		bDevide = true
	})

	table.insert(tOptions, {
		szOption = "　复制节点", bDisable = (treeNode.szType == "Frame"), fnAction = function() UIEditor.CopyTreeNode(treeNode) end
	})
	
	table.insert(tOptions, {
		szOption = "　粘贴节点", bDisable = not UIEditor.tCopyTableCache, fnAction = function() UIEditor.PasteTreeNode(treeNode) end
	})
		
	local nX, nY = Cursor.GetPos(true)
	tOptions.x, tOptions.y = nX + 15, nY + 15
	PopupMenu(tOptions)
end

---------------------------------------------------------------------------------------------------------------
-- 在界面編輯窗口右鍵選擇控件的菜單, 穿透所有可能的圖片或者內容, 按類型分
---------------------------------------------------------------------------------------------------------------
function UIEditor.PopControlSelectMenu()
	if not UIEditor.handleUITree then
		return
	end

	local nHandleX, nHandleY = UIEditor.handleHoverSelectEffect:GetRelPos()
	local nMouseX, nMouseY = Cursor.GetPos()
	local nMouseInnerX, nMouseInnerY = nMouseX - nHandleX, nMouseY - nHandleY
	
	local tResult = {}
	local tResultArray = {}
	local nCount = UIEditor.handleUITree:GetItemCount()
	for i = 0, nCount - 1 do
		local treeNode = UIEditor.handleUITree:Lookup(i)
		if treeNode and treeNode.tInfo then
			local tNodeInfo = treeNode.tInfo
			local nX = tNodeInfo.nX or 0
			local nY = tNodeInfo.nY or 0
			local nW = tNodeInfo.nWidth or 0
			local nH = tNodeInfo.nHeight or 0

			local nShownX, nShownY = UIEditor.CalculateShownPos(treeNode)
			--if nMouseInnerX >= nX and nMouseInnerX <= nX + nW and nMouseInnerY >= nY and nMouseInnerY <= nY + nH then
			if nMouseInnerX >= nShownX and nMouseInnerX <= nShownX + nW and nMouseInnerY >= nShownY and nMouseInnerY <= nShownY + nH then
				tResult[tNodeInfo.szType] = tResult[tNodeInfo.szType] or {}
				tResult[tNodeInfo.szType][tNodeInfo.szName] = treeNode
				table.insert(tResultArray, treeNode)
			end
		end
	end

	local tOptions = {}
	if #tResultArray == 0 then
		return
	elseif #tResultArray <= 10 then
		for i = 1, #tResultArray do
			table.insert(tOptions, {
				szOption = tResultArray[i].tInfo.szName or "[未知控件]", fnAction = function()
					UIEditor.SelectTreeNode(tResultArray[i])
				end
			})
		end
	else
		for szKey, tValue in pairs(tResult) do
			local t = {
				szOption = szKey, r = 200, g = 150, b = 255,
			}
			for szControlName, treeNode in pairs(tValue) do
				table.insert(t, {
					szOption = szControlName, fnAction = function()
						UIEditor.SelectTreeNode(treeNode)
					end
				})
			end
			table.insert(tOptions, t)
		end		
	end

	tOptions.x, tOptions.y = nMouseX + 15, nMouseY + 15
	PopupMenu(tOptions)
end

---------------------------------------------------------------------------------------------------------------
-- 這是圖片文件選擇菜單
---------------------------------------------------------------------------------------------------------------
function UIEditor.PopImageSelectMenu()
	local tOptions = {}
	for szKey, tValue in pairs(UIEditor.tImageFileBaseNameList) do
		local t = {
			szOption = szKey, r = 200, g = 150, b = 255,
		}
		for i = 1, #tValue do
			table.insert(t, {
				szOption = tValue[i], fnAction = function()
					if not UIEditor.treeNodeSelected then
						return
					end
					UIEditor.UndoScopeStart()
					UIEditor.treeNodeSelected.tInfo.szImagePath = tValue[i]
					UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
				end
			})
		end
		table.insert(tOptions, t)
	end
	
	local nX, nY = Cursor.GetPos()
	tOptions.x, tOptions.y = nX + 15, nY + 15
	PopupMenu(tOptions)
end

---------------------------------------------------------------------------------------------------------------
-- 這是圖片類型選擇菜單
---------------------------------------------------------------------------------------------------------------
function UIEditor.PopImageTypeMenu()
	local tOptions = {}
	for i = 1, #UIEditor.tImageTypes do
		table.insert(tOptions, {
			szOption = UIEditor.tImageTypes[i], fnAction = function()
				if not UIEditor.treeNodeSelected then
					return
				end
				UIEditor.UndoScopeStart()
				UIEditor.treeNodeSelected.tInfo.szImageType = UIEditor.tImageTypes[i]
				UIEditor.UndoScopeEnd(UIEditor.treeNodeSelected.tInfo.szName)
			end,
		})		
	end

	local nX, nY = Cursor.GetPos()
	tOptions.x, tOptions.y = nX + 15, nY + 15
	PopupMenu(tOptions)
end

---------------------------------------------------------------------------------------------------------------
-- 這是功能工具選擇菜單
---------------------------------------------------------------------------------------------------------------
function UIEditor.PopToolMenu()
	local tOptions = {
		{szOption = "開啟邊框顯示（HelpGridLine）", bMCheck = true, bChecked = UIEditor.bGridLineEnable, fnAction = function()
			UIEditor.bGridLineEnable = not UIEditor.bGridLineEnable
			UIEditor.GridLineEnable(UIEditor.bGridLineEnable)
			GetPopupMenu():Hide()
		end},
	}

	local nX, nY = Cursor.GetPos()
	tOptions.x, tOptions.y = nX + 15, nY + 15
	PopupMenu(tOptions)
end

function UIEditor.PopFileMenu()
	local tOptions = {
		{szOption = "查看INI文本內容", fnAction = function()
			UIEditor.wndINI:Show()
			UIEditor.editINI:SetText(UIEditor.CalculateINIText())
			GetPopupMenu():Hide()
		end},
	}

	local nX, nY = Cursor.GetPos()
	tOptions.x, tOptions.y = nX + 15, nY + 15
	PopupMenu(tOptions)
end

OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\PopMenu.lua" 加载完成 ...]] .. "\n"))
