-- config: gbk --

local _t
_t = {
  NAME = "lang",
  -- strings = {},
  L = function(name)
    return _t.strings[name] or name
  end,
}

_t.module = Clouds_Player
Clouds_Player.lang = _t
_t.module.base.gen_all_msg(_t)

_t.strings = {
  SkillMon = "技能喊话",
  SkillSpeakTitle = "技能喊话",
  Add = "添加",
  Save = "保存",
  Reset = "重置",
  hit = "命中",
  got = "被命中",
  casting = "读条",
  SkillName = "技能名",
  SkillAction = "类型",
  Setup = "设置",
  SkillSpeakEnabled = "技能喊话开关",
  New = "新建",
  Modify = "修改",
  Delete = "删除",
}
