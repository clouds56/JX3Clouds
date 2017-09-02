if Clouds then return end
_G.Clouds = {}

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
_G.Clouds.DEBUG = false
_G.Clouds.LEVEL_CURRENT = _level.ERROR
_G.Clouds.LEVEL_LOG = _level.WARNING

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
  DEBUG = Clouds.DEBUG,
  LEVEL = _level,
  LEVEL_CURRENT = Clouds.LEVEL_CURRENT,
  LEVEL_LOG = Clouds.LEVEL_LOG,

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
          Trace(string.format("[%s:%s]", module.NAME, base.LEVEL.leveltostring(level)) .. s)
        end
        if module.LEVEL_CURRENT <= level then
          OutputMessage("MSG_SYS", string.format("[%s]", module.NAME) .. s)
        end
      end
    end
  end,
}
Clouds.Base = base

local _t
_t = {
  gen_msg = base.module_gen_msg(base),
  gen_all_msg = function(t)
    t.Output = t.module.base.gen_msg(t.NAME)
    t.Output_ex = function(...) t.Output(base.LEVEL.VERBOSEEX, ...) end
    t.Output_verbose = function(...) t.Output(base.LEVEL.VERBOSE, ...) end
    t.Output_info = function(...) t.Output(base.LEVEL.INFO, ...) end
    t.Output_warn = function(...) t.Output(base.LEVEL.WARNING, ...) end
    t.Output_err = function(...) t.Output(base.LEVEL.ERROR, ...) end
  end,
}

local tag_basestring = "0123456789abcdefghijklmnopqrstuvwxyz"
for i = 1, 36 do
  base.tag_base[i] = tag_basestring:sub(i, i)
end

_t.module = Clouds.Base
Clouds.Base.base = _t
