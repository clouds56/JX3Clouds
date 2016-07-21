-- config: gbk --

local _t
_t = {
  NAME = "lang",
  -- strings = {},
  L = function(name)
    return _t.strings[name] or name
  end,
}

_t.module = Clouds_Flags
Clouds_Flags.lang = _t
_t.module.base.gen_all_msg(_t)

_t.strings = {
  BattleLog = "战斗记录",
  BattleLogTitle = "战斗记录查看",
  BattleLogOpen = "<打开>"
}
