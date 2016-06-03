Clouds_Base = {
  DEBUG = false,
  LEVEL = {
    VERBOSE = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
  },
  LEVEL_CURRENT = 3,
}

local _t
_t = {
  gen_msg = function(h)
    h = tostring(h)
    return function(level, format, ...)
      local s = "[" .. h .. "] " .. string.format(format, ...) .. "\n"
      if _t.module.DEBUG then
        Trace("[Clouds:"..tostring(level).."]" .. s)
      end
      if _t.module.LEVEL_CURRENT <= level then
        OutputMessage("MSG_SYS", s)
      end
    end
  end
}

_t.module = Clouds_Base
Clouds_Base.base = _t
