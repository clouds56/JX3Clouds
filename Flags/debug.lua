if not Clouds_Flags.DEBUG then
  return
end

local GetClientPlayer = GetClientPlayer

local _t
_t = {
  OutputLast = function()
     --xv.debug.out(_t.module.view.Analyze(_t.module.data.current_compat.skill, GetClientPlayer().dwID))
  end
}

_t.module = Clouds_Flags
Clouds_Flags.debug = _t
_t.module.base.gen_all_msg(_t)
