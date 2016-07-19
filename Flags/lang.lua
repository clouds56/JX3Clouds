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
_t.Output = Clouds_Flags.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end
_t.Output_ex = function(...) _t.Output(_t.module.LEVEL.VERBOSEEX, ...) end

_t.strings = {
  BattleLog = "战斗记录",
  BattleLogTitle = "战斗记录查看",
  BattleLogOpen = "<打开>"
}
