local Table_GetBuffName = Table_GetBuffName
local GetLogicFrameCount = GetLogicFrameCount
local GetClientPlayer = GetClientPlayer

local _t
_t = {
  NAME = "api",
  Buff_ToString = function(self)
    local id, level, isbuff, endframe, index, stacknum, skillid, flag1, flag2 = unpack(self)
    if flag1 ~= true or flag2 ~= false then
      _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, "Buff flag1(%s) and flag2(%s)", tostring(flag1), tostring(flag2))
    end
    local name, debuffheader = Table_GetBuffName(id, level) or "", isbuff and "" or "D:"
    local endtime = endframe >= 2^31-1 and "never" or xv.frame.tostring(endframe-GetLogicFrameCount())
    local s = string.format("{ %s%s(%d,%d), endtime: %s, index: %d, stacknum: %d, skillid: %d }",
      debuffheader, name, id, level, endtime, index, stacknum, skillid)
    if flag1 ~= true or flag2 ~= false then
      _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, "Buff flag1(%s) and flag2(%s) in %s", tostring(flag1), tostring(flag2), s)
    end
    return s
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
_t.Output = Clouds_Base.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end
