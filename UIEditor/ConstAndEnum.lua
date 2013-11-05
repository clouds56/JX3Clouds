--Output(pcall(dofile, "Interface\\UIEditor\\ConstAndEnum.lua"))
--OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\ConstAndEnum.lua" 开始加载 ...]] .. "\n"))

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
	"Handle",			-- 容器组件
	
	["Scene"] = {"WndFrame","WndScene","WndWindow"},
	["Window"] = {"WndWindow","WndFrame"},
	["WndCommon"] = {"WndFrame","WndWindow","WndButton","WndCheckBox","WndEdit","WndPage","WndPageSet","WndScene","WndWebPage","WndMinimap","WndMovie"},
	["Button"] = {"WndButton","WndCheckBox"},
	["Edit"] = {"WndEdit","Text"},
	["Item"] = {"Handle","Null","Text","Image","Shadow","Animate","Box","TreeLeaf"},

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

local fnimagepath	=	{function(s)return s and s..".UITex" or "" end,function(s)return s and s:sub(1,-7) end}
local fnimagetype	=	{function(s)return s and UIEditor.tImageTypes[s] or 0 end,function(n)return UIEditor.tImageTypes[n+1]end}
local fnhaligntype	=	{function(s)return s and UIEditor.tTextHAlignTypes[s] or 0 end,function(n)return n and UIEditor.tTextHAlignTypes[n+1] end}
local fnvaligntype	=	{function(s)return s and UIEditor.tTextVAlignTypes[s] or 0 end,function(n)return n and UIEditor.tTextVAlignTypes[n+1] end}
local fnbooltobin	=	{function(b)return b and 1 or 0 end,function(n)return n and n~=0 and true or false end}
local fnnbooltobin	=	{function(b)return b and 0 or 1 end,function(n)return not(n and n~=0 and true or false) end}

UIEditor.tNodeInfoDefault = {
	--Option means write if non nil
	--Nonzero means write if non zero or empty string
	--Important(Default) means if nil write default
	--
	--the mode is ((Common|Tip|Window.etc|WndFrame.etc|Item|Handle.etc)(Option(no case)|Nonzero|Important|Default)?)(|\1)+
	--
	--[[Manual
	{"._WndType",	"Common",	"sz_WndType",	""},	-- string : szItemType
	{"._Parent",	"Common",	"sz_Parent",	""},	-- string : szNext
	{"._Comment",   "CommonNonzero",        "szComment",    nil},   ---
	--]]

	--Only Common's default is Important
	{"Left",		"Common",			"nLeft",		0},		---
	{"Top",			"Common",			"nTop",			0},		---
	{"Width",		"Common",			"nWidth",		0},		---
	{"Height",		"Common",			"nHeight",		0},		---

	--Tip is special, if szTip is set ALL 4 properties should be written
	--otherwise none
{"$Tip",		"Tip",		"szTip",		nil},			---
{"TipRichText",	"Tip",		"nTipRichText",	0},				--- Integer : &nValue1
{"OrgTip",		"Tip",		"nOrgTip",		1},				---TODO
{"ShowTipType",	"Tip",		"nShowTipType",	0},				---TODO

	--TODO: Frame list(but it seems no sense?)
	--"Scene" means WndFrame|WndScene|WndWindow
{"DragAreaLeft",		"SceneDefault",		"nDragAreaLeft",		0},			--TODO
{"DragAreaTop",			"SceneDefault",		"nDragAreaTop",			0},			--TODO
{"DragAreaWidth",		"WindowDefault",	"nDragAreaWidth",		0},			--TODO
{"DragAreaHeight",		"WindowDefault",	"nDragAreaHeight",		0},			--TODO
{"AnimateStartPosX",	"SceneDefault",		"nAnimateStartPosX",	0},			--TODO
{"AnimateStartPosY",	"SceneDefault",		"nAnimateStartPosY",	0},			--TODO
{"AnimateEndPosX",		"SceneDefault",		"nAnimateEndPosX",		0},			--TODO
{"AnimateEndPosY",		"SceneDefault",		"nAnimateEndPosY",		0},			--TODO
{"AnimateTimeSpace",	"SceneDefault",		"nAnimateTimeSpace",	0},			--TODO
{"AnimateMoveSpeed",	"SceneDefault",		"nAnimateMoveSpeed",	0},			--TODO

	--Following properties is Option
	{"ScriptFile",		"WindowNonzero",		"szScriptFile",		nil},	-- string : 

	--vim:set ts=4 sw=4
	--"Window" means WndWindow|WndFrame
	{"IsCustomDragable",		"Window",		"bIsCustomDragable",		0},	-- bool : 
	{"DragAreaRight",			"Scene",		"szuDragAreaRight",			""},	-- unknown : 
	{"DragAreaBottom",			"Scene",		"szuDragAreaBottom",		""},	-- unknown : 
	{"MinWidth",				"Scene",		"nMinWidth",				0},	-- unknown : 
	{"MinHeight",				"Scene",		"nMinHeight",				0},	-- unknown : 
	{"MaxWidth",				"Scene",		"nMaxWidth",				0},	-- unknown : 
	{"MaxHeight",				"Scene",		"nMaxHeight",				0},	-- unknown : 
	{"DisableBringToTop",		"Window|WndButton",	"bDisableBringToTop",	0},	-- unknown : 
	--"WndCommon" means WndFrame|WndWindow|WndButton|WndCheckBox|WndEdit|WndPage|WndPageSet|WndScene|WndWebPage|WndMinimap|WndMovie
	{"DummyWnd",			"WndCommon|WndNewScrollBar",	"bDummyWnd",	0},	-- unknown : 
	{"Moveable",			"WndCommon|WndNewScrollBar",	"bMoveable",	0},	-- unknown : 
	{"DisableBreath",			"Window",		"bDisableBreath",			0},	-- unknown : 
	{"MousePenetrable",			"Scene|WndButton",	"szuMousePenetrable",	""},	-- unknown : 

	{"ItemHandle",				"WndFrame",	"szuItemHandle",			""},	-- unknown : 
	{"MultiFrame",				"WndFrame",	"szuMultiFrame",			""},	-- unknown : 
	{"ClassName",				"WndFrame",	"szuClassName",				""},	-- unknown : 
	{"RenderSampling",			"WndFrame",	"szuRenderSampling",		""},	-- unknown : 
	{"BreatheWhenHide",			"WndFrame",	"bBreatheWhenHide",			0},	-- unknown : 
	{"SelfHoldMouseHover",		"WndFrame",	"szuSelfHoldMouseHover",	""},	-- unknown : 
	{"AreaByEventItem",			"WndFrame",	"szuAreaByEventItem",		""},	-- unknown : 
	{"RenderEvent",				"WndFrame",	"szuRenderEvent",			""},	-- unknown : 
	{"ShowWhenHideUI",			"WndFrame",	"bShowWhenHideUI",			0},	-- unknown : 
	--Except NewScrollBar
	{"FollowMove",				"WndCommon",	"szuFollowMove",		""},	-- unknown : 
	{"FollowSize",				"WndCommon",	"szuFollowSize",		""},	-- unknown : 

	{"EnableTabChangeFocus",	"Window",	"bEnableTabChangeFocus",	0},	-- unknown : 
	{"MouseFollowFocus",		"Window",	"szuMouseFollowFocus",		""},	-- unknown : 
	{"ItemCount",				"Window",	"nItemCount",				0},	-- unknown : 
	{"Item_0",					"Window",	"szuItem_0",				""},	-- unknown : 
	{"Item_1",					"Window",	"szuItem_1",				""},	-- unknown : 
	{"Item_2",					"Window",	"szuItem_2",				""},	-- unknown : 

	{"AreaFile",				"WndFrame",	"szAreaFile",				nil},	-- String : szBuffer

	--Button means WndButton|WndCheckBox
	{"Trans",		"Button|WndPageSet|WndMovie",	"szuTrans",			""},	-- unknown : 	87
	--Button,CheckBox,Page,Movie
{"Image",		"ButtonNonzero|PageNonzero",					"szImage",	nil,		fnimagepath},	--- String : szImagePath	88
{"Frame",		"Button|WndPage|WndPageSet|WndScene|WndMovie",	"nFrame",	0},	-- Integer : &nValue	89
	{"GrayColor",	"Button|WndMovie",				"szuGrayColor",			""},	-- unknown : 	90

	--WndButton and WndCheckBox
	{"Up",				"Button",		"szuUp",				""},	-- unknown : 	91
	{"Down",			"Button",		"szuDown",				""},	-- unknown : 	92
	{"DisableFrame",	"Button",		"nDisableFrame",		-1},	-- Integer : &nValue	93
	{"NoOverSound",		"Button",		"szuNoOverSound",		""},	-- unknown : 	94
	{"Over",			"Button",		"szuOver",				""},	-- unknown : 	95
	{"OverFrame",		"Button",		"szuOverFrame",			""},	-- unknown : 	96
	{"CheckBox",		"WndButton",	"szuCheckBox",			""},	-- unknown : 	97
	{"CheckOver",		"Button",		"szuCheckOver",			""},	-- unknown : 	98
	{"SendHoldMsg",		"Button",		"szuSendHoldMsg",		""},	-- unknown : 	99
	{"NormalGroup",		"Button",		"szuNormalGroup",		""},	-- unknown : 	100
	{"MouseOverGroup",	"Button",		"szuMouseOverGroup",	""},	-- unknown : 	101
	{"MouseDownGroup",	"Button",		"szuMouseDownGroup",	""},	-- unknown : 	102
	{"DisableGroup",	"Button",		"szuDisableGroup",		""},	-- unknown : 	103
	{"MouseOverFont",	"Button",		"szuMouseOverFont",		""},	-- unknown : 	106
	{"MouseDownFont",	"Button",		"szuMouseDownFont",		""},	-- unknown : 	107
	{"DisableFont",		"Button",		"szuDisableFont",		""},	-- unknown : 	108
	--WndButtonOnly
	{"ButtonDisable",	"WndButton",	"szuButtonDisable",		""},	-- unknown : 	104
	{"NormalFont",		"WndButton",	"szuNormalFont",		""},	-- unknown : 	105
	--WndCheckBox
	--Following 8 Orz
	{"UnCheckAndEnable",	"WndCheckBox",	"bUnCheckAndEnable",	0},	-- unknown : 	112
	{"CheckAndEnable",		"WndCheckBox",	"bCheckAndEnable",		0},	-- unknown : 	113
	{"UnCheckAndDisable",	"WndCheckBox",	"bUnCheckAndDisable",	0},	-- unknown : 	114
	{"CheckAndDisable",		"WndCheckBox",	"bCheckAndDisable",		0},	-- unknown : 	115
	{"UnCheckedAndEnableWhenMouseOver",		"WndCheckBox",	"bUnCheckedAndEnableWhenMouseOver",	0},	-- unknown : 	116
	{"CheckedAndEnableWhenMouseOver",		"WndCheckBox",	"bCheckedAndEnableWhenMouseOver",	0},	-- unknown : 	117
	{"CheckedAndDisableWhenMouseOver"	,	"WndCheckBox",	"bCheckedAndDisableWhenMouseOver",	0},	-- unknown : 	118
	{"UnCheckedAndDisableWhenMouseOver",	"WndCheckBox",	"bUnCheckedAndDisableWhenMouseOver",	0},	-- unknown : 	119
	{"Checking",			"WndCheckBox",	"szuChecking",			""},	-- unknown : 	120
	{"UnChecking",			"WndCheckBox",	"szuUnChecking",		""},	-- unknown : 	121
	{"RadioButton",			"WndCheckBox",	"szuRadioButton",		""},	-- unknown : 	123
	{"UncheckFont",			"WndCheckBox",	"szuUncheckFont",		""},	-- unknown : 	124
	{"CheckFont",			"WndCheckBox",	"szuCheckFont",			""},	-- unknown : 	125
	{"DisableCheck",		"WndCheckBox",	"szuDisableCheck",		""},	-- unknown : 	130
	{"CheckedWhenCreate",	"WndCheckBox",	"szuCheckedWhenCreate",	""},	-- unknown : 	131


	--Edit means WndEdit|Text
	{"MultiLine",			"Edit",		"bMultiLine",			0},	-- bool : &nValue	153
	{"FontScheme",			"Edit",		"nFontScheme",			0},	-- number : &nValue	158
	{"RowSpacing",			"Edit",		"nRowSpacing",			0},	-- number : &nValue	162
	{"FontSpacing",			"Edit",		"nFontSpacing",			0},	-- number : &nValue	163
	{"$Text",				"Edit",		"szText",				""},	-- string : szText	168
	{"HAlign",				"Edit",		"nHAlign",				0,		fnhaligntype},	-- number : &nValue	170
	{"VAlign",				"Edit",		"nVAlign",				0,		fnvaligntype},	-- number : &nValue	171
	{"Alpha",				"Edit",		"nAlpha",				255},	-- number : &nValue	167
	{"Password",			"WndEdit",	"szuPassword",			""},	-- unknown : 	154
	{"Type",				"WndEdit",	"szuType",				""},	-- unknown : 	155
	{"TextLength",			"WndEdit",	"szuTextLength",		""},	-- unknown : 	156
	{"MaxLen",				"WndEdit",	"szuMaxLen",			""},	-- unknown : 	157
	{"FocusBgColor",		"WndEdit",	"szuFocusBgColor",		""},	-- unknown : 	159
	{"FocusBgColorAlpha",	"WndEdit",	"szuFocusBgColorAlpha",	""},	-- unknown : 	160
	{"SelectBgColorAlpha",	"WndEdit",	"szuSelectBgColorAlpha",	""},	-- unknown : 	161
	{"SelFontScheme",		"WndEdit",	"szuSelFontScheme",		""},	-- unknown : 	164
	{"CaretFontScheme",		"WndEdit",	"szuCaretFontScheme",	""},	-- unknown : 	165
	{"SelectBgColor",		"WndEdit",	"szuSelectBgColor",		""},	-- unknown : 	166
	{"PosType",				"WndEdit",	"nPosType",				0},	-- number : &nValue	169

	--WndPageSet
	{"PageCount",	"WndPageSet",	"nPageCount",		0},	-- unknown : 	183
	{"Page_0",		"WndPageSet",	"szuPage_0",		""},	-- unknown : 	184
	{"CheckBox_0",	"WndPageSet",	"szuCheckBox_0",	""},	-- unknown : 	185
	{"Page_1",		"WndPageSet",	"szuPage_1",		""},	-- unknown : 	186
	{"CheckBox_1",	"WndPageSet",	"szuCheckBox_1",	""},	-- unknown : 	187
	{"Page_2",		"WndPageSet",	"szuPage_2",		""},	-- unknown : 	188
	{"CheckBox_2",	"WndPageSet",	"szuCheckBox_2",	""},	-- unknown : 	189
	{"Page_3",		"WndPageSet",	"szuPage_3",		""},	-- unknown : 	191
	{"CheckBox_3",	"WndPageSet",	"szuCheckBox_3",	""},	-- unknown : 	192
	{"Page_4",		"WndPageSet",	"szuPage_4",		""},	-- unknown : 	193
	{"CheckBox_4",	"WndPageSet",	"szuCheckBox_4",	""},	-- unknown : 	194
	{"Page_5",		"WndPageSet",	"szuPage_5",		""},	-- unknown : 	195
	{"CheckBox_5",	"WndPageSet",	"szuCheckBox_5",	""},	-- unknown : 	196

	--Movie means WndMovie|WndScene
	{"Alpha",					"WndScene",	"nAlpha",				255},	-- number : &nValue	198
	{"PosType",					"WndScene",	"nPosType",				0},	-- number : &nValue	199
	{"EnableFrameMove",			"WndScene",	"szuEnableFrameMove",	""},	-- unknown : 	200
	{"DisableRenderTerrain",	"Movie",	"szuDisableRenderTerrain",	""},	-- unknown : 	245
	{"DisableRenderSkyBox",		"Movie",	"szuDisableRenderSkyBox",	""},	-- unknown : 	246
	{"EnableAlpha",				"Movie",	"nEnableAlpha",			0},	-- Integer : &nValue	247

	--WndWebPage
	{"$URL",		"WndWebPage",		"szURL",		""},	-- unknown : 	227

	--WndMiniMap
	{"MinimapType",		"WndMinimap",	"szuMinimapType",		""},	-- unknown : 	232
	{"image",			"WndMinimap",	"szuimage",				""},	-- unknown : 	233
	{"selfframe",		"WndMinimap",	"szuselfframe",			""},	-- unknown : 	234
	{"defaulttexture",	"WndMinimap",	"szudefaulttexture",	""},	-- unknown : 	235
	{"sharptexture",	"WndMinimap",	"szusharptexture",		""},	-- unknown : 	236

	--NewScrollBar(export from old jx3 source code)
	{"StepCount",				"WndNewScrollBar",	"szuStepCount",			""},	-- unknown : 	248
	{"PageStepCount",			"WndNewScrollBar",	"szuPageStepCount",		""},	-- unknown : 	249
	{"Type",					"WndNewScrollBar",	"szuType",				""},	-- unknown : 	250
	{"SlideBtn",				"WndNewScrollBar",	"szuSlideBtn",			""},	-- unknown : 	251
	{"AutoHideSlideButton",		"WndNewScrollBar",	"szuAutoHideSlideButton",	""},	-- unknown : 	252
	{"AutoResizeSlideButton",	"WndNewScrollBar",	"szuAutoResizeSlideButton",	""},	-- unknown : 	253


	------------------------------------------
	--seperate between Wnd and Item
	------------------------------------------

	--TODO: change(meanings?)
	--Handle|TreeLeaf
{"HandleType",			"Handle|TreeLeaf",	"nHandleType",			0},	-- number : &nValue	11
{"FirstItemPosType",	"Handle|TreeLeaf",	"nFirstItemPosType",	0},	-- number : &nValue	12
	--Item means Handle|Null|Text|Image|Shadow|Animate|Box|TreeLeaf
{"PosType",				"ItemDefault|Null|Scene",	"nPosType",				0},

{"EventID",		"ItemNonzero",	"nEventID",		0},
{"RowSpacing",	"Handle",		"nRowSpacing",	0},	-- Integer : &nValue	15
{"PixelScroll",	"Handle",		"nPixelScroll",	0},	-- Integer : &nValue	16
	{"ControlShow",		"Handle",	"nControlShow",			0},	-- Integer : &nValue	17
	{"MousePenetrable",	"Handle",	"szuMousePenetrable",	""},	-- unknown : 	19
	{"IntPos",			"Handle",	"nIntPos",				0},	-- Integer : &nValue	20
	{"MinRowHeight",	"Handle",	"nMinRowHeight",		0},	-- Integer : &nValue	27
	{"AreaFile",		"Handle",	"szAreaFile",			""},	-- String : szBuffer	28
	--Execpt TreeLeaf
	{"LockShowAndHide",	"Item",	"nLockShowAndHide",	0},	-- Integer : &nValue	18

	{"IconImage",			"Handle|TreeLeaf",	"szIconImage",		""},	-- String : OutData.szImageName	21
	{"ExpandIconFrame",		"Handle|TreeLeaf",	"nExpandIconFrame",	-1},	-- Integer : &nValue	22
	{"CollapseIconFrame",	"Handle|TreeLeaf",	"nCollapseIconFrame",	-1},	-- Integer : &nValue	23
	{"IndentWidth",			"Handle|TreeLeaf",	"nIndentWidth",		0},	-- Integer : &nValue	24
	{"Indent",				"Handle|TreeLeaf",	"nIndent",			0},	-- Integer : &nValue	25
	{"LineColor",			"Handle|TreeLeaf",	"szLineColor",		""},	-- String : szColor	26
	
	--TreeLeaf
	{"IconWidth",	"TreeLeaf",	"nIconWidth",	0},	-- Integer : &nValue	84
	{"IconHeight",	"TreeLeaf",	"nIconHeight",	0},	-- Integer : &nValue	85
	{"ShowLine",	"TreeLeaf",	"nShowLine",	1},	-- Integer : &nValue	86
	{"AlwaysNode",	"TreeLeaf",	"nAlwaysNode",	0},	-- Integer : &nValue	89

	--Text
{"ShowAll",		"Text",	"bShowAll",	1},	-- bool : &nValue	39
{"AutoEtc",		"Text",	"bAutoEtc",	0},	-- bool : &nValue	40
{"OrgText",		"Text",	"nOrgText",	0},	-- number : &nValue	43
{"MlAutoAdj",	"Text",	"bMlAutoAdj",	0},	-- bool : &nValue	45
	{"CenterEachRow",	"Text",	"nCenterEachRow",	0},	-- Integer : &nValue	46
{"RichText",	"Text",	"bRichText",	1,		fnnbooltobin},	-- bool : &nValue	47
	{"DisableScale",	"Text",	"bDisableScale",	0},	-- Integer : &nValue	48
	{"Al",	"Text",	"szuAl",	""},	-- unknown : 	49

	--{"Alpha",		"CommonNonZero",	"nAlpha",		0},
	--{"Image",		"CommonNonZero",	"szImagePath",	nil,	fnimagepath,	fnrimagepath},--TODO: Btn and others
	--{"Frame",		"Common",		"nFrame",		0},--TODO: Btn and others
	--{"Group",		"Common",		"nAniGroup",	-1},
	--{"ImageType",	"CommonNonZero",	"szImageType",	0,	fnimagetype,	fnrimagetype},

{"Image",		"ImageNonzero",	"szImage",		nil,	fnimagepath},	-- String : szImagePath	50
{"Frame",		"Image",			"nFrame",		0},	-- Integer : &nValue	51
{"Alpha",		"Image",			"nAlpha",		255},	-- number : &nValue	52
{"ImageType",	"Image",			"nImageType",	0,	fnimagetype},	-- number : &nValue	55
	{"DisableScale",	"Image",	"bDisableScale",	0},	-- Integer : &nValue	57
	{"IntPos",			"Image",	"nIntPos",			0},	-- Integer : &nValue	58


	{"ShadowColor",	"Shadow",	"szShadowColor",	""},	-- String : szColor	59
{"Alpha",	"Shadow",	"nAlpha",	255},	-- number : &nValue	60
	{"ShadowAlpha",	"Shadow",	"szuShadowAlpha",	""},	-- unknown : 	62
{"Image",	"AnimateNonzero",	"szImage",	"",		fnimagepath},	-- String : szImagePath	65
{"Group",	"Animate",			"nGroup",	0},	-- Integer : &nValue	66
	{"LoopCount",	"Animate",	"nLoopCount",	0},	-- Integer : &nValue	67

	{"Index",		"Box",	"nIndex",			-1},	-- Integer : &nValue	71
	{"EventName",	"Box",	"szuEventName",		""},	-- unknown : 	74


	-- Usually we use the following properties
	--
	--._WndType				Common
	--._Parent				Common
	--Left					Common
	--Top					Common
	--Width					Common
	--Height				Common
	--
	--$Tip					Tip
	--
	--ScriptFile			Window
	--IsCustomDragable		Window
	--DisableBringToTop		Window|WndButton
	--DummyWnd				WndCommon|WndNewScrollBar
	--Moveable				WndCommon|WndNewScrollBar
	--DisableBreath			Window
	--MousePenetrable		Scene|WndButton
	--ShowWhenHideUI		WndFrame
	--
	--Image					Button|Page|Image|Animate
	--Frame					Button|WndPage|WndPageSet|WndScene|WndMovie|Image
	--Group					Animate
	--
	--MultiLine				Edit
	--FontScheme			Edit
	--RowSpacing			Edit|Handle
	--FontSpacing			Edit
	--$Text					Edit
	--HAlign				Edit
	--VAlign				Edit
	--Alpha					Edit|WndScene|Image|Shadow
	--PosType				WndEdit|WndScene
	--$URL					WndWebPage
	--
	--HandleType			Handle|TreeLeaf
	--FirstItemPosType		Handle|TreeLeaf
	--PosType				Item|Null|Scene|WndEdit|WndScene
	--EventID				Item
	--
	--ImageType				Image
	--ShadowColor			Shadow

}

--OutputMessage("MSG_SYS", "[UIEditor] " .. tostring([["Interface\UIEditor\ConstAndEnum.lua" 加载完成 ...]] .. "\n"))
