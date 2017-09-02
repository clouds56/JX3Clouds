if not Clouds.Flags.DEBUG then
  return
end

local GetClientPlayer = GetClientPlayer

local _t
_t = {
  OutputLast = function()
     --xv.debug.out(_t.module.view.Analyze(_t.module.data.current_compat.skill, GetClientPlayer().dwID))
  end
}

_t.module = Clouds.Flags
Clouds.Flags.debug = _t
Clouds.Base.base.gen_all_msg(_t)
