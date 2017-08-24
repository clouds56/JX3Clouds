local _L = Clouds_Player.lang.L
local CreateAddon = EasyUI.CreateAddon
local xv = Clouds_Base.xv

local PopupMenu = PopupMenu

local _t
_t = {
  NAME = "ui",
  -- szIni = "interface/Clouds/Flags/ui.ini",
  current_name = nil,
  current = {action = "hit", text = "", enabled = true},
  hash_function = function(x) return x.name end,
  ui_manager = Clouds_Graphics.manager.EasyManager,

  add_text = function(t, action, text, disable)
    local x = {action = action, text = text, enabled = not disable}
    table.insert(t, x)
    if not t[action] then
      t[action] = {}
    end
    if x.enabled then
      table.insert(t[action], x)
    end
  end,

  update_text = function()
    _t.ui_manager:Fetch("M_SkillSpeak_Name"):SetText(_t.current_name)
    _t.ui_manager:Fetch("M_SkillSpeak_Content"):SetText(_t.current.text)
    _t.ui_manager:Fetch("M_SkillSpeak_TypeHit"):Check(_t.current.action == "hit")
    _t.ui_manager:Fetch("M_SkillSpeak_TypeGot"):Check(_t.current.action == "got")
    _t.ui_manager:Fetch("M_SkillSpeak_TypeCasting"):Check(_t.current.action == "casting")
  end,
}

_t.tSkillSpeak = xv.algo.ordered_hash.new(_t.hash_function, {
  {name = "Test1", {text = "Hello", action = "hit", enabled = true},},
  {name = "Test2", },
  {name = "Test3", },
  {name = "Test4", },
})

_t.module = Clouds_Player
Clouds_Player.ui = _t
Clouds_Player.base.gen_all_msg(_t)

local empty_f = function() end
local true_f = function() return true end

local function init()
  local pos = EasyUI.NewPos(0, 0, 5)
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
          table.insert(m, { szOption = "Add", fnDisable = function() return true end })
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
            for _, k in ipairs(v) do
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
                    for i, v in ipairs(t) do
                      if v == k then
                        table.remove(v[t], i)
                        break
                      end
                    end
                  end
                end
              }
              table.insert(menuSkill, menuSpeak)
              if #v < 5 then
                menuSpeak = menuSkill
              end
              table.insert(menuSpeak, {
                szOption = "  " .. _L(k.action),
                fnDisable = true_f,
              })
              table.insert(menuSpeak, {
                szOption = "  " .. _L("Modify"),
                fnAction = function()
                  _t.current = k
                  _t.current_name = v.name
                  _t.update_text()
                end
              })
            end
            table.insert(m, menuSkill)
          end
          PopupMenu(m)
        end,
      },{
        name = "M_SkillSpeak_NameText", type = "Text", rect = pos:NextLine(nil, 120, 25), text = _L("SkillName"), font = 140,
      },{
        name = "M_SkillSpeak_Name", type = "Edit", rect = pos:Next(160, 25), font = 140, default =  function() return _t.current_name end, callback = function(n)
          _t.current_name = n
        end,
      },{
        name = "M_SkillSpeak_Add", type = "Button", rect = pos:Next(80, 25), text = _L("Add"), font = 140, callback = function(n)
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
            _t.add_text(t, _t.current.action, _t.current.text)
          end
        end,
      },{
        name = "M_SkillSpeak_TypeText", type = "Text", rect = pos:NextLine(nil, 120, 25), text = _L("SkillAction"), font = 140,
      },{
        name = "M_SkillSpeak_TypeHit", type = "RadioBox", rect = pos:Next(60, 25), text = _L("Hit"), font = 140, default =  function() return _t.current.action == "hit" end, callback = function(n)
          _t.current.action = "hit"
        end, group = "SkillSpeak_type",
      },{
        name = "M_SkillSpeak_TypeGot", type = "RadioBox", rect = pos:Next(60, 25), text = _L("Got"), font = 140, default = function() return _t.current.action == "got" end, callback = function(n)
          _t.current.action = "got"
        end, group = "SkillSpeak_type",
      },{
        name = "M_SkillSpeak_TypeCasting", type = "RadioBox", rect = pos:Next(60, 25), text = _L("Casting"), font = 140, default = function() return _t.current.action == "casting" end, callback = function(n)
          _t.current.action = "casting"
        end, group = "SkillSpeak_type",
      },{
        name = "M_SkillSpeak_Content", type = "Edit", rect = pos:NextLine(nil, 400, 60), font = 140, default = function() return _t.current.text end, callback = function(n)
          _t.current.text = n
        end,
      }
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
