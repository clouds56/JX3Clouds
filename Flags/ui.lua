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

_t.RenderBattleLog = function(tp, value)
  local ss = {}
  table.insert(ss, GetFormatText(tp..": ", 10, 255, 255, 255, 515,
    'Clouds_Flags.ui.BattleLogRegisterPrefix(this)', "type"))
  table.insert(ss, GetFormatText(string.format("[%d] ", value.time), nil, 255, 255, 0))
  if tp == "skill" then
    local script = value.skill.type==SKILL_EFFECT_TYPE.SKILL and
      string.format('Clouds_Flags.ui.BattleLogRegisterSkill(this,%d,%d)', value.skill.id, value.skill.level) or
      string.format('Clouds_Flags.ui.BattleLogRegisterBuff(this,%d,%d)', value.skill.id, value.skill.level)
    table.insert(ss, GetFormatText(string.format("%s", xv.object_to_string(value.skill)), 10, 0, 128, 255, 256, script, "skill"))
  elseif tp == "buff" then
    table.insert(ss, GetFormatText(string.format("%s", xv.object_to_string(value.buff)), nil, 0, 255, 255, 256,
      string.format('Clouds_Flags.ui.BattleLogRegisterBuff(this,%d,%d)', value.buff.id, value.buff.level), "buff"))
  end
  if tp == "skill" or tp == "buff" then
    table.insert(ss, GetFormatText(" : "))
    table.insert(ss, GetFormatText(string.format("%s", xv.object_to_string(value.src)), nil, 0, 255, 0))
    table.insert(ss, GetFormatText(" => "))
    table.insert(ss, GetFormatText(string.format("%s", xv.object_to_string(value.dst)), nil, 255, 128, 192))
  end
  return ss
end

function _t.BattleLog:Init()
  local frame = self:Append("Frame", "BattleLog", {title = _L("BattleLogTitle"), style = "NORMAL"})

  local window = self:Append("Window", frame, "WindowMain", {x = 0,y = 50,w = 768,h = 400})
  local btnRefresh = self:Append("Button", window, "ButtonRefresh", {x = 50, y = 20, w = 200, h = 30, text = _L("Refresh")})
  local scroll2 = self:Append("Scroll", window, "ScrollTest", {x = 50,y = 50,w = 300,h = 350})
  btnRefresh.OnClick = function()
    scroll2:GetHandle():Clear()
    for i, t, v in _t.module.data.iter_compat(_t.module.data._compat) do
      local h = self:Append("Handle", scroll2, "h"..i, {w=280,h=22,postype=8})
      local img = self:Append("Image", h, "img"..i,{w=280,h=22,image="ui\\Image\\Common\\TextShadow.UITex",frame=2,lockshowhide=1})
      local hh = self:Append("Handle", h, "hh"..i, {w=280,h=22,postype=0,handletype=3})
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
