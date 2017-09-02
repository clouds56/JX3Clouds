local Table_GetBuffName = Table_GetBuffName
local GetLogicFrameCount = GetLogicFrameCount
local GetClientPlayer = GetClientPlayer
local GetFormatText = GetFormatText
local FireUIEvent = FireUIEvent
local xv = Clouds.xv

local _t
_t = {
  NAME = "api",
  Buff_ToString = function(self)
    local id, level, isbuff, endframe, index, stacknum, srcid, valid, stackable = unpack(self)
    local name, debuffheader = Table_GetBuffName(id, level) or "", isbuff and "" or "~"
    local endtime = endframe >= 2^31-1 and "forever" or xv.algo.frame.tostring(endframe-GetLogicFrameCount())
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
  end,
  COLOR = {
    Yellow          = 0xFFFF00,
    Red             = 0xFF0000,
    Green           = 0x00FF00,
    Blue            = 0x0000FF,
    LightBlue       = 0x0080FF,
    Orange          = 0xFF8000,
  },
  color_rgb_cache = {},
  ColorToRGB = function(color)
    if color == nil then
      return nil, nil, nil
    end
    if _t.color_rgb_cache[color] then
      return unpack(_t.color_rgb_cache[color])
    end
    _t.color_rgb_cache[color] = { (color/256/256)%256, (color/256)%256, color%256 }
    return unpack(_t.color_rgb_cache[color])
  end,
  GetFormatText = function(text, font, eventid, script, name)
    local color, f = font, nil
    if type(font) == "table" then
      color, f = unpack(font)
    end
    local r, g, b = _t.ColorToRGB(color)
    return GetFormatText(text, f, r, g, b, eventid, script, name)
  end,
  reload_keep = {},
  ReloadUIAddon = function()
    FireUIEvent("DISCONNECT")
    _G.ReloadUIAddon()
  end,
}

_t.module = Clouds.Base
Clouds.Base.api = _t
_t.module.base.gen_all_msg(_t)

xv.api = {
  GetBuffList = _t.GetBuffList,
  COLOR = _t.COLOR,
  ColorToRGB = _t.ColorToRGB,
  GetFormatText = _t.GetFormatText,
  ReloadUIAddon = _t.ReloadUIAddon,
}
