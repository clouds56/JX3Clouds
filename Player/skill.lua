local _t
_t = {
  NAME = "skill",

  SkillSpeak = function(from, to, id, level)
    if _t.module.ui and _t.module.ui.tSkillSpeak then
      local me = GetClientPlayer()
      local skill = Table_GetSkill(id, level)
      if not skill or skill.szSpecialDesc == "" then
        return
      end
      local t = _t.module.ui.tSkillSpeak:get(skill.szName)
      local action = ""
      if t then
        if from == me.dwID then
          action = "hit"
        elseif to == me.dwID then
          action = "got"
        elseif from == nil then
          action = "casting"
        end
        _t.Output_verbose(--[[tag]]1001, string.format("%s %s(%d)", action, tostring(skill.szName), id))
        if t[action] and #t[action] ~= 0 then
          local i = math.floor(math.random()*(#t[action]))+1
          _t.Output_verbose(--[[tag]]1002, tostring(t[action][i].text))
        end
      end
    end
  end,

  OnSkillCast = function(event, now, from, to, id, level)
    _t.Output_verbose(--[[tag]]1000, string.format("[%s] %d casting (%d, %d) to %d", tostring(event), tostring(from), tostring(id), tostring(level), tostring(to)))
    if not _t.cast_list[from] then
      _t.cast_list[from] = {}
    end
    _t.cast_list[from][id] = now

    _t.SkillSpeak(from, to, id, level)
  end,

  cast_list = {},
}

_t.module = Clouds_Player
Clouds_Player.skill = _t
_t.module.base.gen_all_msg(_t)

Clouds_Base.event.Add("SYS_MSG", function()
  local now = GetLogicFrameCount()
  local event = arg0
  -- if event == "UI_OME_SKILL_CAST_LOG" then _t.OnSkillCast(event, now, arg1, nil, arg2, arg3)
  -- elseif event == "UI_OME_SKILL_CAST_RESPOND_LOG" then _t.OnSkillCast(event, now, arg1, nil, arg2, arg3)
  if event == "UI_OME_SKILL_EFFECT_LOG" then _t.OnSkillCast(event, now, arg1, arg2, arg5, arg6)
  elseif event == "UI_OME_SKILL_BLOCK_LOG" then _t.OnSkillCast(event, now, arg1, arg2, arg4, arg5, arg6)
  elseif event == "UI_OME_SKILL_SHIELD_LOG" then _t.OnSkillCast(event, now, arg1, arg2, arg4, arg5)
  elseif event == "UI_OME_SKILL_MISS_LOG" then _t.OnSkillCast(event, now, arg1, arg2, arg4, arg5)
  elseif event == "UI_OME_SKILL_HIT_LOG" then _t.OnSkillCast(event, now, arg1, arg2, arg4, arg5)
  elseif event == "UI_OME_SKILL_DODGE_LOG" then _t.OnSkillCast(event, now, arg1, arg2, arg4, arg5)
  end
end, "Clouds_Player_skill")
