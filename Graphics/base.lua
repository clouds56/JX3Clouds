Clouds_Graphics = {
  NAME = "Clouds_Graphics",
  DEBUG = Clouds_Base.DEBUG,
  LEVEL = Clouds_Base.LEVEL,
  LEVEL_CURRENT = Clouds_Base.LEVEL_CURRENT,
  LEVEL_LOG = Clouds_Base.LEVEL_LOG,
}

local _t
_t = {
  gen_msg = Clouds_Base.module_gen_msg(Clouds_Graphics),
}

_t.module = Clouds_Graphics
Clouds_Graphics.base = _t
