local _t
_t = {
  NAME = "lang",
  -- strings = {},
  L = function(name)
    return _t.strings[name]
  end,
}

_t.module = Clouds_Graphics
Clouds_Graphics.lang = _t
_t.Output = Clouds_Graphics.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end
_t.Output_ex = function(...) _t.Output(_t.module.LEVEL.VERBOSEEX, ...) end

_t.strings = {
  All = "所有",
  Combat = "战斗",
  Raid = "团队",
  Other = "其他",
  EasyManagerTitle = "流云插件集",
  EasyManagerBtnTipTitle = "流云插件管理",
  EasyManagerBtnTipDesc = "单击这里可以打开插件管理器。",
}
