local speak
speak = {
  NAME = "Clouds_Speak",
  DEBUG = true,
  LEVEL = Clouds.LEVEL,
  LEVEL_CURRENT = Clouds.LEVEL.VERBOSE,
  LEVEL_LOG = Clouds.LEVEL.VERBOSEEX,
}
_G.Clouds.Speak = speak

local _t
_t = {
  NAME = "base",
  gen_msg = Clouds.Base.module_gen_msg(speak),
  gen_all_msg = Clouds.Base.base.gen_all_msg
}

_t.module = Clouds.Speak
Clouds.Speak.base = _t
