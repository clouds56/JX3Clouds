local _L = Clouds.Speak.lang.L
local enum = Clouds.Base.enum
local api = Clouds.Base.api
local event = Clouds.Base.event

local _t
_t = {
  NAME = "skill",

  SkillSpeak = function(from, to, id, level)
    if _t.module.data and _t.module.data.speak then
      local me = GetClientPlayer()
      local skill = Table_GetSkill(id, level)
      if not skill or skill.szSpecialDesc == "" then
        return
      end
      local t = _t.module.data.speak:get(skill.szName)
      local action = ""
      if from == me.dwID then
        action = "hit"
      elseif to == me.dwID then
        action = "got"
      elseif from == nil then
        action = "casting"
      end
      if t then
        _t.Output_verbose(--[[tag]]1001, string.format("%s %s(%d)", action, tostring(skill.szName), id))
        if t[action] and #t[action] ~= 0 then
          local me = GetClientPlayer()
          local tar = api.GetObject(to) or {szName = _L("UnknownTarget")}
          local i = math.floor(math.random()*(#t[action]))+1
          local text = t[action][i].text:gsub("$$", "$$|"):gsub("$u", tostring(tar.szName)):gsub("$me", tostring(me.szName)):gsub("$s", skill.szName):gsub("$$|", "$")
          _t.Output_verbose(--[[tag]]1002, text)
          local result = me.Talk(enum.PLAYER_TALK_CHANNEL.RAID, 0, {{ type = "text", text = text }})
          if result == false then
            _t.Output_warn(--[[tag]]3000, "talk failed")
          end
        end
      end
    end
  end,

  OnSkillCast = function(event, now, from, to, id, level)
    -- _t.Output_verbose(--[[tag]]1000, string.format("[%s] %d casting (%d, %d) to %d", tostring(event), tostring(from), tostring(id), tostring(level), tostring(to)))
    if not _t.cast_list[from] then
      _t.cast_list[from] = {}
    end
    _t.cast_list[from][id] = now

    if event == "UI_OME_SKILL_CAST_LOG" and to ~= nil then
      from = nil
    end
    _t.SkillSpeak(from, to, id, level)
  end,

  cast_list = {},
}

_t.module = Clouds.Speak
Clouds.Speak.skill = _t
Clouds.Base.base.gen_all_msg(_t)

event.Add("SYS_MSG", function()
  local now = GetLogicFrameCount()
  local tp = arg0
  if tp == "UI_OME_SKILL_CAST_LOG" then
    local me = GetClientPlayer()
    local _, target
    if me.dwID == arg1 then
      _, target = me.GetTarget()
    end
    _t.OnSkillCast(tp, now, arg1, target, arg2, arg3)
  -- elseif tp == "UI_OME_SKILL_CAST_RESPOND_LOG" then _t.OnSkillCast(tp, now, arg1, nil, arg2, arg3)
  elseif tp == "UI_OME_SKILL_EFFECT_LOG" then _t.OnSkillCast(tp, now, arg1, arg2, arg5, arg6)
  elseif tp == "UI_OME_SKILL_BLOCK_LOG" then _t.OnSkillCast(tp, now, arg1, arg2, arg4, arg5, arg6)
  elseif tp == "UI_OME_SKILL_SHIELD_LOG" then _t.OnSkillCast(tp, now, arg1, arg2, arg4, arg5)
  elseif tp == "UI_OME_SKILL_MISS_LOG" then _t.OnSkillCast(tp, now, arg1, arg2, arg4, arg5)
  elseif tp == "UI_OME_SKILL_HIT_LOG" then _t.OnSkillCast(tp, now, arg1, arg2, arg4, arg5)
  elseif tp == "UI_OME_SKILL_DODGE_LOG" then _t.OnSkillCast(tp, now, arg1, arg2, arg4, arg5)
  end
end, "Clouds_Player_skill")
