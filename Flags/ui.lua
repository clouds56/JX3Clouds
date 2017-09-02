local _L = Clouds.Flags.lang.L
local CreateAddon = EasyUI.CreateAddon
local Graphics = Clouds.Graphics
local xv = Clouds.xv

local OutputSkillTip, OutputBuffTip, HideTip = OutputSkillTip, OutputBuffTip, HideTip

local _t
_t = {
  NAME = "ui",
  szIni = "interface/Clouds/Flags/ui.ini",
}

_t.module = Clouds.Flags
Clouds.Flags.ui = _t
_t.module.base.gen_all_msg(_t)

_t.BattleLog = CreateAddon("Clouds_Flags_BattleLog")

_t.OnClickBattleType = function(self)

end

_t.BattleLogRegisterPrefix = function(self)
  self.OnItemLButtonDown = function()
    local hh, s = this:GetParent(), ""
    for i = 0, hh:GetItemCount() - 1 do
      s = s .. hh:Lookup(i):GetText()
    end
    xv.debug.out(s, this:GetTreePath())
  end
  -- xv.debug.out(self)
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

_t.PlayerToColor = function(player)
  if _t.tocolor_cache[player] then
    return _t.tocolor_cache[player]
  end
  if not player.force then
    return 0xFFFFFF
  end
  return player.force
end

_t.RenderBattleLog = function(compat, tp, value)
  local ss = {}
  table.insert(ss, xv.api.GetFormatText(string.format("[%s] ", xv.algo.frame.tostring(value.time, 2)), 0xFFFF00))
  table.insert(ss, xv.api.GetFormatText(tp..": ", {0xFFFFFF,10}, 515,
    'Clouds.Flags.ui.BattleLogRegisterPrefix(this)', "type"))
  if tp == "skill" or tp == "buff" then
    if value.act ~= _t.module.data.ACTION_TYPE.SKILL_LOG then
      local src = compat:GetPlayer(value.src)
      table.insert(ss, xv.api.GetFormatText(_t.PlayerToString(src), 0x0080FF))
      table.insert(ss, xv.api.GetFormatText("@", 0x808080))
    else
      local dst = compat:GetPlayer(value.dst)
      table.insert(ss, xv.api.GetFormatText(_t.PlayerToString(dst), 0xFF8000))
      table.insert(ss, xv.api.GetFormatText("@", 0x808080))
    end

    if tp == "skill" then
      table.insert(ss, xv.api.GetFormatText(string.format("%s", _t.SkillToString(value.skill)), 0x00FFFF, 256,
        string.format('Clouds.Flags.ui.BattleLogRegisterSkill(this,%d,%d)', value.skill.id, value.skill.level), "skill"))
    elseif tp == "buff" then
      table.insert(ss, xv.api.GetFormatText(string.format("%s", _t.BuffToString(value.buff)), value.buff.type ~= false and 0x00FF00 or 0xFF0000, 256,
        string.format('Clouds.Flags.ui.BattleLogRegisterBuff(this,%d,%d)', value.buff.id, value.buff.level), "buff"))
      if value.act == _t.module.data.ACTION_TYPE.BUFF_ADD then
        table.insert(ss, xv.api.GetFormatText(" +++ ", value.buff.type~=false and 0x00FF00 or 0xFF0000))
      elseif value.act == _t.module.data.ACTION_TYPE.BUFF_REMOVE then
        table.insert(ss, xv.api.GetFormatText(" --- ", value.buff.type==false and 0x00FF00 or 0xFF0000))
      else
        --table.insert(ss, xv.api.GetFormatText(" => ", 0x808080))
      end
    end

    if value.damage and value.damage.therapy+value.damage.damage ~= 0 then
      -- { !!100 (10) }
      table.insert(ss, xv.api.GetFormatText(" { ", 0x808080))
      if value.damage.damage ~= 0 then
        if value.oops then
          table.insert(ss, xv.api.GetFormatText("!!", 0xFF8000))
        end
        if value.damage.effective_damage ~= value.damage.damage then
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

    if value.act ~= _t.module.data.ACTION_TYPE.SKILL_LOG and value.dst ~= value.src then
      if value.act == _t.module.data.ACTION_TYPE.SKILL_EFFECT or value.act == _t.module.data.ACTION_TYPE.BUFF_ACTION then
        table.insert(ss, xv.api.GetFormatText(" => ", 0x808080))
      elseif value.act == _t.module.data.ACTION_TYPE.SKILL_LOG then
        table.insert(ss, xv.api.GetFormatText(" => ", 0xFFFFFF))
      elseif not value.act then
        table.insert(ss, xv.api.GetFormatText(" : ", 0x808080))
      end
      local dst = compat:GetPlayer(value.dst)
      table.insert(ss, xv.api.GetFormatText(_t.PlayerToString(dst), 0xFF8000))
    end

    -- table.insert(ss, xv.api.GetFormatText(string.format(" (%s)", _t.module.data.ACTION_TYPE.tostring(value.act))))
    -- table.insert(ss, xv.api.GetFormatText("\n", 0xFFFFFF))
  end
  return ss
end

_t.BattleLog.width = 480

function _t.BattleLog:AppendBattleItem(compat, tp, item)
  local scroll = self.scrollLog
  local h = self:Append("Handle", scroll, "h"..tostring(item), {w=self.width,h=22,postype=8})
  local img = self:Append("Image", h, "img"..tostring(item),{w=self.width,h=22,image="ui\\Image\\Common\\TextShadow.UITex",frame=2,lockshowhide=1})
  local hh = self:Append("Handle", h, "hh"..tostring(item), {w=self.width,h=22,postype=0,handletype=3})

  local hhraw = hh:GetSelf()
  for i, s in ipairs(_t.RenderBattleLog(compat, tp, item)) do
    hhraw:AppendItemFromString(s)
  end

  hh:FormatAllItemPos():SetSizeByAllItemSize()
  local hhw, hhh = hh:GetSize()
  img:SetSize(self.width, hhh)
  h:FormatAllItemPos():SetSizeByAllItemSize()
  h.OnEnter = function() img:Show() end
  h.OnLeave = function() img:Hide() end
  hh.OnEnter = function() img:Show() end
  hh.OnLeave = function() img:Hide() end
end

function _t.BattleLog:RefreshBattle(compat)
  local scroll = self.scrollLog
  scroll:GetHandle():Clear()
  for i, t, v in xv.algo.table.iter_subtables(compat and compat.logs or {}) do
    self:AppendBattleItem(compat, t, v)
  end
  scroll:UpdateList()
end

function _t.BattleLog:Init()
  local compat = _t.module.data.current_compat
  local frame = self:CreateMainFrame({title = _L("BattleLogTitle"), style = "NORMAL"})
  frame:RegisterEvent("Clouds_Flags_record_CURRENT_COMPAT_UPDATE", function()
    if arg0 == compat then
      self:AppendBattleItem(arg0, arg1, arg2)
      self.scrollLog:UpdateList()
    end
  end)

  local window = self:Append("Window", frame, "WindowMain", {x = 0,y = 50,w = 768,h = 400})
  local pos = EasyUI.NewPos(50, 20, 5)
  local btnRefresh = self:Append("Button", window, "ButtonRefresh", {rect = pos:Next(100, 30), text = _L("Refresh")})
  local btnNew = self:Append("Button", window, "ButtonNew", {rect = pos:Next(100, 30), text = _L("New")})
  local btnEnd = self:Append("Button", window, "ButtonEnd", {rect = pos:Next(100, 30), text = _L("End")})
  local btnReload = self:Append("Button", window, "ButtonReload", {rect = pos:Next(100, 30), text = _L("Reload")})
  pos:NextLine()
  local scrollLog = self:Append("Scroll", window, "ScrollLog", {rect = pos:Next(self.width+20, 350)})
  self.scrollLog = scrollLog

  btnRefresh.OnClick = function()
    self:RefreshBattle(compat)
  end
  btnNew.OnClick = function()
    compat = _t.module.data:StartNewCompat()
    self:RefreshBattle(compat)
  end
  btnEnd.OnClick = function()
    _t.module.data:EndCompat()
    self:RefreshBattle()
  end
  btnReload.OnClick = function()
    xv.api.ReloadUIAddon()
  end
  self:RefreshBattle(compat)

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
      },{
        name = "M_Options", type = "Text", rect = { w = 100, h = 25, x = 0, y = 90 }, text = "Options", font = 140,
      }
    },
  }
  Graphics.manager.EasyManager:RegisterPanel(tConfig)
end

local Base = Clouds.Base
Base.event.Add("LOGIN_GAME", init, "Clouds_Flags_ui")

Base.event.Add("LOADING_END", function()
  if _t.module.DEBUG then
    _t.Output_verbose(--[[tag]]0, "Open BattleLog Panel")
    Base.event.Delay(1, function()_t.BattleLog:OpenPanel()end, "Clouds_Flags_ui_open")
  end
end, "Clouds_Flags_ui")
