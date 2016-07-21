local Table_GetBuffName = Table_GetBuffName
local GetLogicFrameCount = GetLogicFrameCount
local GetClientPlayer = GetClientPlayer

local _t
_t = {
  NAME = "api",
  Buff_ToString = function(self)
    local id, level, isbuff, endframe, index, stacknum, srcid, valid, stackable = unpack(self)
    local name, debuffheader = Table_GetBuffName(id, level) or "", isbuff and "" or "~"
    local endtime = endframe >= 2^31-1 and "forever" or xv.frame.tostring(endframe-GetLogicFrameCount())
    local stack = (stackable~=false or stacknum~=1) and string.format("x%d", stacknum) or ""
    local s = string.format("{ [%d]: %s%s(%d,%d) %s, last: %s, src: %d }",
      index, debuffheader, name, id, level, stack, endtime, srcid)
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
      table.insert(buffs, { __tostring = _t.Buff_ToString, target.GetBuff(i) })
    end
    return buffs
  end
}

_t.module = Clouds_Base
Clouds_Base.api = _t
_t.Output = Clouds_Base.base.gen_msg(_t.NAME)
_t.Output_verbose = function(...) _t.Output(_t.module.LEVEL.VERBOSE, ...) end

xv.api = {
  GetBuffList = _t.GetBuffList
}
