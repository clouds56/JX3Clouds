if not Clouds or not Clouds.debug then return end

local debugger
debugger = {
  NAME = "Clouds_Debugger",
  DEBUG = true,
  LEVEL_CURRENT = Clouds.Base.LEVEL.VERBOSE,
  LEVEL_LOG = Clouds.Base.LEVEL.VERBOSEEX,
}
_G.Clouds.Debugger = debugger

local _t
_t = {
  NAME = "base",
  gen_msg = Clouds.Base.module_gen_msg(debugger),
}

_t.module = Clouds.Debugger
Clouds.Debugger.base = _t
