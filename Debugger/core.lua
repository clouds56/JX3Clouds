local xv = Clouds_Base.xv
local out = Clouds_Base.xv.debug.out

local _t
_t = {
  NAME = "core",
}

_t.RegisterCode = function(_this, index, func)
  _this.OnItemLButtonDown = function(self)
    self = self or this
    local hh, s = self:GetParent(), Clouds_Base.debug.var2str(func())
    hh:AppendItemFromString(xv.api.GetFormatText(string.format("Out[%d]: %s\n", index, s), 0x00FFFF, nil, nil, "out"))
    hh:resize()
  end
end

_t.RegisterClearCode = function(_this)
  _this.OnItemLButtonDown = function(self)
    self = self or this
    local hh = self:GetParent()
    local itemCount = 0
    while itemCount ~= hh:GetItemCount() do
      itemCount = hh:GetItemCount()
      hh:RemoveItem("out")
    end
    hh:resize()
  end
end

function _t.RenderCode(index, code)
  local itemCount = 3
  local ss = {}
  table.insert(ss, xv.api.GetFormatText(string.format("In [%d]: %s", index, code), 0xFFFFFF, 771))
  table.insert(ss, xv.api.GetFormatText(" *Run* ", 0x0000FF, 771,
      string.format('local func=function()return %s end\nClouds_Debugger.core.RegisterCode(this, %d, func)', code, index), "code"))
  table.insert(ss, xv.api.GetFormatText(" *Clear* \n", 0x0000FF, 771,
      string.format('Clouds_Debugger.core.RegisterClearCode(this, %d)', itemCount), "code"))
  return ss
end

_t.module = Clouds_Debugger
Clouds_Debugger.core = _t
_t.module.base.gen_all_msg(_t)
