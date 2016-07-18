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

function _t.BattleLog:Init()
  local frame = self:Append("Frame", "BattleLog", {title = _L("BattleLogTitle"), style = "NORMAL"})

  local window = self:Append("Window", frame, "WindowMain", {x = 0,y = 100,w = 768,h = 400})
  local scroll2 = self:Append("Scroll", window, "ScrollTest", {x = 50,y = 0,w = 200,h = 350})
  for i, t, v in _t.module.data.iter_compat(_t.module.data._compat) do
    local str = t
    if t == "skill" then
      str = string.format("%s: [%d] %s => %s : %s [%d, %d]",
        t, v.time, xv.object_to_string(v.src), xv.object_to_string(v.dst), xv.object_to_string(v.skill), v.damage, v.health)
    elseif t == "buff" then
      str = string.format("%s: [%d] %s : %s => %s (%s)",
        t, v.time, xv.object_to_string(v.buff), xv.object_to_string(v.src), xv.object_to_string(v.dst), v.isadd and "add" or "remove")
    else
      str = string.format("%s: something update", t)
    end
    local h = self:Append("Handle", scroll2, "h"..i, {w=180,h=22,postype=8})
    local img = self:Append("Image", h, "img"..i,{w=160,h=22,image="ui\\Image\\Common\\TextShadow.UITex",frame=2,lockshowhide=1})
    local txt = self:Append("Text", h, "txt"..i, {w=180,h=22,text=str}):SetMultiLine(true):AutoSize()
    img:SetSize(txt:GetSize())
    h:FormatAllItemPos():SetSizeByAllItemSize()
    h.OnClick = function()
      out(txt:IsMultiLine())
    end
    h.OnEnter = function() img:Show() end
    h.OnLeave = function() img:Hide() end
  end
  scroll2:UpdateList()

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
end

Clouds_Base.event.Add("LOGIN_GAME", init)
