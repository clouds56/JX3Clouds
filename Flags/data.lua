local IsPlayerExist = IsPlayerExist
local GetPlayer = GetPlayer
local GetNpc = GetNpc
local Table_GetBuff = Table_GetBuff
local Table_GetSkill = Table_GetSkill
local Table_GetBuffName = Table_GetBuffName
local Table_GetSkillName = Table_GetSkillName
local SKILL_EFFECT_TYPE = SKILL_EFFECT_TYPE

local _t
_t = {
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
  --- _players[id] = { id, type, [name, force, level, zhuangfen] }
  _players = {},
  --- @param(id): player id
  --- @param(type): NPC or Player
  RecordPlayer = function(self, playerid)
    local t = {type = IsPlayerExist(playerid), id = playerid, tostring = self.PlayerToString}
    if t.type == true then
      t.t = GetPlayer(t.id)
    else
      t.t = GetNpc(t.id)
    end
    if t.t then
      t.name = t.t.szName
    end
    self._players[playerid] = t
    return t
  end,
  GetPlayer = function(self, playerid)
    return self._players[playerid] or self:RecordPlayer(playerid)
  end,
  PlayerToString = function(self)
    return string.format("%s#%d", self.name or "Unknown", self.id)
  end,

  --- cache for Table_Skill...
  --- _skills[id] = {type, id, level, [name, school,] }
  _skills = {},
  RecordSkill = function(self, skillid)
    local index = table.concat(skillid, "|")
    local t = {type = skillid[1], id = skillid[2], level = skillid[3], tostring = self.SkillToString}
    if t.type == SKILL_EFFECT_TYPE.SKILL then
      t.t = Table_GetSkill(t.id, t.level)
    elseif t.type == SKILL_EFFECT_TYPE.BUFF then
      t.t = Table_GetBuff(t.id, t.level)
    end
    if t.t then
      t.name = t.t.szName
    end
    self._skills[index] = t
    return t
  end,
  GetSkill = function(self, skillid)
    local index = table.concat(skillid, "|")
    return self._skills[index] or self:RecordSkill(skillid)
  end,
  SkillToString = function(self)
    local t = self.type == SKILL_EFFECT_TYPE.BUFF and "B:" or ""
    return string.format("%s%s(%d,%d)", t, self.name or "Unknown", self.id, self.level)
  end,

  _buffs = {},
  RecordBuff = function(self, buffid)
    local index = table.sconcat(buffid, "|")
    local t = {type = buffid[1], id = buffid[2], level = buffid[3], tostring = self.SkillToString}
    t.t = Table_GetBuff(t.id, t.level)
    if t.t then
      t.name = t.t.szName
    end
    self._buffs[index] = t
    return t
  end,
  GetBuff = function(self, buffid)
    local index = table.sconcat(buffid, "|")
    return self._buffs[index] or self:RecordBuff(buffid)
  end,
  BuffToString = function(self)
    local t = self.type and "" or "D:"
    return string.format("%s%s(%d,%d)", t, self.name or "Unknown", self.id, self.level)
  end,

  _compat = {
    --- skill[i] = { time=, src=, dst=, skill=, damage=, health=, }
    skill = {},
    --- buff[i] = { time=, [src=,] dst=, buff=, isadd=, }
    buff = {},
    damage = {},
    status = {},
  },
  RecordSkillEffect = function(self, timestamp, sourceid, destid, skillid, damage, health)
    table.insert(self._compat.skill, {time=timestamp, src=self:GetPlayer(sourceid), dst=self:GetPlayer(destid), skill=self:GetSkill(skillid), damage=damage, health=health})
  end,
  RecordBuffLog = function(self, timestamp, sourceid, destid, buffid, isadd)
    table.insert(self._compat.buff, {time=timestamp, dst=self:GetPlayer(destid), buff=self:GetBuff(buffid), isadd=isadd})
  end
}

_t.module = Clouds_Flags
Clouds_Flags.data = _t
