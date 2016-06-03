Clouds_Flags = {
  DEBUG = Clouds_Base.DEBUG,
  LEVEL = Clouds_Base.LEVEL,
  LEVEL_CURRENT = Clouds_Base.LEVEL_CURRENT,
}

local _t
_t = {
  gen_msg = Clouds_Base.base.gen_msg,
}

_t.module = Clouds_Flags
Clouds_Flags.base = _t
