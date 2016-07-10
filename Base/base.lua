local _ = {}
local _level = {
  VERBOSE = 1,
  INFO = 2,
  WARNING = 3,
  ERROR = 4,
}

_level.leveltostring = function(level)
  if level == _level.VERBOSE then
    return "verb"
  elseif level == _level.INFO then
    return "Info"
  elseif level == _level.WARNING then
    return "WARN"
  elseif level == _level.ERROR then
    return "ERROR"
  else
    return ("Unknown(%s)"):format(tostring(level))
  end
end

Clouds_Base = {
  NAME = "Clouds_Base",
  DEBUG = false,
  LEVEL = _level,
  LEVEL_CURRENT = _level.WARNING,

  module_gen_msg = function(module)
    if module.module then module = module.module end
    return function(h)
      h = tostring(h)
      return function(level, format, ...)
        local s = "[" .. h .. "] " .. string.format(format, ...) .. "\n"
        if module.DEBUG then
          Trace(string.format("[%s:%s]", module.NAME, module.LEVEL.leveltostring(level)) .. s)
        end
        if module.LEVEL_CURRENT <= level then
          OutputMessage("MSG_SYS", string.format("[%s]", module.NAME) .. s)
        end
      end
    end
  end,
}

local _t
_t = {
  gen_msg = Clouds_Base.module_gen_msg(Clouds_Base)
}

_t.module = Clouds_Base
Clouds_Base.base = _t
