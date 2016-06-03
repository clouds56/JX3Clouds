local _ = Clouds_Flags

_.data = {
  PLAYER_TYPE = {
    DAXIA = 0,
    QIXIU = 1,
    WANHUA = 2,
    CHUNYANG = 3,
    CANGJIAN = 4,
    TIANCE = 5,
    TANGMEN = 6,
    WUDU = 7,
    SHAOLIN = 8,
    MINGJIAO = 9,
    GAIBANG = 10,
    CANGYUN = 11,
    CHANGGE = 12,
    NPC = 100,
    BOSS = 104,
  },
  --- _players[id] = { id, type, name, force, level, zhuangfen }
  _players = {},
  --- @param(id): player id
  --- @param(type): NPC or Player
  RecordPlayer = function(id, type, name, force, zhuangfen )
    _.data._players[id] = { id, type, name, force, zhuangfen }
  end,

  --- cache for Table_Skill...
  --- _skills[id] = {id, school, }
  _skills = {},

  _compat = {
    --- skill[i] = { sourceid, destid, skillid,  }
    skill = {},
    buff = {},
    damage = {},
    status = {},
  },
  RecordSkill = function(timestamp, sourceid, destid, skillid, damage, therapy)
    table.insert(_.data._compat.skill, {timestamp, sourceid, destid, skillid, damage, therapy})
  end,
}
