if not Clouds_Flags.DEBUG then
  return
end

local _t
_t = {
  OutputLast = function()
     out(_t.module.view.Analyze(_t.module.data._compat.skill, GetClientPlayer().dwID))
  end
}

_t.module = Clouds_Flags
Clouds_Flags.debug = _t
