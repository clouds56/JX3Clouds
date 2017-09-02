local speak
speak = {
  NAME = "Clouds_Speak",
  DEBUG = true,
  LEVEL_CURRENT = Clouds.LEVEL_CURRENT,
  LEVEL_LOG = Clouds.LEVEL_LOG,
}
_G.Clouds.Speak = speak

local _t
_t = {
  NAME = "base",
  gen_msg = Clouds.Base.module_gen_msg(speak),
}

_t.module = Clouds.Speak
Clouds.Speak.base = _t
