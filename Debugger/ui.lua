local CreateAddon = EasyUI.CreateAddon
local xv = Clouds.xv
local out = Clouds.debug.out

local _t
_t = {
  NAME = "ui",
  panel = CreateAddon("Clouds_Debugger_REPL"),
  init = function()
    _t.panel:OpenPanel()
  end,
}

_t.panel.width = 600

function _t.panel:Run()
  self.selected:GetSelf():run()
end

function _t.panel:New()
  local width = self.width
  local scroll = self.scroll
  local edit = self.edit
  local h = self:Append("Handle", scroll, "h" .. _t.module.core.index, {w=width,h=22,postype=8})
  local img = self:Append("Image", h, "img" .. _t.module.core.index,{w=width,h=22,image="ui\\Image\\Common\\TextShadow.UITex",frame=2,lockshowhide=1})
  local hh = self:Append("Handle", h, "hh" .. _t.module.core.index, {w=width,h=22,postype=0,handletype=3})

  local hhraw = hh:GetSelf()
  _t.module.core.RenderCode(hhraw, self.edit:GetText(), {
    resize = function(self)
      hh:FormatAllItemPos():SetSizeByAllItemSize()
      local hhw, hhh = hh:GetSize()
      img:SetSize(width, hhh)
      h:FormatAllItemPos():SetSizeByAllItemSize()
      scroll:UpdateList()
    end,
    remove = function(self)
      scroll.__handle:RemoveItem(h:GetSelf())
      -- TODO: fix destroy
      -- h:Destroy()
      scroll:UpdateList()
    end,
    edit = function(self)
      edit:SetText(hh:GetSelf():Lookup(0).data)
    end
  })
  hhraw:run()

  h.OnEnter = function() img:Show() end
  h.OnLeave = function() img:Hide() end
  hh.OnEnter = function() img:Show() end
  hh.OnLeave = function() img:Hide() end

  return hh
end

function _t.panel:Init()
  local frame = self:CreateMainFrame({title = "Debugger", style="LARGER"})

  local window = self:Append("Window", frame, "WindowMain", {x = 0,y = 50,w = 768,h = 1000})
  local pos = EasyUI.NewPos(50, 20, 5)
  local btnNew = self:Append("Button", window, "ButtonNew", {rect = pos:Next(80, 30), text = "New"})
--  local btnRun = self:Append("Button", window, "ButtonRun", {rect = pos:Next(80, 30), text = "Run"})
  local btnClear = self:Append("Button", window, "ButtonClear", {rect = pos:Next(80, 30), text = "Clear"})
  local btnReload = self:Append("Button", window, "ButtonReload", {rect = pos:Next(80, 30), text = "Reload"})
  pos:NextLine()
  local edit = self:Append("Edit", window, "edit", {rect = pos:Next(self.width, 150), multi = true, limit = 10*1000*1000})
  pos:NextLine()
  local scroll = self:Append("Scroll", window, "ScrollLog", {rect = pos:Next(self.width + 20, 350)})
  self.edit = edit
  self.scroll = scroll

--  btnRun.OnClick = function()
--    self:Run()
--  end
  btnNew.OnClick = function()
    self.selected = self:New()
  end
  btnClear.OnClick = function()
    self.scroll:ClearHandle()
  end
  btnReload.OnClick = function()
    xv.api.ReloadUIAddon()
  end

  return frame
end

function _t.panel:OpenPanel()
  local frame = self:Fetch("Clouds_Debugger_REPL")
  if frame and frame:IsVisible() then
    frame:Destroy()
  else
    frame = self:Init()
  end
end

_t.module = Clouds.Debugger
Clouds.Debugger.ui = _t
Clouds.Base.base.gen_all_msg(_t)

Clouds.Base.event.Add("LOADING_END", _t.init, "Clouds_Debugger_REPL")
