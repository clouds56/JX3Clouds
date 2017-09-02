local xv = Clouds_Base.xv
local enum = Clouds_Base.enum

local _t
_t = {
  NAME = "data",
  loaded = false,

  speak = {},
  hash_function = function(x) return x.name end,
  type_sets = { "hit", "got", "casting" },
  rehash = function(v)
    if not v then
      for i, v in ipairs(_t.speak) do
        _t.rehash(v)
      end
    else
      for _, k in ipairs(v) do
        if k.enabled == true then
          if not v[k.action] then
            v[k.action] = {}
          end
          table.insert(v[k.action], k)
        end
      end
    end
  end,
  add_text = function(t, x)
    local found = false
    x = xv.algo.table.clone(x)
    for i, v in ipairs(t) do
      if v.action == x.action and v.text == x.text then
        v.enabled = x.enabled
        x = v
        found = true
      end
    end
    if not found then
      table.insert(t, x)
    end
    if not t[x.action] then
      t[x.action] = {}
    end
    if x.enabled then
      table.insert(t[x.action], x)
    end
    return x
  end,
  remove = function(v, k)
    xv.algo.table.remove_v(v, k)
    for _, t in ipairs(_t.type_sets) do
      xv.algo.table.remove_v(v[t] or {}, k)
    end
    if #v == 0 then
      _t.speak:remove(v.name)
    end
  end,
  get = function(n, force)
    if not n or n == "" then return end
    local t = _t.speak:get(n)
    if not t and force then
      t = {name = n, hit = {}, got = {}, casting = {}, enabled = true}
      _t.speak:push(t)
    end
    return t
  end,

  init_data = {
    [enum.FORCE_TYPE.WAN_HUA] = { 101, 139 },
  },
  initialize = function()
    _t.speak = xv.algo.ordered_hash.new(_t.hash_function, {})
    local me = GetClientPlayer()
    for i, v in ipairs(_t.init_data[me.dwForceID] or {}) do
      local skill = Table_GetSkill(v)
      if skill and skill.szName and skill.szName ~= "" then
        local desc = skill.szSpecialDesc
        if not desc or desc == "" then
          desc = skill.szName
        end
        local t = _t.get(skill.szName, true)
        _t.add_text(t, {action = "hit", text = desc, enabled = true})
      end
    end
  end
}

_t.module = Clouds_Player
Clouds_Player.data = _t
_t.module.base.gen_all_msg(_t)

Clouds_Base.event.Add("LOADING_END", function()
  if _t.loaded == true then
    return
  end
  _t.loaded = true
  _t.initialize()
end, "Clouds_Player_data")
