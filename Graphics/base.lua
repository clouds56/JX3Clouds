local graphics
graphics = {
  NAME = "Clouds_Graphics",
  DEBUG = Clouds.DEBUG,
  LEVEL_CURRENT = Clouds.LEVEL_CURRENT,
  LEVEL_LOG = Clouds.LEVEL_LOG,
}
_G.Clouds.Graphics = graphics

local _t
_t = {
  NAME = "base",
  gen_msg = Clouds.Base.module_gen_msg(graphics),
}

_t.module = Clouds.Graphics
Clouds.Graphics.base = _t
