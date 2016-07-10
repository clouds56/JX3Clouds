local _t
_t = {
  Buff_ToString = function(self)
    local id, level, isbuff, endframe, index, stacknum, skillid, valid, visible = unpack(self)
    out(unpack(self))
    local name, visibleflag, debuffflag = Table_GetBuffName(id, level) or "", visible and "" or "*", isbuff and "" or "D:"
    local endtime = endframe == 2^31-1 and "never" or ("%.2f"):format(endframe-GetLogicFrameCount()/16)
    return string.format("{ %s%s%s(%d,%d), endtime: %s, index: %d, stacknum: %d, skillid: %d, valid: %s }",
      visibleflag, debuffflag, name, id, level, endtime, index, stacknum, skillid, tostring(valid))
  end,
  GetBuffList = function(target)
    target = target or GetClientPlayer()
    if not target then
      return nil
    end
    local buffs = {}
    local count = target.GetBuffCount()
    for i = 0, count - 1 do
      table.insert(buffs, { tostring = _t.Buff_ToString, target.GetBuff(i) })
    end
    return buffs
  end
}

_t.module = Clouds_Base
Clouds_Base.api = _t
