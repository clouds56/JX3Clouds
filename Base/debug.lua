Clouds_Base.DEBUG = true
Clouds_Base.LEVEL_CURRENT = 1

_t = {}

_t.module = Clouds_Base
Clouds_Base.debug = _t

_t.object_to_string = _t.module.algorithm.object_to_string

if _t.module.DEBUG then
  function _var2str(...)
    local t = {...}
    if #t == 1 then
      return _t.object_to_string(t[1])
    end
    return _t.object_to_string(t)
  end

  function _dumpstr(f)
    return _t.object_to_string(f, { fun=true })
  end

  function out(...)
    local s = _var2str(...)
    OutputMessage("MSG_SYS", s)
    print(s)
  end
end
