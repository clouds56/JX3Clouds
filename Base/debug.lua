local OutputMessage = OutputMessage

Clouds.DEBUG = true
Clouds.LEVEL_CURRENT = Clouds.Base.LEVEL.INFO
Clouds.LEVEL_LOG = Clouds.Base.LEVEL.VERBOSE

local _t = {}
Clouds.debug = _t

_t.object_to_string = Clouds.Base.algorithm.object_to_string

_t.var2str = function(...)
  local t = {...}
  if #t == 1 then
    return _t.object_to_string(t[1])
  end
  return _t.object_to_string(t)
end

_t.dumpstr = function(f)
  return _t.object_to_string(f, { fun=true })
end

_t.out = function(...)
  local s = _t.var2str(...)
  OutputMessage("MSG_SYS", s)
  print(s)
end

Clouds.xv.debug = {
  object_to_string = _t.object_to_string,
  var2str = _t.var2str,
  dumpstr = _t.dumpstr,
  out = _t.out,
}

-- RegisterEvent("CALL_LUA_ERROR", function()
--   out(arg0)
-- end)

if Clouds.DEBUG then
  Clouds.Base.DEBUG = Clouds.DEBUG
  Clouds.Base.LEVEL_CURRENT = Clouds.LEVEL_CURRENT
  Clouds.Base.LEVEL_LOG = Clouds.LEVEL_LOG
  _G._var2str = _t.var2str
  _G._dumpstr = _t.dumpstr
  _G.out = _t.out
  TraceButton_AppendAddonMenu( { function()
    return {{szOption = "Reload", fnAction = function() Clouds.Base.api.ReloadUIAddon() end}}
  end } )
end
