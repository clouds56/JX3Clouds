local Wnd, Station = Wnd, Station
local gl

local _t
_t = {
  NAME = "draw",
  szIni = "interface/Clouds/Graphics/draw.ini",
  handles = {},
}

_t.module = Clouds_Graphics
Clouds_Graphics.draw = _t
_t.Output = Clouds_Graphics.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end
_t.Output_ex = function(...) _t.Output(_t.module.LEVEL.VERBOSEEX, ...) end

_t.GetHandle = function(name)
  if not _t.ui or not _t.ui.handle then return end
  local h = _t.handles[name] or _t.ui.handle:Lookup(name)
  if not h then
    _t.Output_ex(--[[tag]]0, "creating handle %s", name)
    -- TODO: escape name
    _t.ui.handle:AppendItemFromString(string.format('<handle>name="%s"</handle>', name))
    h = _t.ui.handle:Lookup(name)
    if h == nil then
      _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, "new item create failed %s: %s", name, tostring(h))
      return
    end
    if h:GetName() ~= name then
      _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, "new item has name %s but not %s", h:GetName(), name)
      return
    end
    _t.handles[name] = h
  end
  return h
end

_G.Clouds_Graphics_Draw = {}
_G.Clouds_Graphics_Draw.OnFrameCreate = function()
  _t.Output_ex(--[[tag]]0, "on frame create")
  -- _t.ui.handle = this:Lookup("", "")
end

local init = function()
  if _t.ui then return end
  local ui = Station.Lookup("Lowest/Clouds_Graphics_Draw")
  if not ui then
    ui = Wnd.OpenWindow(_t.szIni, "Clouds_Graphics_Draw")
  end
  _t.ui = ui
  _t.ui.handle = _t.ui:Lookup("", "")
  _t.ui.handle:Clear()
  _t.Output_verbose(--[[tag]]0, "init successfully: %s", tostring(_t.ui))
end

init()

gl = {
  GetHandle = _t.GetHandle,
}
if _t.module.DEBUG then
  _G.gl = gl
end
