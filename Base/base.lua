local Trace = Trace
local OutputMessage = OutputMessage

local _ = {}
local _level = {
  VERBOSEEX = 5,
  VERBOSE = 10,
  INFO = 20,
  WARNING = 30,
  ERROR = 40,
}

_level.leveltostring = function(level)
  if level == _level.VERBOSEEX then
    return "verboseex"
  elseif level == _level.VERBOSE then
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

local base
base = {
  NAME = "Clouds_Base",
  DEBUG = false,
  LEVEL = _level,
  LEVEL_CURRENT = _level.WARNING,
  LEVEL_LOG = _level.VERBOSE,

  tag_base = {},
  decode_tag = function(tag)
    local s = ""
    if tag == 0 then return "0" end
    while tag ~= 0 do
      local i = tag % 36
      s = base.tag_base[i+1] .. s
      tag = (tag - i) / 36
    end
  end,
  module_gen_msg = function(module)
    if module.module then module = module.module end
    return function(h)
      h = tostring(h)
      return function(level, tag, format, ...)
        local s = string.format("[%s](%s) ", h, tag) .. string.format(format, ...) .. "\n"
        if module.DEBUG and module.LEVEL_LOG <= level then
          Trace(string.format("[%s:%s]", module.NAME, module.LEVEL.leveltostring(level)) .. s)
        end
        if module.LEVEL_CURRENT <= level then
          OutputMessage("MSG_SYS", string.format("[%s]", module.NAME) .. s)
        end
      end
    end
  end,
}
_G.Clouds_Base = base

local _t
_t = {
  gen_msg = Clouds_Base.module_gen_msg(Clouds_Base),
  gen_all_msg = function(t)
    t.Output = t.module.base.gen_msg(t.NAME)
    t.Output_verbose = function(...) t.Output(t.module.LEVEL.VERBOSE, ...) end
    t.Output_ex = function(...) t.Output(t.module.LEVEL.VERBOSEEX, ...) end
    t.Output_warn = function(...) t.Output(t.module.LEVEL.WARNING, ...) end
  end,
}

local tag_basestring = "0123456789abcdefghijklmnopqrstuvwxyz"
for i = 1, 36 do
  Clouds_Base.tag_base[i] = tag_basestring:sub(i, i)
end

_t.module = Clouds_Base
Clouds_Base.base = _t
