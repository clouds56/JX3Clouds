local _ = {
  DEBUG = true,
  LEVEL = {
    VERBOSE = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
  },
  LEVEL_CURRENT = 1,
}

_.base = {
  gen_msg = function(h)
    h = tostring(h)
    return function(level, s, ...)
      local s = "[" .. h .. "] " .. tostring(s) .. "\n"
      if _.DEBUG then
        Trace("[Clouds:"..tostring(level).."]" .. s)
      end
      if _.LEVEL_CURRENT <= level then
        OutputMessage("MSG_SYS", s)
      end
    end
  end
}

Clouds_Base = _
