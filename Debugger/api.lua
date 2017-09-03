-- Basic
local me = GetClientPlayer(); -- UI_GetClientPlayerID
local id = GetControlPlayerID(); -- 平沙?

-- Skill
local school = me.GetSchoolList();
--[[
{ 0, 10: "唐门" }
]]
local skill_list = me.GetAllSkillList();
--[[
{ 10082: "江湖轻功", 10083: "外功系", 10084: "内功系", 10165: "造化功", 10005: "防身武艺", 10066: "基础系", 10074: "辅助系", 10095: "混元气功", 10010: "基础招式", 10087: "先天功", 10125: "经脉畅行", },
{ 4104: "双人同骑", 605: "骑御", 11: "六合棍", 15: "连环双刀", 16: "判官笔法", 17: "打坐", 18: "踏云", 34: "虹气长空", 35: "传功", 608: "自绝经脉", 1795: "四季剑法", 3121: "罡风镖法", 4326: "大漠刀法", 13039: "卷雪刀", 12: "梅花枪法", 2183: "大荒笛法", 13: "三柴剑法", 14: "长拳", 9004: "迎风回浪", 9005: "凌霄揽胜", 9006: "瑶台枕鹤", 16010: "霜风刀法",},
{ 10224: "惊羽诀", 10218: "百步穿杨", 10219: "九宫飞星", 3095: "夺魄箭", 10225: "天罗诡道", 10226: "流星赶月阵", 10227: "千机百变阵", 10220: "天魔无相", },
{ 3089: "雷震子", 3090: "迷神钉", 3091: "毒蒺藜", 3094: "心无旁骛", 3098: "穿心弩", 3101: "逐星箭", 3103: "飞星遁影", 3109: "千机变", 3110: "鬼斧神工", 3111: "暗藏杀机", 3112: "浮光掠影", 3114: "惊鸿游龙", 3118: "鸟翔碧空", 3357: "图穷匕见", 3107: "鲲鹏铁爪", 3087: "化血镖", 3240: "飞星遁影", 3373: "弩箭制造", 3374: "机关制造",}
{ 599: "",   10230: "", 3210: "", 3212: "", },
{ 3211: "惊魄", 17588: "遁影",  17587: "遁影", 10216: "乾坤一掷", 3472: "踏月留香", 3216: "流星赶月阵", 3204: "穿杨", 3217: "千机百变阵", },
]]
me.GetKungfuList(10)
--[[
{
  10005: 1, -- "防身武艺" { 17: "打坐", 34: "虹气长空", 605: "骑御", 608: "自绝经脉", 3373: "弩箭制造", 3374: "机关制造", 4104: "双人同骑",
    11: "六合棍", 12: "梅花枪法", 13: "三柴剑法", 14: "长拳", 15: "连环双刀", 16: "判官笔法", 1795: "四季剑法", 2183: "大荒笛法", 3121: "罡风镖法", 4326: "大漠刀法", 13039: "卷雪刀", 16010: "霜风刀法", }
  10010: 1, -- "基础招式" {}
  10066: 1, -- "基础系" { 599: "" }
  10074: 1, -- "辅助系" {}
  10082: 1, -- "江湖轻功" {  18 "踏云", 81: "神行千里", 3465: "点墨山河", 3470: "飞鸢泛月", 9002: "扶摇直上", 9003: "蹑云逐月", 9004: "迎风回浪", 9005: "凌霄揽胜", 9006: "瑶台枕鹤", }
  10083: 1, -- "外功系" {}
  10084: 1, -- "内功系" {}
  10087: 1, -- "先天功" {}
  10095: 1, -- "混元气功" {}
  10125: 1, -- "经脉畅行" { 35: "传功" }
  10165: 1, -- "造化功" {}
}
{
  10230: 1, -- "" {}
  10219: 1, -- "九宫飞星" { 3106: "天女散花", 3107: "鲲鹏铁爪", 3108: "天绝地灭", 3109: "千机变", 3110: "鬼斧神工", 3111: "暗藏杀机", 3105: "蚀肌弹", 3357: "图穷匕见", }
  10225: 10, -- "天罗诡道" { 3211: "惊魄", 3212: "", }
  10227: 1, -- "千机百变阵" { 3217: "千机百变阵", }
  10216: 1, -- "乾坤一掷" { 3093: "暴雨梨花针", 3087: "化血镖", 3089: "雷震子", 3090: "迷神钉", 3091: "毒蒺藜", }
  10218: 1, -- "百步穿杨" { 3101: "逐星箭", 3095: "夺魄箭", 3096: "追命箭", 3097: "裂石弩", 3098: "穿心弩", },
  10220: 1, -- "天魔无相" { 3114: "惊鸿游龙", 3094: "心无旁骛", 3103: "飞星遁影", 3118: "鸟翔碧空",3112: "浮光掠影", },
  10224: 10, -- "惊羽诀" { 3204: "穿杨, 3210: "", }
  10226: 1, -- "流星赶月阵" { 3216: "流星赶月阵" }
}
]]
local other_api = { -Table_GetSkillSortOrder(dwID, dwLevel), Table_GetSkillIconID(dwID, dwLevel), };
player.GetCommonSkill(bMelee) -- true: 3121, false: 0

-- UI
local box_actionbar = Station.Lookup("Lowest/ActionBar"..nGroupID, "Handle_Box/"..nIndex) -- ActionBar
local dwType, nData1, nData2, nData3, nData4, nData5, nData6 = boxHand:GetObject();
--[[
{ skill(5), skill_id, skill_level, 0, 1, -1, -1 }
{ -1,-1,-1,-1,-1,-1,-1 }
]]
box:SetObject(dwType, nData1, nData2, nData3, nData4, nData5, nData6)
SetActionBarData(box)
box:SetObjectIcon(nIconID)
ActionBar.UpdateBoxNum(box, "")

boxHand:SetUserData(box:GetUserData())
boxHand:SetBoxIndex(box:GetBoxIndex())
boxHand:SetObject(box:GetObject())
boxHand:SetObjectIcon(box:GetObjectIcon())
boxHand.nCount = nCount
boxHand.bAction = bAction

box:SetObject(UI_OBJECT_SKILL, dwID, dwLevel)
box:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
Hand_Clear();

local dwID, dwLevel = 3114, 1
local boxHand = Station.Lookup("Lowest/Hand", "Box_Hand")
boxHand:SetObject(UI_OBJECT_SKILL, dwID, dwLevel, 0, 1)
boxHand:SetObjectIcon(Table_GetSkillIconID(dwID, dwLevel))
local box, _this = Station.Lookup("Lowest/ActionBar"..1, "Handle_Box/"..1), this
box.__bDragIn=true --??
this = box;box.OnItemLButtonDragEnd();this = _this
Hand_Clear()
box:GetObject()

-- System
local tMenu = {
  function()
    return {{
      szOption = "Hello",
      fnAction = function(...) out(...) --[[{nil, true}]] end,
      {
        szOption = "Sub1",
        fnDisable = function() return true end,
      },{ bDevide = true },{
        szOption = "checkbox",
        bCheck = true, bChecked = false,
        -- bMCheck = true
      }
    }}
  end,
}
local other_api = { TraceButton_AppendAddonMenu(tMenu), TraceButton_GetAddonMenu() }

-- Player

-- Event

-- MSG
local event = {
  ["SYS_MSG"] = function()
    local event = arg0
    if event == "UI_OME_SKILL_CAST_LOG" then OnSkillCast(arg1, arg2, arg3) --dwCaster, dwSkillID, dwLevel
    elseif event == "UI_OME_SKILL_CAST_RESPOND_LOG" then OnSkillCastRespond(arg1, arg2, arg3, arg4) --dwCaster, dwSkillID, dwLevel, nRespond
    elseif event == "UI_OME_SKILL_EFFECT_LOG" then OnSkillEffectLog(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) --dwCaster, dwTarget, bReact, nEffectType, dwID, dwLevel, bCriticalStrike, nCount, tResult
    elseif event == "UI_OME_SKILL_BLOCK_LOG" then OnSkillBlockLog(arg1, arg2, arg3, arg4, arg5, arg6) --dwCaster, dwTarget, nEffectType, dwID, dwLevel, dwDamageType
    elseif event == "UI_OME_SKILL_SHIELD_LOG" then OnSkillShieldLog(arg1, arg2, arg3, arg4, arg5) --dwCaster, dwTarget, nEffectType, dwID, dwLevel
    elseif event == "UI_OME_SKILL_MISS_LOG" then OnSkillMissLog(arg1, arg2, arg3, arg4, arg5) --dwCaster, dwTarget, nEffectType, dwID, dwLevel
    elseif event == "UI_OME_SKILL_HIT_LOG" then OnSkillHitLog(arg1, arg2, arg3, arg4, arg5) --dwCaster, dwTarget, nEffectType, dwID, dwLevel
    elseif event == "UI_OME_SKILL_DODGE_LOG" then OnSkillDodgeLog(arg1, arg2, arg3, arg4, arg5) --dwCaster, dwTarget, nEffectType, dwID, dwLevel
    elseif event == "UI_OME_COMMON_HEALTH_LOG" then OnCommonHealthLog(arg1, arg2) --dwTarget, nDeltaLife
    elseif event == "UI_OME_BUFF_LOG" then OnBuffLog(arg1, arg2, arg3, arg4, arg5) --dwTarget, bCanCancel, dwID, bAddOrDel, nLevel
    elseif event == "UI_OME_BUFF_IMMUNITY" then OnBuffImmunity(arg1, arg2, arg3, arg4) --dwTarget, bCanCancel, dwID, nLevel
    elseif event == "UI_OME_SKILL_RESPOND" then OnSkillRespond(arg1) --nRespondCode
    end
  end,
  ["DO_SKILL_CAST"] = function()
    OnDoSkillCast(arg0, arg1, arg2) --dwCaster, dwSkillID, dwLevel
  end
}

RegisterEvent("LOADING_ENDING", OnInit) -- first time

RegisterEvent('GAME_EXIT', OnExit)
RegisterEvent('PLAYER_EXIT_GAME', OnExit)
RegisterEvent('RELOAD_UI_ADDON_BEGIN', OnExit)
