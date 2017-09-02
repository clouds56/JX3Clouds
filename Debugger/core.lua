local xv = Clouds.xv
local out = Clouds.debug.out

local _t
_t = {
  NAME = "core",
  inputs = {},
  results = {},
  allResults = false,
  outformat = "_d%s",
  outlast = "_d",
  outbox = {},
  index = 1,
}

_t.RegisterCode = function(_this, index, data, func)
  _t.inputs[index] = func
  _this.data = data
end

_t.RegisterRunCode = function(_this, index)
  local subIndex = 1
  if _t.allResults then
    _t.allResults[index] = {}
  end
  _this.OnItemLButtonDown = function(self)
    self = self or this
    local func = _t.inputs[index]
    if not func then return end
    local result = {func()}
    _t.results[index] = result
    if _t.allResults then
      _t.allResults[index][subIndex] = result
    end
    _t.outbox[_t.outlast] = result[1]
    _t.outbox[_t.outformat:format(index)] = result[1]
    local hh, s = self:GetParent(), Clouds.debug.var2str(unpack(result))
    hh:AppendItemFromString(xv.api.GetFormatText(string.format("Out[%d]: %s\n", index, s), 0x00FFFF, nil, nil, "out"))
    hh:resize()
    subIndex = subIndex + 1
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

_t.RegisterEditCode = function(_this)
  _this.OnItemLButtonDown = function(self)
    self = self or this
    local hh = self:GetParent()
    hh:edit()
  end
end

_t.RegisterRemoveCode = function(_this)
  _this.OnItemLButtonDown = function(self)
    self = self or this
    local hh = self:GetParent()
    hh:remove()
  end
end

function _t.RenderCode(hh, code, callbacks)
  local codeTrim = code:trim()
  local head, rtn = codeTrim:match("(.*)[;\n](.*)")
  if not rtn then
    head, rtn = "", codeTrim
  end
  local codeExec = head .. ("\nreturn " .. rtn)
  hh:AppendItemFromString(xv.api.GetFormatText(string.format("In [%d]: %s", _t.index, codeTrim), 0xFFFFFF, 0,
      string.format("local func=function() %s end\nClouds.Debugger.core.RegisterCode(this, %d, %s, func)", codeExec, _t.index, EncodeComponentsString(code)), "in"))
  hh:AppendItemFromString(xv.api.GetFormatText(" *#* ", 0x0000FF, 771,
      string.format('Clouds.Debugger.core.RegisterRunCode(this, %d)', _t.index), "code"))
  hh:AppendItemFromString(xv.api.GetFormatText(" *!* ", 0xFF00FF, 771,
      string.format('Clouds.Debugger.core.RegisterClearCode(this, %d)', _t.index), "code"))
  hh:AppendItemFromString(xv.api.GetFormatText(" *@* ", 0xFF00FF, 771,
      string.format('Clouds.Debugger.core.RegisterEditCode(this, %d)', _t.index), "code"))
  hh:AppendItemFromString(xv.api.GetFormatText("*X*\n", 0xFF0000, 771,
      string.format('Clouds.Debugger.core.RegisterRemoveCode(this, %d)', _t.index), "code"))
  hh.resize = callbacks.resize
  hh.remove = callbacks.remove
  hh.edit = callbacks.edit
  hh.run = function(self)
    self:Lookup(1):OnItemLButtonDown()
  end
  hh.clear = function(self)
    self:Lookup(2):OnItemLButtonDown()
  end
  _t.index = _t.index + 1
end

_t.module = Clouds.Debugger
Clouds.Debugger.core = _t
_t.module.base.gen_all_msg(_t)

if _t.module.DEBUG then
  _G["_dout"] = _t.results
  _G["_din"] = _t.inputs
  _t.outbox = _G
  _t.allResults = {}
end
