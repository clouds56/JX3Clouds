--Output(pcall(dofile, "Interface\\UIEditor\\ConstAndEnum.lua"))
OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\ConstAndEnum.lua" 开始加载 ...]] .. "\n"))

UIEditor = UIEditor or {}

---------------------------------------------------------------------------------------------------------------
-- 通常數據定義
---------------------------------------------------------------------------------------------------------------
UIEditor.szINIPath = "Interface\\UIEditor\\UIEditor.ini"			-- INI 位置
UIEditor.nTreeUndoLimited = 9999									-- 可撤銷次數

---------------------------------------------------------------------------------------------------------------
-- 各種數據表
---------------------------------------------------------------------------------------------------------------
UIEditor.tEventIndex = {											-- 事件定義和 bit 映射表
	KeyDown = 13,
	KeyUp = 14,
	
	MouseLDown = 1,
	MouseLUp = 3,
	MouseLClick = 5,
	MouseLDBClick = 7,
	MouseLDrag = 20,
	
	MouseRDown = 2,
	MouseRUp = 4,
	MouseRClick = 6,
	MouseRDBClick = 8,
	MouseRDrag = 19,
	
	MouseMDown = 15,
	MouseMUp = 16,
	MouseMClick = 17,
	MouseMDBClick = 18,
	MouseMDrag = 21,
	
	MouseEnterLeave = 9,
	MouseArea = 10,
	MouseMove = 11,
	MouseHover = 22,
	MouseScroll = 12,
}

UIEditor.tWindowLayers = {											-- 窗體 Layer 表
	"Lowest",
	"Lowest1",
	"Lowest2",
	"Normal",
	"Normal1",
	"Normal2",
	"Topmost",
	"Topmost1",
	"Topmost2",
	"Texture",
}

UIEditor.tTreeNodeTypes = {											-- 窗體 Type 表
	"Frame",			-- 主窗体
	
	"WndWindow",		-- 虚窗口
	"WndScrollBar",		-- 滚动条
	"WndButton",		-- 按钮
	"WndCheckBox",		-- 复选框
	"WndEdit",			-- 输入框
	"WndPage",			-- 标签页面
	"WndPageSet",		-- 标签页面集
	"WndMiniMap",		-- 小地图
	"WndScene",			-- 3D场景
	"WndWebPage",		-- 内嵌网页

	"Null",				-- 空组件
	"Text",				-- 文本组件
	"Image",			-- 图片组件
	"Shadow",			-- 阴影组件
	"Animate",			-- 动画组件
	"Box",				-- 格子组件
	"Scene",			-- 场景组件
	"TreeLeaf",			-- 树节点组件
	"Handle"			-- 容器组件
}

UIEditor.tImageTypes = {											-- 圖片 Type 表
	"一般圖像", "百分比：左右", "百分比：右左", "百分比：上下", "百分比：下上", "百分比：轉圈",
	"可旋轉圖像", "上下翻轉圖像", "左右翻轉圖像", "對角翻轉圖像", "九宮圖像", "左中右三宮", "上中下三宮", 

	["一般圖像"] = 0,
	["百分比：左右"] = 1,
	["百分比：右左"] = 2,
	["百分比：上下"] = 3,
	["百分比：下上"] = 4,
	["百分比：轉圈"] = 5,
	["可旋轉圖像"] = 6,
	["上下翻轉圖像"] = 7,
	["左右翻轉圖像"] = 8,
	["對角翻轉圖像"] = 9,
	["九宮圖像"] = 10,
	["左中右三宮"] = 11,
	["上中下三宮"] = 12,
}

UIEditor.tTextHAlignTypes = {										-- 文本水平對齊 Type 表
	"水平左對齊", "水平居中", "水平右對齊", 

	["水平左對齊"] = 0,
	["水平居中"] = 1,
	["水平右對齊"] = 2,
}

UIEditor.tTextVAlignTypes = {										-- 文本垂直對齊 Type 表
	"垂直上對齊", "垂直居中", "垂直下對齊", 

	["垂直上對齊"] = 0,
	["垂直居中"] = 1,
	["垂直下對齊"] = 2,
}

UIEditor.tImageTXTTitle = {											-- 图片文件帧信息表的表头名字
	{f = "i", t = "Farme"},				-- 图片帧 ID
	{f = "i", t = "Left"},				-- 帧位置: 距离左侧像素(X位置)
	{f = "i", t = "Top"},				-- 帧位置: 距离顶端像素(Y位置)
	{f = "i", t = "Width"},				-- 帧宽度
	{f = "i", t = "High"},				-- 帧高度
	{f = "s", t = "File"},				-- 帧来源文件(无作用)
}

UIEditor.szColorFileName = "Interface/UIEditor/Misc/Color.txt"
UIEditor.tColorTXTTitle = {											-- 顏色文件帧信息表的表头名字
	{f = "i", t = "index"},				-- 顏色索引
	{f = "s", t = "name"},				-- 顏色名字
	{f = "i", t = "r"},					-- 顏色 R 值
	{f = "i", t = "g"},					-- 顏色 G 值
	{f = "i", t = "b"},					-- 顏色 B 值
}

UIEditor.tImageFileBaseNameList = {									-- 图片文件列表, 目前暂时只支持手动维护此表
	Button = {
		"UI/Image/Button/CommonButton_1",
		"UI/Image/Button/FrendnpartyButton",
		"UI/Image/Button/ShopButton",
		"UI/Image/Button/SystemButton",
		"UI/Image/Button/SystemButton_1",
	},
	
	ChannelsPanel = {
		"UI/Image/ChannelsPanel/b",
		"UI/Image/ChannelsPanel/Button",
		"UI/Image/ChannelsPanel/Channels1",
		"UI/Image/ChannelsPanel/Channels2",
		"UI/Image/ChannelsPanel/Channels3",
		"UI/Image/ChannelsPanel/Channels4",
		"UI/Image/ChannelsPanel/Channels5",
		"UI/Image/ChannelsPanel/Channels6",
		"UI/Image/ChannelsPanel/Channels7",
		"UI/Image/ChannelsPanel/Channels8",
		"UI/Image/ChannelsPanel/Channels9",
		"UI/Image/ChannelsPanel/NewChannels",
		"UI/Image/ChannelsPanel/NewChannels2",
	},
	
	Common = {
		"UI/Image/Common/Animate",
		"UI/Image/Common/Box",
		"UI/Image/Common/CommonPanel",
		"UI/Image/Common/CoverShadow",
		"UI/Image/Common/DialogueLabel",
		"UI/Image/Common/KeynotesPanel",
		"UI/Image/Common/Logo",
		"UI/Image/Common/Mainpanel_1",
		"UI/Image/Common/MatrixAni",
		"UI/Image/Common/MatrixAni_1",
		"UI/Image/Common/MatrixAni_2",
		"UI/Image/Common/Money",
		"UI/Image/Common/ProgressBar",
		"UI/Image/Common/TempBox",
		"UI/Image/Common/TextShadow",
	},
	
	Minimap = {
		"UI/Image/Minimap/Mapmark",
		"UI/Image/Minimap/Minimap",
		"UI/Image/Minimap/Minimap2",
	},
	
	QuestPanel = {
		"UI/Image/QuestPanel/QuestPanel",
		"UI/Image/QuestPanel/QuestPanelButton",
		"UI/Image/QuestPanel/QuestPanelPart",
	},
	
	TargetPanel = {
		"UI/Image/TargetPanel/CangjianAnimation1",
		"UI/Image/TargetPanel/CangjianAnimation2",
		"UI/Image/TargetPanel/Player",
		"UI/Image/TargetPanel/Target",
	},
	
	UICommon = {
		"UI/Image/UICommon/Commonpanel",
		"UI/Image/UICommon/Commonpanel2",
		"UI/Image/UICommon/Commonpanel4",
		"UI/Image/UICommon/Commonpanel5",
		"UI/Image/UICommon/CompassPanel",
		"UI/Image/UICommon/FEPanel",
		"UI/Image/UICommon/FEPanel3",
		"UI/Image/UICommon/HelpPanel",
		"UI/Image/UICommon/LoginCommon",
		"UI/Image/UICommon/LoginSchool",
		"UI/Image/UICommon/MailCommon",
		"UI/Image/UICommon/PasswordPanel",
		"UI/Image/UICommon/ScienceTreeNode",
		"UI/Image/UICommon/Talk_Face",
	},
	
	Misc = {
		"UI/Image/ChatPanel/EditBox",
		"UI/Image/Cursor/Arrowimg",
		"UI/Image/Helper/Help",
		"UI/Image/Helper/Help—bg",
		"UI/Image/Item_Pic/266",
		"UI/Image/Login/CharButton",
		"UI/Image/LootPanel/LootPanel",
		"UI/Image/MiddleMap/MapWindow",
		"UI/Image/QuicklySetPanel/QuicklySetPanel1",
	},
}

OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\ConstAndEnum.lua" 加载完成 ...]] .. "\n"))