local IsPlayerExist = IsPlayerExist
local GetPlayer = GetPlayer
local GetNpc = GetNpc
local Table_GetBuff = Table_GetBuff
local Table_GetSkill = Table_GetSkill
local Table_GetBuffName = Table_GetBuffName
local Table_GetSkillName = Table_GetSkillName
local SKILL_EFFECT_TYPE = SKILL_EFFECT_TYPE
local SaveLUAData = SaveLUAData
local GetClientPlayer = GetClientPlayer
local GetCurrentTime = GetCurrentTime
local GetLogicFrameCount = GetLogicFrameCount
local FireUIEvent = FireUIEvent

local _t
_t = {
  NAME = "data",

  ACTION_TYPE = {
    BUFF_ADD = 100,
    BUFF_REMOVE = 101,
    BUFF_ACTION = 102,

    SKILL_EFFECT = 209,
    SKILL_LOG = 201,
    SKILL_CASTED = 202,

    tostring = function(self)
      for i, v in pairs(_t.ACTION_TYPE) do
        if self == v then
          return i
        end
      end
      return tostring(self)
    end
  },
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
    if playerid == nil then
      return nil
    end
    local t = {type = IsPlayerExist(playerid), id = playerid, __tostring = self.PlayerToString}
    if t.type == true then
      t.t = GetPlayer(t.id)
      if t.t then
        -- TODO: xinfa
        t.force = t.t.dwForceID
      end
    else
      t.t = GetNpc(t.id)
      if t.t then
        t.force = t.t.dwTemplateID
      end
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
  --- _skills[id] = {type=, id=, level=, [name=, school,] }
  _skills = {},
  RecordSkill = function(self, id, level)
    assert(id ~= nil, "id should not be null")
    local index = id .. "|" .. level
    local t = {id = id, level = level, __tostring = self.SkillToString}
    t.t = Table_GetSkill(t.id, t.level)
    if t.t then
      t.name = t.t.szName
    end
    self._skills[index] = t
    return t
  end,
  GetSkill = function(self, id, level)
    local index = id .. "|" .. level
    return self._skills[index] or self:RecordSkill(id, level)
  end,
  SkillToString = function(self)
    return string.format("%s(%d,%d)", self.name or "Unknown", self.id, self.level)
  end,

  _buffs = {},
  RecordBuff = function(self, id, level, type)
    local index = id .. "|" .. level
    local t = {type = type, id = id, level = level, __tostring = self.BuffToString}
    t.t = Table_GetBuff(t.id, t.level)
    if t.t then
      t.name = t.t.szName
    end
    self._buffs[index] = t
    return t
  end,
  GetBuff = function(self, id, level, type)
    local index = id .. "|" .. level
    local buff = self._buffs[index] or self:RecordBuff(id, level, type)
    if not buff.type then buff.type = type end
    if type and buff.type ~= type then
      _t.Output_warn(--[[tag]]0, "type of %d changed from %s to %s", id, tostring(buff.type), tostring(type))
    end
    return buff
  end,
  BuffToString = function(self)
    local t = self.type==false and "~" or ""
    return string.format("%s%s(%d,%d)", t, self.name or "Unknown", self.id, self.level)
  end,

  DataFolder = "interface/Clouds/Flags/_data",
  SaveCompat = function(compat)
    SaveLUAData(string.format("%s/%s", _t.DataFolder, tostring(compat.__name)), compat)
  end,
  CreateCompat = function()
    local me, id = GetClientPlayer()
    local time, date = GetLogicFrameCount(), GetCurrentTime()
    if me then
      id = me.dwID or 0
    end
    --- {starttime =,}
    local compat = {
      metadata = {
        name = string.format("%d_%d", id, date),
        date =  date,
        starttime = time,
        endtime = time,
        me = id,
      },
      logs = {
        --- skill[i] = { time=, src=, dst=, skill=, damage?={}, data?=data, oops?= }
        skill = {},
        --- buff[i] = { time=, src=, dst=, buff=, act=, lasttime?=, damage?=, oops?=}
        --- lasttime when act = ADD
        --- damage when act = ACTION
        buff = {},
        damage = {},
        status = {},
      },
      data = {
        players = {},
      },
    }
    setmetatable(compat, { __index = _t.compat_method})
    return compat
  end,
  StartNewCompat = function(self)
    if self.current_compat then
      self.SaveCompat(self.current_compat)
    end
    self.current_compat = self.CreateCompat()
    table.insert(self.compats, self.current_compat)
    return self.current_compat
  end,
  compats = {},
  current_compat = nil,

  compat_method = {
    record = function(self, time, t, i)
      table.insert(self.logs[t], i)
      self.metadata.endtime = time
      FireUIEvent("Clouds_Flags_record_CURRENT_COMPAT_UPDATE", self, t, i)
    end,
    RecordSkillLog = function(self, timestamp, sourceid, destid, id, level, act, data)
      self:record(timestamp, "skill", {time=timestamp-self.metadata.starttime, src=_t:GetPlayer(sourceid), dst=_t:GetPlayer(destid), skill=_t:GetSkill(id, level), act=act, data=data})
    end,
    RecordSkillEffect = function(self, timestamp, sourceid, destid, id, level, damage, oops)
      self:record(timestamp, "skill", {time=timestamp-self.metadata.starttime, src=_t:GetPlayer(sourceid), dst=_t:GetPlayer(destid), skill=_t:GetSkill(id, level), act=_t.ACTION_TYPE.SKILL_EFFECT, damage=damage, oops=oops})
    end,
    RecordBuffLog = function(self, timestamp, sourceid, destid, id, level, type, act, data)
      self:record(timestamp, "buff", {time=timestamp-self.metadata.starttime, src=_t:GetPlayer(sourceid), dst=_t:GetPlayer(destid), buff=_t:GetBuff(id, level, type), act=act, data=data})
    end,
    RecordBuffEffect = function(self, timestamp, sourceid, destid, id, level, damage, oops)
      self:record(timestamp, "buff", {time=timestamp-self.metadata.starttime, src=_t:GetPlayer(sourceid), dst=_t:GetPlayer(destid), buff=_t:GetBuff(id, level), act=_t.ACTION_TYPE.BUFF_ACTION, damage=damage, oops=oops})
    end,
  },
}

_t.module = Clouds_Flags
Clouds_Flags.data = _t
_t.module.base.gen_all_msg(_t)
