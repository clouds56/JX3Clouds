local _L = Clouds_Flags.lang.L
local CreateAddon = EasyUI.CreateAddon

local _t
_t = {
  NAME = "ui",
  szIni = "interface/Clouds/Flags/ui.ini",
}

_t.module = Clouds_Flags
Clouds_Flags.ui = _t
_t.Output = Clouds_Flags.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end
_t.Output_ex = function(...) _t.Output(_t.module.LEVEL.VERBOSEEX, ...) end

_t.BattleLog = CreateAddon("Clouds_Flags_BattleLog")

_t.OnClickBattleType = function(self)

end

_t.BattleLogRegisterPrefix = function(self)
  self.OnItemLButtonDown = function()
    local hh, s = this:GetParent(), ""
    for i = 0, hh:GetItemCount() - 1 do
      s = s .. hh:Lookup(i):GetText()
    end
    out(s, this:GetTreePath())
  end
  -- out(self)
end

_t.BattleLogRegisterSkill = function(self, id, level)
  self.OnItemMouseEnter = function()
    local x, y = this:GetAbsPos()
    local w, h = this:GetSize()
    OutputSkillTip(id, level, {x, y, w, h})
  end
  self.OnItemMouseLeave = function()
    HideTip()
  end
end

_t.BattleLogRegisterBuff = function(self, id, level)
  self.OnItemMouseEnter = function()
    local x, y = this:GetAbsPos()
    local w, h = this:GetSize()
    OutputBuffTip(0, id, level, nil, nil, nil, {x, y, w, h})
  end
  self.OnItemMouseLeave = function()
    HideTip()
  end
end

_t.tostring_cache = {}

_t.SkillToString = function(skill)
  if _t.tostring_cache[skill] then
    return _t.tostring_cache[skill]
  end
  if skill.name and skill.name ~= "" and skill.name ~= "Unknown" then
    _t.tostring_cache[skill] = tostring(skill.name)
  elseif skill.level and skill.level ~= 0 then
    _t.tostring_cache[skill] = string.format("(%s,%s)", tostring(skill.id), tostring(skill.level))
  else
    _t.tostring_cache[skill] = string.format("(%s)", tostring(skill.id))
  end
  return _t.tostring_cache[skill]
end

_t.BuffToString = _t.SkillToString

_t.PlayerToString = function(player)
  if _t.tostring_cache[player] then
    return _t.tostring_cache[player]
  end
  local fmt = "%s"
  if player.type then
    fmt = "[%s]"
  end
  if player.name and player.name ~= "" and player.name ~= "Unknown" then
    _t.tostring_cache[player] = string.format(fmt, tostring(player.name))
  elseif player.force then
    _t.tostring_cache[player] = string.format(fmt, string.format("#(%d)", tostring(player.force)))
  else
    _t.tostring_cache[player] = string.format(fmt, string.format("#%d", tostring(player.id)))
  end
  return _t.tostring_cache[player]
end

_t.RenderBattleLog = function(tp, value)
  local ss = {}
  table.insert(ss, xv.api.GetFormatText(tp..": ", {0xFFFFFF,10}, 515,
    'Clouds_Flags.ui.BattleLogRegisterPrefix(this)', "type"))
  table.insert(ss, xv.api.GetFormatText(string.format("[%s] ", xv.algo.frame.tostring(value.time, 2)), 0xFFFF00))
  if tp == "skill" or tp == "buff" then
    table.insert(ss, xv.api.GetFormatText(_t.PlayerToString(value.dst), 0xFF8000))

    if value.act == _t.module.data.ACTION_TYPE.SKILL_EFFECT then
      table.insert(ss, xv.api.GetFormatText(" <= ", 0x808080))
    elseif value.act == _t.module.data.ACTION_TYPE.SKILL_LOG then
      table.insert(ss, xv.api.GetFormatText(" => ", 0xFFFFFF))
    elseif value.act == _t.module.data.ACTION_TYPE.SKILL_CASTED then
      table.insert(ss, xv.api.GetFormatText(" <= ", 0xFFFFFF))
    elseif not value.act then
      table.insert(ss, xv.api.GetFormatText(" : ", 0x808080))
    end

    if tp == "skill" then
      table.insert(ss, xv.api.GetFormatText(string.format("%s", _t.SkillToString(value.skill)), 0x00FFFF, 256,
        string.format('Clouds_Flags.ui.BattleLogRegisterSkill(this,%d,%d)', value.skill.id, value.skill.level), "skill"))
    elseif tp == "buff" then
      local act_string
      if value.act == _t.module.data.ACTION_TYPE.BUFF_ADD then
        act_string = xv.api.GetFormatText(" +++ ", value.buff.type~=false and 0x00FF00 or 0xFF0000)
      elseif value.act == _t.module.data.ACTION_TYPE.BUFF_REMOVE then
        act_string = xv.api.GetFormatText(" --- ", value.buff.type==false and 0x00FF00 or 0xFF0000)
      else
        table.insert(ss, xv.api.GetFormatText(" <= ", 0x808080))
      end
      if act_string then
        table.insert(ss, act_string)
      end
      table.insert(ss, xv.api.GetFormatText(string.format("%s", _t.BuffToString(value.buff)), value.buff.type ~= false and 0x00FF00 or 0xFF0000, 256,
        string.format('Clouds_Flags.ui.BattleLogRegisterBuff(this,%d,%d)', value.buff.id, value.buff.level), "buff"))
      if act_string then
        table.insert(ss, act_string)
      end
    end

    if value.damage and value.damage.therapy+value.damage.damage ~= 0 then
      table.insert(ss, xv.api.GetFormatText(" { ", 0x808080))
      if value.damage.damage ~= 0 then
        if value.oops then
          table.insert(ss, xv.api.GetFormatText("!!", 0xFF8000))
        end
        if value.damage.effective_damage ~= value.damage.damage then
          effective = string.format("(%s)", tostring(value.damage.effective_damage))
          table.insert(ss, xv.api.GetFormatText(string.format("%s", tostring(value.damage.damage)), 0x800000))
          table.insert(ss, xv.api.GetFormatText(string.format("(%s) ", tostring(value.damage.effective_damage)), value.damage.effective_damage==0 and 0xFFFFFF or 0xFF0000))
        else
          table.insert(ss, xv.api.GetFormatText(string.format("%s ", tostring(value.damage.damage)), 0xFF0000))
        end
      end
      if value.damage.therapy ~= 0 then
        if value.oops then
          table.insert(ss, xv.api.GetFormatText("!!", 0xFF8000))
        end
        if value.damage.effective_therapy ~= value.damage.therapy then
          table.insert(ss, xv.api.GetFormatText(string.format("%s", tostring(value.damage.therapy)), 0x008000))
          table.insert(ss, xv.api.GetFormatText(string.format("(%s) ", tostring(value.damage.effective_therapy)), value.damage.effective_therapy==0 and 0xFFFFFF or 0x00FF00))
        else
          table.insert(ss, xv.api.GetFormatText(string.format("%s ", tostring(value.damage.therapy)), 0x00FF00))
        end
      end
      table.insert(ss, xv.api.GetFormatText("}", 0x808080))
    end

    if value.act ~= _t.module.data.ACTION_TYPE.SKILL_LOG then
      table.insert(ss, xv.api.GetFormatText(" @", 0x808080))
      table.insert(ss, xv.api.GetFormatText(_t.PlayerToString(value.src), 0x0080FF))
    end
    -- table.insert(ss, xv.api.GetFormatText(string.format(" (%s)", _t.module.data.ACTION_TYPE.tostring(value.act))))
  end
  return ss
end

function _t.BattleLog:Init()
  local width = 480
  local frame = self:CreateMainFrame({title = _L("BattleLogTitle"), style = "NORMAL"})

  local window = self:Append("Window", frame, "WindowMain", {x = 0,y = 50,w = 768,h = 400})
  local btnRefresh = self:Append("Button", window, "ButtonRefresh", {x = 50, y = 20, w = 200, h = 30, text = _L("Refresh")})
  local scroll2 = self:Append("Scroll", window, "ScrollTest", {x = 50,y = 50,w = width+20,h = 350})
  btnRefresh.OnClick = function()
    scroll2:GetHandle():Clear()
    for i, t, v in _t.module.data.iter_compat(_t.module.data._compat) do
      local h = self:Append("Handle", scroll2, "h"..i, {w=width,h=22,postype=8})
      local img = self:Append("Image", h, "img"..i,{w=width,h=22,image="ui\\Image\\Common\\TextShadow.UITex",frame=2,lockshowhide=1})
      local hh = self:Append("Handle", h, "hh"..i, {w=width,h=22,postype=0,handletype=3})
      -- local txt = self:Append("Text", hh, "txt"..i, {w=180,h=22,text=str}):SetMultiLine(true):AutoSize()

      local hhraw = hh:GetSelf()
      for i, s in ipairs(_t.RenderBattleLog(t, v)) do
        hhraw:AppendItemFromString(s)
      end

      hh:FormatAllItemPos():SetSizeByAllItemSize()
      img:SetSize(hh:GetSize())
      h:FormatAllItemPos():SetSizeByAllItemSize()
      -- hh.OnClick = function()
      --   out(this:GetTreePath())
      -- end
      hh.OnEnter = function() img:Show() end
      hh.OnLeave = function() img:Hide() end
    end
    scroll2:UpdateList()
  end
  btnRefresh.OnClick()

  return frame
end

function _t.BattleLog:OpenPanel()
  local frame = self:Fetch("Clouds_Flags_BattleLog")
  if frame and frame:IsVisible() then
    frame:Destroy()
  else
    frame = self:Init()
  end
end

local function init()
  local Graphics = Clouds_Graphics
  _t.Output_verbose(--[[tag]]0, "Hello Graphics => %s", tostring(Graphics))
  local tConfig = {
    szName = "BattleLog",
    szTitle = _L("BattleLog"),
    dwIcon = 80,
    szClass = "Combat",
    tWidget = {
      {
        name = "M_Title", type = "Text", w = 80, h = 28, x = 0, y = 0, text = _L("BattleLogTitle"), font = 136,
      },{
        name = "M_DevTools", type = "TextButton", w = 100, h = 25, x = 0, y = 60, text = _L("BattleLogOpen"), font = 177,
        callback = function()
          _t.BattleLog:OpenPanel()
        end
      }
    },
  }
  Graphics.manager.EasyManager:RegisterPanel(tConfig)
  if _t.module.DEBUG then
    _t.BattleLog:OpenPanel()
  end
end

Clouds_Base.event.Add("LOGIN_GAME", init)
