--Output(pcall(dofile, "Interface\\UIEditor\\TreeNode.lua"))
--OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\TreeNode.lua" 开始加载 ...]] .. "\n"))

UIEditor = UIEditor or {}

---------------------------------------------------------------------------------------------------------------
-- 樹節點通常變量定義
---------------------------------------------------------------------------------------------------------------
UIEditor.tCopyTableCache = nil		-- 可以撤销的树节点保存栈
UIEditor.treeNodeSelected = nil		-- 被選擇的節點

---------------------------------------------------------------------------------------------------------------
-- 樹節點系統回調
---------------------------------------------------------------------------------------------------------------
function UIEditor.OnItemLButtonClick_TreeNode()
	local szName = this:GetName()

	if szName:match("^TreeNode_") then
		UIEditor.SelectTreeNode(this)
	end
end

function UIEditor.OnItemLButtonDBClick_TreeNode()
	local szName = this:GetName()

	if szName:match("^TreeNode_") then
		if this:IsExpand() then
			this:Collapse()
		else
			this:Expand()
		end
		UIEditor.handleUITree:FormatAllItemPos()
	end
end

function UIEditor.OnItemRButtonClick_TreeNode()
	local szName = this:GetName()

	if szName:match("^TreeNode_") then
		UIEditor.PopTreeNodeMenu(this)
	end
end

function UIEditor.OnItemMouseEnter_TreeNode()
	local szName = this:GetName()

	if szName:match("^TreeNode_") then
		local tNodeInfo = this.tInfo
		local img = this:Lookup("ImageLeafCover_" .. tNodeInfo.nLevel)
		if img then
			img:Show()
		end

		if tNodeInfo and IsCtrlKeyDown() then
			local nMouseX, nMouseY = Cursor.GetPos()
			local szTipInfo = "<Text>text=" .. EncodeComponentsString("　 类　型：") .. " font=162 </text>" ..
				"<Text>text=" .. EncodeComponentsString(tNodeInfo.szType) .. " font=100 </text>"
			szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n　 层　级：") .. " font=162 </text>" ..
				"<Text>text=" .. EncodeComponentsString(tNodeInfo.nLevel) .. " font=100 </text>"
			szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n　 名　称：") .. " font=162 </text>" ..
				"<Text>text=" .. EncodeComponentsString(tNodeInfo.szName) .. " font=100 </text>"
			szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n－－－－－－－－－－－") .. " font=162 </text>"

			if this.parent and this.parent.tInfo then
				szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n　 父节点：") .. " font=162 </text>" ..
					"<Text>text=" .. EncodeComponentsString(this.parent.tInfo.szName or "[未知父节点]") .. " font=100 </text>"
			end
			if tNodeInfo.tChild and #tNodeInfo.tChild > 0 then
				szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n　 子节点：") .. " font=162 </text>" ..
					"<Text>text=" .. EncodeComponentsString(#tNodeInfo.tChild .. " 个") .. " font=100 </text>"
				for i = 1, math.min(#tNodeInfo.tChild, 10) do
					if tNodeInfo.tChild[i].szType == "Handle" then
						if tNodeInfo.tChild[i].tChild and #tNodeInfo.tChild[i].tChild > 0 then
							szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n 　★" .. tNodeInfo.tChild[i].szName or "[未知子节点]") .. " font=100 </text>"
						else
							szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n 　☆" .. tNodeInfo.tChild[i].szName or "[未知子节点]") .. " font=100 </text>"
						end
					else
						szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n 　　" .. tNodeInfo.tChild[i].szName or "[未知子节点]") .. " font=100 </text>"
					end
				end
				if #tNodeInfo.tChild > 10 then
					szTipInfo = szTipInfo .. "<Text>text=" .. EncodeComponentsString("\n 　　……") .. " font=100 </text>"
				end
			end

			OutputTip(szTipInfo, 1000, {nMouseX - 15, nMouseY - 20, 0, 0})
		end
	end
end

function UIEditor.OnItemMouseLeave_TreeNode()
	local szName = this:GetName()

	if szName:match("^TreeNode_") then
		if not UIEditor.treeNodeSelected or UIEditor.treeNodeSelected ~= this then
			local tNodeInfo = this.tInfo
			local img = this:Lookup("ImageLeafCover_" .. tNodeInfo.nLevel)
			if img then
				img:Hide()
			end
		end
	end

	HideTip()
end

---------------------------------------------------------------------------------------------------------------
-- 樹節點功能函數
---------------------------------------------------------------------------------------------------------------
-- 計算一個樹節點的名字(控件名字)
function UIEditor.CalculateNodeName(szBaseName)
	if not UIEditor.handleUITree then
		return szBaseName
	end

	local nCount = UIEditor.handleUITree:GetItemCount()
	local nNewAutoIndex = 0
	local bFound = false
	for i = 0, nCount - 1 do
		local treeNode = UIEditor.handleUITree:Lookup(i)
		if treeNode and treeNode.tInfo then
			local szName = treeNode.tInfo.szName or ""
			if szName == szBaseName then
				bFound = true
			end

			local szNameIndex = szName:match("^" .. szBaseName .. "_(%d*)")
			if szNameIndex then
				local nNameIndex = tonumber(szNameIndex)
				if nNameIndex and nNameIndex > nNewAutoIndex then
					nNewAutoIndex = nNameIndex
				end
			end
		end
	end

	if bFound then
		return szBaseName .. "_" .. (nNewAutoIndex + 1)
	end
	return szBaseName
end

-- 獲得當前棧樹信息
function UIEditor.GetTreeAllInfo(nStackLevelShift)
	nStackLevelShift = nStackLevelShift or 0
	local nUndoStackLevelBak = UIEditor.nUndoStackLevel
	if nStackLevelShift > 0 then
		UIEditor.nUndoStackLevel = math.min(UIEditor.nUndoStackLevel + nStackLevelShift, #UIEditor.tUndoStack)
	elseif nStackLevelShift < 0 then
		UIEditor.nUndoStackLevel = math.max(UIEditor.nUndoStackLevel + nStackLevelShift, 1)
	end

	-- 获取树结构数据表, 不存在就嘗試獲取當前的
	local tInfo = UIEditor.tUndoStack[UIEditor.nUndoStackLevel]
	if not tInfo then
		UIEditor.nUndoStackLevel = nUndoStackLevelBak
		tInfo = UIEditor.tUndoStack[UIEditor.nUndoStackLevel]
	end
	return tInfo
end

-- 展開指定的節點(包括其所有父節點)
function UIEditor.ExpandTreeNode(treeNode)
	if not treeNode then
		return
	end

	local parent = treeNode.parent
	for k = 0, 15 do
		if parent then
			parent:Expand()
			parent = parent.parent
		else
			break
		end
	end

	treeNode:Expand()
	UIEditor.handleUITree:FormatAllItemPos()
end

-- 選擇指定的樹節點
function UIEditor.SelectTreeNode(treeNode)
	--TODO: this is temporary solution (check for ___id)
	if UIEditor.treeNodeSelected and UIEditor.treeNodeSelected.___id then
		local img = UIEditor.treeNodeSelected:Lookup("ImageLeafCover_" .. UIEditor.treeNodeSelected.tInfo.nLevel)
		if img then
			img:Hide()
		end
	end

	if not treeNode then
		return
	end

	UIEditor.treeNodeSelected = treeNode
	local img = treeNode:Lookup("ImageLeafCover_" .. treeNode.tInfo.nLevel)
	if img then
		img:Show()
	end

	UIEditor.ExpandTreeNode(treeNode)
	UIEditor.RefreshSettingPanel(treeNode)

	UIEditor.CloseAllSelector()
end

-- 創建整棵樹, 遞歸調用, 由 RefreshTree 調用
function UIEditor.CreateTree(tTreeInfo, treeNodeParent, szExpandNodeName, tSelectedNodeName)
	if not tTreeInfo then
		return
	end

	for i = 1, #tTreeInfo do
		local tNodeInfo = tTreeInfo[i]
		if tNodeInfo and tNodeInfo.nLevel and tNodeInfo.nLevel < 0 then		-- 最外层的 table
			UIEditor.CreateTree(tNodeInfo.tChild, nil, szExpandNodeName, tSelectedNodeName)
		elseif tNodeInfo and tNodeInfo.nLevel and tNodeInfo.szType and tNodeInfo.szType ~= "" and tNodeInfo.szName and tNodeInfo.szName ~= "" then
			local nIndex = UIEditor.handleUITree:GetItemCount()
			local node = UIEditor.handleUITree:AppendItemFromIni(UIEditor.szINIPath, "TreeLeaf_" .. tNodeInfo.nLevel, "TreeNode_" .. nIndex)

			if node then
				-- 給樹節點掛接數據
				node.parent = treeNodeParent
				node.tInfo = tNodeInfo

				-- 節點是否需要展開
				local bNeedExpand = false

				-- 這裡設置樹節點的文字(控件名字)
				if tNodeInfo.szLayer and tNodeInfo.szLayer ~= "" then
					node:Lookup("TextLeaf_" .. tNodeInfo.nLevel):SetText(tNodeInfo.szName .. " (" .. tNodeInfo.szLayer .. ")")
					bNeedExpand = true
				else
					node:Lookup("TextLeaf_" .. tNodeInfo.nLevel):SetText(tNodeInfo.szName)
				end

				-- 下面處理展開(更新Setting面板)
				if node.parent and node.parent.szType == "Frame" then
					bNeedExpand = true
				end

				if szExpandNodeName and szExpandNodeName == tNodeInfo.szName then
					bNeedExpand = true
				end

				for _, szSNName in ipairs(tSelectedNodeName or {}) do
					if szSNName and szSNName == tNodeInfo.szName then
						bNeedExpand = true
						UIEditor.SelectTreeNode(node)
						break
					end
				end

				if bNeedExpand then
					UIEditor.ExpandTreeNode(node)
				end

				-- 掛接父節點的子節點(自己)
				if treeNodeParent then
					treeNodeParent.child = treeNodeParent.child or {}
					table.insert(treeNodeParent.child, node)
				end

				-- 自己沒有子節點則不顯示樹圖標
				if not tNodeInfo.tChild or #tNodeInfo.tChild == 0 then
					node:SetNodeIconSize(1, 1)
				end

				-- 這裡創建可見的對象內容
				UIEditor.AppendUIContent(node)

				-- 繼續遞歸
				UIEditor.CreateTree(tNodeInfo.tChild, node, szExpandNodeName, tSelectedNodeName)
			end
		end
	end
end

-- 刷新当树显示, nStackLevelShift 为 0 或者 nil 表示当前, -1 表示上一个保存的树(Ctrl+Z), 1 表示下一个保存的树(Ctrl+Y)
function UIEditor.RefreshTree(nStackLevelShift, szExpandNodeName)
	local tTreeInfo = UIEditor.GetTreeAllInfo(nStackLevelShift)
	if not tTreeInfo then
		return
	end

	-- 刷新撤銷數量顯示
	UIEditor.frameSelf:Lookup("Btn_Refresh"):Lookup("", "Text_Refresh"):SetText(UIEditor.nUndoStackLevel .. "/" .. #UIEditor.tUndoStack)

	local tSelectedNodeName = {}
	if tTreeInfo.szSelectedNodeName then
		table.insert(tSelectedNodeName, tTreeInfo.szSelectedNodeName)
	end
	if UIEditor.treeNodeSelected then
		table.insert(tSelectedNodeName, UIEditor.treeNodeSelected.tInfo.szName)
	end
	UIEditor.SelectTreeNode(nil)

	-- 根据树结构数据表生成树节点 (递归)
	UIEditor.handleUITree:Clear()
	UIEditor.handleUIContent:Clear()

	UIEditor.CreateTree(tTreeInfo, nil, szExpandNodeName, tSelectedNodeName)
	UIEditor.handleUITree:FormatAllItemPos()
	UIEditor.handleUIContent:FormatAllItemPos()

	if not UIEditor.treeNodeSelected then
		UIEditor.RefreshSettingPanel(nil)
	end
end

-- 添加一個樹節點
function UIEditor.AppendTreeNode(treeNode, szType)
	if not treeNode or not szType then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end

	local szNewNodeName = UIEditor.CalculateNodeName(szType:gsub("^Wnd", "") .. "_New")
	local tNewNodeInfo = {
		nLevel = tNodeInfo.nLevel + 1,
		szType = szType,
		szName = szNewNodeName,
		nWidth = 40,
		nHeight = 20,
		tChild = {},
	}

	UIEditor.UndoScopeStart(tNewNodeInfo)
	tNodeInfo.tChild = tNodeInfo.tChild or {}
	table.insert(tNodeInfo.tChild, tNewNodeInfo)
	UIEditor.UndoScopeEnd(tNodeInfo.szName)
end

-- 修改樹節點的 Layer 信息
function UIEditor.ModifyWindowLayer(treeNode, szLayer)
	if not treeNode then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end

	UIEditor.UndoScopeStart()
	tNodeInfo.szLayer = szLayer
	UIEditor.UndoScopeEnd(tNodeInfo.szName)
end

-- 移動一個節點的位置, 位置決定了可見性和覆蓋特徵
function UIEditor.MoveTreeNode(treeNode, nShift)
	if not treeNode or not nShift then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end
	local parent = treeNode.parent
	if not parent then
		return
	end
	local tParentInfo = parent.tInfo
	if not tParentInfo then
		return
	end

	-- 找到當前節點的索引位置
	local nThisIndex = -1
	for i = 1, #tParentInfo.tChild do
		if tParentInfo.tChild[i] and tParentInfo.tChild[i].szName == tNodeInfo.szName then
			nThisIndex = i
			break
		end
	end
	if nThisIndex <= 0 then
		return
	end

	-- 計算新的索引位置
	local nNewIndex = math.min(math.max(nThisIndex + nShift, 1), #tParentInfo.tChild)
	if nThisIndex == nNewIndex then
		return
	end

	-- 交換所在位置和當前位置
	UIEditor.UndoScopeStart()
	tParentInfo.tChild[nThisIndex], tParentInfo.tChild[nNewIndex] = tParentInfo.tChild[nNewIndex], tParentInfo.tChild[nThisIndex]
	UIEditor.UndoScopeEnd(tParentInfo.szName)
end

-- 刪除一個節點
function UIEditor.DeleteTreeNode(treeNode)
	if not treeNode then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end
	local parent = treeNode.parent
	if not parent then
		return
	end
	local tParentInfo = parent.tInfo
	if not tParentInfo then
		return
	end

	-- 找到當前節點的索引位置
	local nThisIndex = -1
	for i = 1, #tParentInfo.tChild do
		if tParentInfo.tChild[i] and tParentInfo.tChild[i].szName == tNodeInfo.szName then
			nThisIndex = i
			break
		end
	end
	if nThisIndex <= 0 then
		return
	end

	UIEditor.UndoScopeStart()
	table.remove(tParentInfo.tChild, nThisIndex)
	UIEditor.UndoScopeEnd(tParentInfo.szName)
end

-- 拷貝節點
function UIEditor.CopyTreeNode(treeNode)
	if not treeNode then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end

	-- TODO: 這裡還有別的拷貝限制可能
	if tNodeInfo.szType == "Frame" then
		return
	end
	UIEditor.tCopyTableCache = UIEditor.CloneTable(tNodeInfo)
end

-- 為待複製的數據調整節點的層級數據和名字數據(新的層級, 不能重名)
function UIEditor.AdjustForPaste(tTab, nLevelDiff)
	if not tTab or not nLevelDiff then
		return
	end

	local tResult = {}
	for key, value in pairs(tTab) do
		if type(value) == "table" then
			tResult[key] = UIEditor.AdjustForPaste(value, nLevelDiff)
		else
			if key == "nLevel" then
				tResult[key] = value + nLevelDiff
			elseif key == "szName" then
				tResult[key] = UIEditor.CalculateNodeName(value)
			else
				tResult[key] = value
			end
		end
	end

	return tResult
end

function UIEditor.CheckPaste(tNodeInfo, szType)
	-- 這裡判斷是否能粘貼的指定位置
	--algo.print(tNodeInfo.szType,szType)
	if tNodeInfo.szType == "Frame" or tNodeInfo.szType:find("^Wnd") then
		if szType == "Handle" then
			if not tNodeInfo.tChild then
				return true
			end
			for i = 1, #tNodeInfo.tChild do
				if tNodeInfo.tChild[i].szType == "Handle" then
					return false
				end
			end
			return true
		elseif szType:match("^Wnd") then
			return true
		end
	elseif tNodeInfo.szType == "Handle" then
		if not szType:match("^Wnd") and szType~="Frame" then
			return true
		end
	end
	return false
end


-- 粘貼樹節點(調整層級和避免重名)
function UIEditor.PasteTreeNode(treeNode)
	if not treeNode then
		return
	end
	local tNodeInfo = treeNode.tInfo
	if not tNodeInfo then
		return
	end
	if not UIEditor.tCopyTableCache then
		return
	end

	-- 這裡判斷是否能粘貼的指定位置
	if not UIEditor.CheckPaste(tNodeInfo, UIEditor.tCopyTableCache.szType) then
		return
	end

	UIEditor.UndoScopeStart()
	--treeNode.child = treeNode.child or {}
	local tClone = UIEditor.CloneTable(UIEditor.tCopyTableCache)		-- 可能多次粘貼, 所以 Clone 避免污染之後可能的粘貼
	tClone = UIEditor.AdjustForPaste(tClone, tNodeInfo.nLevel - tClone.nLevel + 1)
	table.insert(tNodeInfo.tChild, tClone)
	UIEditor.UndoScopeEnd(treeNode.szName)
end

--OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\TreeNode.lua" 加载完成 ...]] .. "\n"))
