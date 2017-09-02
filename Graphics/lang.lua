local _t
_t = {
  NAME = "lang",
  -- strings = {},
  L = function(name)
    return _t.strings[name]
  end,
}

_t.module = Clouds.Graphics
Clouds.Graphics.lang = _t
Clouds.Base.base.gen_all_msg(_t)

_t.strings = {
  All = "所有",
  Combat = "战斗",
  Raid = "团队",
  Other = "其他",
  EasyManagerTitle = "流云插件集",
  EasyManagerBtnTipTitle = "流云插件管理",
  EasyManagerBtnTipDesc = "单击这里可以打开插件管理器。",
}
