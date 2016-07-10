Clouds_Flags = {
  NAME = "Clouds_Flags",
  DEBUG = Clouds_Base.DEBUG,
  LEVEL = Clouds_Base.LEVEL,
  LEVEL_CURRENT = Clouds_Base.LEVEL_CURRENT,
}

local _t
_t = {
  gen_msg = Clouds_Base.module_gen_msg(Clouds_Flags),
}

_t.module = Clouds_Flags
Clouds_Flags.base = _t
