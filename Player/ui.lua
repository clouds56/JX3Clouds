local _L = Clouds_Player.lang.L
local CreateAddon = EasyUI.CreateAddon
local xv = Clouds_Base.xv
local NewPos = EasyUI.NewPos

local PopupMenu = PopupMenu

local _t
_t = {
  NAME = "ui",
  -- szIni = "interface/Clouds/Flags/ui.ini",
  current_name = "",
  current = nil,
  old_name = nil,
  old = nil,
  modified = false,
  default = {action = "hit", text = "", enable = true},
  true_f = function() return true end,
  hash_function = function(x) return x.name end,
  ui_manager = Clouds_Graphics.manager.EasyManager,

  type_sets = { "hit", "got", "casting" },

  reset = function()
      _t.current = xv.algo.table.clone(_t.default)
      _t.current_name = ""
      _t.old = nil
      _t.old_name = nil
  end,

  rehash = function(v)
    if not v then
      for i, v in ipairs(_t.tSkillSpeak) do
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
    x = xv.algo.table.clone(x)
    table.insert(t, x)
    if not t[x.action] then
      t[x.action] = {}
    end
    if x.enabled then
      table.insert(t[x.action], x)
    end
    return x
  end,

  update_text = function()
    _t.ui_manager:Fetch("M_SkillSpeak_Name"):SetText(_t.current_name)
    _t.ui_manager:Fetch("M_SkillSpeak_Content"):SetText(_t.current.text)
    for i, v in ipairs(_t.type_sets) do
      _t.ui_manager:Fetch("M_SkillSpeak_Type_" .. v):Check(_t.current.action == v)
    end
    _t.notify_modified()
  end,

  remove = function(v, k)
    xv.algo.table.remove_v(v, k)
    for _, t in ipairs(_t.type_sets) do
      xv.algo.table.remove_v(v[t] or {}, k)
    end
    if #v == 0 then
      _t.tSkillSpeak:remove(v.name)
    end
  end,

  get_menu = function(m)
    if not m then
      m = {}
    end
    table.insert(m, { szOption = _L("New"), fnAction = function()
      _t.reset()
      _t.update_text()
    end})
    table.insert(m, { bDevide = true }) -- Divide
    for i, v in ipairs(_t.tSkillSpeak) do
      local menuSkill = {
        szOption = v.name,
        bCheck = true,
        bChecked = v.enabled,
        fnAction = function()
          v.enabled = not v.enabled
        end,
        {
          szOption = "Delete", fnAction = function() _t.tSkillSpeak:remove_i(i) end,
        },
      }
      for _, a in ipairs(_t.type_sets) do
        if #v >= 5 then
          table.insert(menuSkill, { bDevide = true }) -- Divide
          table.insert(menuSkill, { szOption = _L(a), fnDisable = _t.true_f })
        end
      for _, k in ipairs(v) do
      if k.action == a then
        if #v < 5 then
          table.insert(menuSkill, { bDevide = true }) -- Divide
        end
        local menuSpeak = {
          szOption = k.text:sub(1, 20),
          bCheck = true,
          bChecked = k.enabled,
          fnAction = function()
            k.enabled = not k.enabled
            local t = v[k.action]
            if not t then
              t = {}
              v[k.action] = t
            end
            if k.enabled then
              table.insert(t, k)
            else
              xv.algo.table.remove_v(t, k)
            end
          end
        }
        table.insert(menuSkill, menuSpeak)
        if #v < 5 then
          menuSpeak = menuSkill
          table.insert(menuSpeak, {
            szOption = "  " .. _L(k.action),
            fnDisable = _t.true_f,
          })
        end
        table.insert(menuSpeak, {
          szOption = "  " .. _L("Modify"),
          fnAction = function()
            _t.current = xv.algo.table.clone(k)
            _t.old = k
            _t.current_name = v.name
            _t.old_name = v.name
            _t.update_text()
          end
        })
        table.insert(menuSpeak, {
          szOption = "  " .. _L("Delete"),
          fnAction = function()
            _t.remove(v, k)
            -- _t.current = _t.default
            -- _t.current_name = ""
            -- _t.update_text()
          end
        })
      end
      end
      end
      table.insert(m, menuSkill)
    end
    return m
  end,

  notify_modified = function()
    if _t.old then
      _t.modified = _t.old_name ~= _t.current_name or _t.old.text ~= _t.current.text or _t.old.action ~= _t.current.action
    end
    _t.ui_manager:Fetch("M_SkillSpeak_Save"):Enable(_t.old ~= nil and _t.modified)
  end
}

_t.reset()
_t.tSkillSpeak = xv.algo.ordered_hash.new(_t.hash_function, {
  {name = "Test1", {text = "Hello", action = "hit", enabled = true},},
  {name = "Test2", },
  {name = "Test3", },
  {name = "Test4", },
})
_t.rehash()

_t.module = Clouds_Player
Clouds_Player.ui = _t
Clouds_Player.base.gen_all_msg(_t)

local empty_f = function() end
local true_f = function() return true end

local function init()
  local pos = NewPos(0, 0, 5)
  local tSkillMonConfig = {
    szName = "SkillMon",
    szTitle = _L("SkillMon"),
    dwIcon = 80,
    szClass = "Combat",
    tWidget = {
      {
        name = "M_SkillSpeak_Title", type = "Text", rect = pos:Next(80, 28), text = _L("SkillSpeakTitle"), font = 136,
      },
      {
        name = "M_SkillSpeak_Options", type = "Text", rect = pos:NextLine(30, 100, 25), text = "Options", font = 140,
      },{
        name = "M_SkillSpeak_Enable", type = "CheckBox", rect = pos:NextLine(nil, 200, 25), text = _L("SkillSpeakEnabled"), font = 140, default = true_f,
      },{
        name = "M_SkillSpeak_All", type = "ComboBox", rect = pos:Next(200, 25), text = _L("Setup"), font = 140, callback = function(m)
          _t.get_menu(m)
          PopupMenu(m)
        end,
      },{
        name = "M_SkillSpeak_NameText", type = "Text", rect = pos:NextLine(nil, 120, 25), text = _L("SkillName"), font = 140,
      },{
        name = "M_SkillSpeak_Name", type = "Edit", rect = pos:Next(160, 25), font = 140, default =  function() return _t.current_name end, callback = function(n)
          _t.current_name = n
          _t.notify_modified()
        end,
      },{
        name = "M_SkillSpeak_TypeText", type = "Text", rect = pos:NextLine(nil, 120, 25), text = _L("SkillAction"), font = 140,
      },{
        name = "M_SkillSpeak_Type_hit", type = "RadioBox", rect = pos:Next(60, 25), text = _L("Hit"), font = 140, default =  function() return _t.current.action == "hit" end, callback = function(n)
          _t.current.action = "hit"
          _t.notify_modified()
        end, group = "SkillSpeak_type",
      },{
        name = "M_SkillSpeak_Type_got", type = "RadioBox", rect = pos:Next(60, 25), text = _L("Got"), font = 140, default = function() return _t.current.action == "got" end, callback = function(n)
          _t.current.action = "got"
          _t.notify_modified()
        end, group = "SkillSpeak_type",
      },{
        name = "M_SkillSpeak_Type_casting", type = "RadioBox", rect = pos:Next(60, 25), text = _L("Casting"), font = 140, default = function() return _t.current.action == "casting" end, callback = function(n)
          _t.current.action = "casting"
          _t.notify_modified()
        end, group = "SkillSpeak_type",
      },{
        name = "M_SkillSpeak_Content", type = "Edit", rect = pos:NextLine(nil, 400, 60), font = 140, default = function() return _t.current.text end, callback = function(n)
          _t.current.text = n
          _t.notify_modified()
        end,
      },{
        name = "M_SkillSpeak_Add", type = "Button", rect = pos:NextLine(nil, 80, 25), text = _L("Add"), font = 140, callback = function(n)
          local n = _t.current_name
          if not n then
            return
          end
          if n:sub(1, 1) == "[" and n:sub(-1) == "]" then
            n = n:sub(2, -2)
          end
          if n ~= "" then
            local t = _t.tSkillSpeak:get(n)
            if not t then
              t = {name = n, hit = {}, got = {}, casting = {}}
              _t.tSkillSpeak:push(t)
            end
            _t.old = _t.add_text(t, _t.current)
          end
        end,
      },{
        name = "M_SkillSpeak_Save", type = "Button", rect = pos:Next(80, 25), text = _L("Save"), font = 140, enable = function() return _t.old and _t.modified end, callback = function(n)
          local n = _t.current_name
          if n and n:sub(1, 1) == "[" and n:sub(-1) == "]" then
            n = n:sub(2, -2)
          end
          if not n or n == "" then
            return
          end
          local t = _t.tSkillSpeak:get(n)
          if not t then
            t = {name = n, hit = {}, got = {}, casting = {}, enabled = true}
            _t.tSkillSpeak:push(t)
          end
          if n ~= _t.old_name then
            local old_t = _t.tSkillSpeak:get(_t.old_name)
            if old_t then
              _t.remove(old_t, _t.old)
            end
            _t.old = _t.add_text(t, _t.current)
            _t.old_name = n
          else
            if xv.algo.table.in_(t, _t.old) then
              _t.old.text = _t.current.text
              if _t.old.action ~= _t.current.action then
                _t.old.action = _t.current.action
                xv.algo.table.remove_v(t[_t.old.action] or {}, _t.old)
                if not t[_t.current.action] then
                  t[_t.current.action] = {}
                end
                if _t.current.enabled then
                  table.insert(t[_t.current.action], _t.current)
                end
              end
            else
              _t.old = _t.add_text(t, _t.current)
            end
          end
          _t.notify_modified()
        end,
      },{
        name = "M_SkillSpeak_Reset", type = "Button", rect = pos:Next(80, 25), text = _L("Reset"), font = 140, callback = function(n)
          _t.reset()
          _t.update_text()
        end,
      },
    },
  }
  _t.ui_manager:RegisterPanel(tSkillMonConfig)
end

local Base = Clouds_Base
Base.event.Add("LOGIN_GAME", init, "Clouds_Player_ui")

Base.event.Add("LOADING_END", function()
  if _t.module.DEBUG then
    -- _t.Output_verbose(--[[tag]]0, "Open BattleLog Panel")
    -- Base.event.Delay(1, function()_t.BattleLog:OpenPanel()end, "Clouds_Flags_ui_open")
  end
end, "Clouds_Player_ui")
