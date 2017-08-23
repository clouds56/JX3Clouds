local _t
_t = {
  NAME = "skill",

  OnSkillCast = function(event, now, from, to, id, level)
    _t.Output_verbose(--[[tag]]0, string.format("[%s] %d casting (%d, %d) to %d", tostring(event), tostring(from), tostring(id), tostring(level), tostring(to)))
    if not _t.cast_list[from] then
      _t.cast_list[from] = {}
    end
    _t.cast_list[from][id] = now
  end,

  cast_list = {},
}

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

_t.module = Clouds_Player
Clouds_Player.record = _t
_t.module.base.gen_all_msg(_t)
