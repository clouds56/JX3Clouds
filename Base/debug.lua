local OutputMessage = OutputMessage

Clouds_Base.DEBUG = true
Clouds_Base.LEVEL_CURRENT = Clouds_Base.LEVEL.VERBOSE

local _t = {}

_t.module = Clouds_Base
Clouds_Base.debug = _t

_t.object_to_string = _t.module.algorithm.object_to_string

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

Clouds_Base.xv.debug = {
  object_to_string = _t.object_to_string,
  var2str = _t.var2str,
  dumpstr = _t.dumpstr,
  out = _t.out,
}

-- RegisterEvent("CALL_LUA_ERROR", function()
--   out(arg0)
-- end)

if _t.module.DEBUG then
  _G._var2str = _t.var2str
  _G._dumpstr = _t.dumpstr
  _G.out = _t.out
end
