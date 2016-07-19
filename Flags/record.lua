local GetLogicFrameCount = GetLogicFrameCount
local SKILL_EFFECT_TYPE = SKILL_EFFECT_TYPE
local SKILL_RESULT_TYPE = SKILL_RESULT_TYPE
local SKILL_RESULT_CODE = SKILL_RESULT_CODE

local _t
_t = {
  NAME = "record",

  OnEvent = function()
    _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, string.format("%s %s %s %s", tostring(arg0), tostring(arg1), tostring(arg2), tostring(arg3)))
  end,

  OnSkillCast = function(dwCaster, dwSkillID, dwLevel)
    _t.Output_ex(--[[tag]]0, string.format("%d casting (%d, %d)", dwCaster, dwSkillID, dwLevel))
  end,

  OnSkillCastRespond=function(dwCaster, dwSkillID, dwLevel, nRespond)
    --local szCasterName = GlobalEventHandler.GetCharacterTipInfo(dwCaster)
    --local szSkillName = Table_GetSkillName(dwSkillID, dwLevel)
    --szRespond = GlobalEventHandler.GetSkillRespondText(nRespond)
    --local szMsg = FormatString(g_tStrings.STR_SKILL_CAST_RESPOND_LOG, szCasterName, szSkillName, szRespond)
    _t.Output_ex(--[[tag]]0, string.format("%d casting (%d, %d), result %s(%d)", dwCaster, dwSkillID, dwLevel, _t.GetSkillRespondText(nRespond), nRespond))
  end,

  --- @param(dwCaster): caster id
  --- @param(dwTarget): target id
  --- @param(bReact): not used?
  --- @param(nEffectType): SKILL_EFFECT_TYPE.SKILL or BUFF
  --- @param(dwID): skill id
  --- @param(dwLevel): skill level
  --- @param(bCriticalStrike): is the value of effect doubled
  --- @param(nCount): #tResult
  --- @param(tResult): effect value table? { [13]=EFFECTIVE_DAMAGE, [14]=EFFECTIVE_THERAPY }
  OnSkillEffectLog = function(dwCaster, dwTarget, bReact, nEffectType, dwID, dwLevel, bCriticalStrike, nCount, tResult)
    if dwID == 7513 and dwLevel == 10 then return end
    --local nValue = tResult[SKILL_RESULT_TYPE.PHYSICS_DAMAGE]
    --PHYSICS_DAMAGE, SOLAR_MAGIC_DAMAGE, NEUTRAL_MAGIC_DAMAGE, LUNAR_MAGIC_DAMAGE, POISON_DAMAGE
    --szDamage = szDamage..FormatString(g_tStrings.SKILL_DAMAGE, nValue, g_tStrings.STR_SKILL_PHYSICS_DAMAGE)
    --GlobalEventHandler.OnSkillDamageLog(dwCaster, dwTarget, bReact, nEffectType, dwID, dwLevel, bCriticalStrike, szDamage, tResult, nTotal)

    --nValue = tResult[SKILL_RESULT_TYPE.THERAPY];GlobalEventHandler.OnSkillTherapyLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, bCriticalStrike, tResult)

    --GlobalEventHandler.OnSkillReflectiedDamageLog(dwCaster, dwTarget, tResult[SKILL_RESULT_TYPE.REFLECTIED_DAMAGE])
    --GlobalEventHandler.OnSkillStealLifeLog(dwCaster, dwTarget, tResult[SKILL_RESULT_TYPE.STEAL_LIFE])
    --GlobalEventHandler.OnSkillDamageAbsorbLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, tResult[SKILL_RESULT_TYPE.ABSORB_DAMAGE])
    --GlobalEventHandler.OnSkillDamageShieldLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, tResult[SKILL_RESULT_TYPE.SHIELD_DAMAGE])
    --GlobalEventHandler.OnSkillDamageParryLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, tResult[SKILL_RESULT_TYPE.PARRY_DAMAGE]);
    --GlobalEventHandler.OnSkillDamageInsightLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, tResult[SKILL_RESULT_TYPE.INSIGHT_DAMAGE])
    --GlobalEventHandler.OnSkillDamageTransferLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, tResult[SKILL_RESULT_TYPE.TRANSFER_LIFE], SKILL_RESULT_TYPE.TRANSFER_LIFE)
    --GlobalEventHandler.OnSkillDamageTransferLog(dwCaster, dwTarget, nEffectType, dwID, dwLevel, tResult[SKILL_RESULT_TYPE.TRANSFER_MANA], SKILL_RESULT_TYPE.TRANSFER_MANA)
    local verbose = ""
    if _t.module.DEBUG then verbose = string.format("verbose: %s", xv.object_to_string(tResult, {oneline=true})) end
    _t.Output_ex(--[[tag]]0, string.format("%d casted (%d, %d), effect %d. %s", dwCaster, dwID, dwLevel, dwTarget, verbose))
    local damage, therapy = 0, tResult[SKILL_RESULT_TYPE.THERAPY] or 0
    for i, t in ipairs({"PHYSICS_DAMAGE", "SOLAR_MAGIC_DAMAGE", "NEUTRAL_MAGIC_DAMAGE", "LUNAR_MAGIC_DAMAGE", "POISON_DAMAGE"}) do
      damage = damage + (tResult[SKILL_RESULT_TYPE[t]] or 0)
    end
    if damage ~= 0 or therapy ~= 0 then
      _t.module.data:RecordSkillEffect(GetLogicFrameCount(), dwCaster, dwTarget, {nEffectType, dwID, dwLevel}, damage, therapy)
    end
  end,

  OnCommonHealthLog=function(dwTarget, nDeltaLife)
    --szMsg = FormatString(g_tStrings.STR_SKILL_COMMON_DAMAGE_LOG_MSG, szTargetName, -nDeltaLife)
    --szMsg = FormatString(g_tStrings.STR_SKILL_COMMON_THERAPY_LOG_MSG, szTargetName, nDeltaLife)
    _t.Output_verbose(--[[tag]]0, string.format("%d get %d health", dwTarget, nDeltaLife))
  end,

  OnSkillBlockLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, dwDamageType)
    --local szMsg = FormatString(g_tStrings.STR_SKILL_BLOCK_LOG_MSG, szCasterName, szSkillName, GlobalEventHandler.g_DamageType[dwDamageType], szTargetName)
    _t.Output_ex(--[[tag]]0, string.format("%d casted (%d, %d) to %d, blocked", dwCaster, dwID, dwLevel, dwTarget))
  end,

  OnSkillShieldLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    --local szMsg = FormatString(g_tStrings.STR_SKILL_SHIELD_LOG_MSG, szCasterName, szSkillName, szTargetName)
    _t.Output_ex(--[[tag]]0, string.format("%d casted (%d, %d) to %d, shield", dwCaster, dwID, dwLevel, dwTarget))
  end,

  OnSkillMissLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    --local szMsg = FormatString(g_tStrings.STR_SKILL_MISS_LOG_MSG, szCasterName, szSkillName)
    _t.Output_ex(--[[tag]]0, string.format("%d casted (%d, %d) to %d, missed", dwCaster, dwID, dwLevel, dwTarget))
  end,

  --- @param(dwCaster): caster id
  --- @param(dwTarget): target id
  --- @param(nEffectType): SKILL_EFFECT_TYPE.SKILL or BUFF
  --- @param(dwID): skill id
  --- @param(dwLevel): skill level
  OnSkillHitLog = function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    -- the message is null
    --local szMsg = FormatString(g_tStrings.STR_SKILL_HIT_LOG_MSG, szCasterName, szSkillName, szTargetName)
    _t.Output_ex(--[[tag]]0, string.format("%d casted (%d, %d), hit %d", dwCaster, dwID, dwLevel, dwTarget))
  end,

  OnSkillDodgeLog = function(dwCaster, dwTarget, nEffectType, dwID, dwLevel)
    --local szMsg = FormatString(g_tStrings.STR_SKILL_DODGE_LOG_MSG, szCasterName, szSkillName, szTargetName)
    _t.Output_ex(--[[tag]]0, string.format("%d casted (%d, %d) to %d, dodged", dwCaster, dwID, dwLevel, dwTarget))
  end,

  --- TODO: remove
  OnExpLog = function(dwPlayerID, nAddExp)
    --local szMsg = FormatString(g_tStrings.STR_EXP_YOU_GET_EXP_MSG, nAddExp)
    --OutputMessage("MSG_EXP", szMsg)
    _t.Output_ex(--[[tag]]0, string.format("%d get %d exp", dwPlayerID, nAddExp))
  end,

  --- @param(dwTarget): who get buff
  --- @param(bCanCancel): buff(true) or debuff(false)
  --- @param(dwID): buff id
  --- @param(bAddOrDel): (it's a int) add(1) or remove(0)
  --- @param(nLevel): buff level
  OnBuffLog = function(dwTarget, bCanCancel, dwID, bAddOrDel, nLevel)
    --Table_BuffIsVisible(dwID, nLevel)
    --local szBuffName = Table_GetBuffName(dwID, nLevel)
    --szMsg = FormatString(g_tStrings.STR_YOU_GET_SOME_EFFECT_MSG, szTargetName, szBuffName)
    --szMsg = FormatString(g_tStrings.STR_YOU_LOSE_SOME_EFFECT_MSG, szBuffName, szTargetName)
    _t.Output_ex(--[[tag]]0, string.format("buff(%s) (%d, %d) affact(%s) on %d", tostring(bCanCancel), dwID, nLevel, tostring(bAddOrDel), dwTarget))
    -- _t.module.data:RecordBuffLog(GetLogicFrameCount(), nil, dwTarget, {bCanCancel, dwID, nLevel}, bAddOrDel)
  end,

  OnBuffImmunity = function(dwTarget, bCanCancel, dwID, nLevel)
    --szMsg = FormatString(g_tStrings.STR_BUFF_IMMUNITY_LOG_MSG, szBuffName, szTargetName)
    _t.Output_ex(--[[tag]]0, string.format("buff (%d, %d) to %d, immunity", dwID, nLevel, dwTarget))
  end,

  OnDeathNotify = function(dwID, nLeftReviveFrame, szKiller)
    ----CreateRevivePanel(nLeftReviveFrame / GLOBAL.GAME_FPS)
    _t.Output_verbose(--[[tag]]0, string.format("%s killed %d, revive in %d", szKiller or "#nil", dwID, nLeftReviveFrame))
  end,

  OnSkillRespond = function(nRespondCode)
    --local szMsg = GlobalEventHandler.GetSkillRespondText(nRespondCode);OutputMessage("MSG_ANNOUNCE_RED", szMsg)
    --if nRespondCode == SKILL_RESULT_CODE.FORCE_EFFECT then OutputMessage("MSG_SKILL_SELF_FAILED", szMsg..g_tStrings.STR_FULL_STOP.."\n") end
  end,

  OnBuffUpdate = function(dwPlayerID, bAddOrDel, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, bInit, nBuffLevel, dwSkillSrcID)
    local now = GetLogicFrameCount()
    -- _t.Output_verbose(--[[tag]]0, string.format("buff(%s) (%d, %d) affact(%s) on %d by %d",
    --   tostring(bCanCancel), dwBuffID, nBuffLevel, tostring(bAddOrDel), dwPlayerID, dwSkillSrcID))
    -- out(dwPlayerID, bAddOrDel, nIndex, bCanCancel, dwBuffID, nCount, nEndFrame, nBuffLevel, dwSkillSrcID)
    if dwBuffID == 0 then return end
    if nEndFrame - now > 2*60*60*16 then return end
    if not Table_BuffIsVisible(dwBuffID, nBuffLevel) then return end
    _t.module.data:RecordBuffLog(now, dwSkillSrcID, dwPlayerID, {bCanCancel, dwBuffID, nBuffLevel}, not bAddOrDel, nEndFrame - now)
  end,
}

_t.module = Clouds_Flags
Clouds_Flags.record = _t
_t.Output = Clouds_Flags.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end
_t.Output_ex = function(...) _t.Output(_t.module.LEVEL.VERBOSEEX, ...) end

_t.GetSkillRespondText=function(nRespondCode)
  if nRespondCode == SKILL_RESULT_CODE.INVALID_CAST_MODE then return "INVALID_CAST_MODE"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_LIFE then return "NOT_ENOUGH_LIFE"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_MANA then return "NOT_ENOUGH_MANA"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_RAGE then return "NOT_ENOUGH_RAGE"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_ENERGY then return "NOT_ENOUGH_ENERGY"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_TRAIN then return "NOT_ENOUGH_TRAIN"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_STAMINA then return "NOT_ENOUGH_STAMINA"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_ITEM then return "NOT_ENOUGH_ITEM"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_AMMO then return "NOT_ENOUGH_AMMO"
  elseif nRespondCode == SKILL_RESULT_CODE.SKILL_NOT_READY then return "SKILL_NOT_READY"
  elseif nRespondCode == SKILL_RESULT_CODE.INVALID_SKILL then return "INVALID_SKILL"
  elseif nRespondCode == SKILL_RESULT_CODE.INVALID_TARGET then return "INVALID_TARGET"
  elseif nRespondCode == SKILL_RESULT_CODE.NO_TARGET then return "NO_TARGET"
  elseif nRespondCode == SKILL_RESULT_CODE.TOO_CLOSE_TARGET then return "TOO_CLOSE_TARGET"
  elseif nRespondCode == SKILL_RESULT_CODE.TOO_FAR_TARGET then return "TOO_FAR_TARGET"
  elseif nRespondCode == SKILL_RESULT_CODE.OUT_OF_ANGLE then return "OUT_OF_ANGLE"
  elseif nRespondCode == SKILL_RESULT_CODE.TARGET_INVISIBLE then return "TARGET_INVISIBLE"
  elseif nRespondCode == SKILL_RESULT_CODE.WEAPON_ERROR then return "WEAPON_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.WEAPON_DESTROY then return "WEAPON_DESTROY"
  elseif nRespondCode == SKILL_RESULT_CODE.AMMO_ERROR then return "AMMO_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_EQUIT_AMMO then return "NOT_EQUIT_AMMO"
  elseif nRespondCode == SKILL_RESULT_CODE.MOUNT_ERROR then return "MOUNT_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.IN_OTACTION then return "IN_OTACTION"
  elseif nRespondCode == SKILL_RESULT_CODE.ON_SILENCE then return "ON_SILENCE"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_FORMATION_LEADER then return "NOT_FORMATION_LEADER"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_ENOUGH_MEMBER then return "NOT_ENOUGH_MEMBER"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_START_ACCUMULATE then return "NOT_START_ACCUMULATE"
  --local skill = GetClientPlayer().GetKungfuMount() --shaolin
  --szMsg = skill and skill.dwMountType == 5 and g_tStrings.STR_ERROR_SKILL_NOT_FANJIZHI or g_tStrings.STR_ERROR_SKILL_NOT_START_ACCUMULATE
  elseif nRespondCode == SKILL_RESULT_CODE.SKILL_ERROR then return "SKILL_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.BUFF_ERROR then return "BUFF_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.NOT_IN_FIGHT then return "NOT_IN_FIGHT"
  elseif nRespondCode == SKILL_RESULT_CODE.MOVE_STATE_ERROR then return "MOVE_STATE_ERROR"
  --szMsg = FormatString(g_tStrings.STR_ERROR_SKILL_MOVE_STATE_ERROR, g_tStrings.tPlayerMoveState[player.nMoveState])
  elseif nRespondCode == SKILL_RESULT_CODE.DST_MOVE_STATE_ERROR then return "DST_MOVE_STATE_ERROR"
  --szMsg = target.nMoveState == MOVE_STATE.ON_DEATH and g_tStrings.STR_ERROR_SKILL_TARGET_ON_DEATH or
  --FormatString(g_tStrings.STR_ERROR_SKILL_DST_MOVE_STATE_ERROR, g_tStrings.tPlayerMoveState[target.nMoveState])
  elseif nRespondCode == SKILL_RESULT_CODE.ERROR_BY_HORSE then return "ERROR_BY_HORSE"
  --szMsg = player.bOnHorse and g_tStrings.STR_ERROR_SKILL_NOT_ON_HORSE or g_tStrings.STR_ERROR_SKILL_ON_HORSE
  elseif nRespondCode == SKILL_RESULT_CODE.BUFF_INVALID then return "BUFF_INVALID"
  elseif nRespondCode == SKILL_RESULT_CODE.FORCE_EFFECT then return "FORCE_EFFECT"
  elseif nRespondCode == SKILL_RESULT_CODE.BUFF_IMMUNITY then return "BUFF_IMMUNITY"
  elseif nRespondCode == SKILL_RESULT_CODE.TARGET_LIFE_ERROR then return "TARGET_LIFE_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.SELF_LIFE_ERROR then return "SELF_LIFE_ERROR"
  elseif nRespondCode == SKILL_RESULT_CODE.MAP_BAN then return "MAP_BAN"
  elseif nRespondCode == SKILL_RESULT_CODE.TARGET_STEALTH then return "TARGET_STEALTH"
  elseif nRespondCode == SKILL_RESULT_CODE.ERROR_BY_SPRINT then return "ERROR_BY_SPRINT"
  --szMsg = player.bSprintFlag and g_tStrings.STR_ERROR_SKILL_NOT_IN_SPRINT or g_tStrings.STR_ERROR_SKILL_IN_SPRINT
  else return "UNABLE_CAST" end
end

Clouds_Base.event.Add("SYS_MSG", function()
  local event = arg0
  if event == "UI_OME_SKILL_CAST_LOG" then _t.OnSkillCast(arg1, arg2, arg3)
  elseif event == "UI_OME_SKILL_CAST_RESPOND_LOG" then _t.OnSkillCastRespond(arg1, arg2, arg3, arg4)
  elseif event == "UI_OME_SKILL_EFFECT_LOG" then _t.OnSkillEffectLog(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
  elseif event == "UI_OME_SKILL_BLOCK_LOG" then _t.OnSkillBlockLog(arg1, arg2, arg3, arg4, arg5, arg6)
  elseif event == "UI_OME_SKILL_SHIELD_LOG" then _t.OnSkillShieldLog(arg1, arg2, arg3, arg4, arg5)
  elseif event == "UI_OME_SKILL_MISS_LOG" then _t.OnSkillMissLog(arg1, arg2, arg3, arg4, arg5)
  elseif event == "UI_OME_SKILL_HIT_LOG" then _t.OnSkillHitLog(arg1, arg2, arg3, arg4, arg5)
  elseif event == "UI_OME_SKILL_DODGE_LOG" then _t.OnSkillDodgeLog(arg1, arg2, arg3, arg4, arg5)
  elseif event == "UI_OME_COMMON_HEALTH_LOG" then _t.OnCommonHealthLog(arg1, arg2)
  elseif event == "UI_OME_BUFF_LOG" then _t.OnBuffLog(arg1, arg2, arg3, arg4, arg5)
  elseif event == "UI_OME_BUFF_IMMUNITY" then _t.OnBuffImmunity(arg1, arg2, arg3, arg4)
  elseif event == "UI_OME_SKILL_RESPOND" then _t.OnSkillRespond(arg1)
  end
end, "Clouds_Flags_record")

Clouds_Base.event.Add("BUFF_UPDATE", function()
  _t.OnBuffUpdate(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end, "Clouds_Flags_record")

--SYNC_ROLE_DATA_END

--[[

g_DamageType = {
  [SKILL_RESULT_TYPE.PHYSICS_DAMAGE]         = g_tStrings.STR_SKILL_PHYSICS_DAMAGE;
  [SKILL_RESULT_TYPE.SOLAR_MAGIC_DAMAGE]     = g_tStrings.STR_SKILL_SOLAR_MAGIC_DAMAGE;
  [SKILL_RESULT_TYPE.NEUTRAL_MAGIC_DAMAGE]   = g_tStrings.STR_SKILL_NEUTRAL_MAGIC_DAMAGE;
  [SKILL_RESULT_TYPE.LUNAR_MAGIC_DAMAGE]     = g_tStrings.STR_SKILL_LUNAR_MAGIC_DAMAGE;
  [SKILL_RESULT_TYPE.POISON_DAMAGE]       = g_tStrings.STR_SKILL_POISON_DAMAGE;
  [SKILL_RESULT_TYPE.REFLECTIED_DAMAGE]     = g_tStrings.STR_SKILL_REFLECTIED_DAMAGE;
}

g_TransferType = {
  [SKILL_RESULT_TYPE.TRANSFER_LIFE] = g_tStrings.STR_SKILL_LIFE;
  [SKILL_RESULT_TYPE.TRANSFER_MANA] = g_tStrings.STR_SKILL_MANA,
}

OnSkillDamageLog=function(dwCaster, dwTarget, bReact, nType, dwID, nLevel, bCriticalStrike, szDamage, tResult, nTotalDamage)
  local nEffectDamage = tResult[SKILL_RESULT_TYPE.EFFECTIVE_DAMAGE] or 0
  if nTotalDamage == nEffectDamage then
    szMsg = FormatString(g_tStrings.SKILL_DAMAGE_LOG,
      szCasterName, szSkillName, szCriticalStrike, szTargetName, szDamage)
  else
    szMsg = FormatString(g_tStrings.SKILL_EFFECT_DAMAGE_LOG,
      szCasterName, szSkillName, szCriticalStrike, szTargetName, szDamage, nEffectDamage)
  end
end;

OnSkillReflectiedDamageLog=function(dwCaster, dwTarget, nDamage)
  local szMsg = FormatString(g_tStrings.STR_SKILL_REFLECTIED_DAMAGE_LOG_MSG, szTargetName, szCasterName, nDamage)
end

OnSkillTherapyLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, bCriticalStrike, tResult)
  local nTherapy = tResult[SKILL_RESULT_TYPE.THERAPY] or 0
  local nEffectTherapy = tResult[SKILL_RESULT_TYPE.EFFECTIVE_THERAPY] or 0
  if nEffectTherapy == nTherapy then
    szMsg = FormatString(g_tStrings.SKILL_THERAPY_LOG,
      szCasterName, szSkillName, szCriticalStrike, szTargetName, nTherapy)
  else
    szMsg = FormatString(g_tStrings.SKILL_EFFECT_THERAPY_LOG,
      szCasterName, szSkillName, szCriticalStrike, szTargetName, nTherapy, nEffectTherapy)
  end
end

OnSkillStealLifeLog=function(dwCaster, dwTarget, nHealth)
  local szMsg = FormatString(g_tStrings.STR_SKILL_STEAL_LIFE_LOG_MSG, szCasterName, szTargetName, nHealth)
end

OnSkillDamageAbsorbLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
  local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_ABSORB_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
end

OnSkillDamageShieldLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
  local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_SHIELD_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
end

OnSkillDamageParryLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
  local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_PARRY_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
end

OnSkillDamageInsightLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage)
  local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_INSIGHT_LOG_MSG, szCasterName, szSkillName, szTargetName, nDamage)
end

OnSkillDamageTransferLog=function(dwCaster, dwTarget, nEffectType, dwID, dwLevel, nDamage, dwTransferType)
  local szMsg = FormatString(g_tStrings.STR_SKILL_DAMAGE_TRANSFER_LOG_MSG, szCasterName, szSkillName,
     szTargetName, nDamage, GlobalEventHandler.g_TransferType[dwTransferType])
end

]]
