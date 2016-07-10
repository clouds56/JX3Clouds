local _t
_t = {
  NAME = "event",

  --- tMonitor[event][tag] = { func, enabled, called, errored }
  tMonitor = {},

  tDelay = {},
  szIni="interface/Clouds/Base/event.ini",
}

_t.module = Clouds_Base
Clouds_Base.event = _t
_t.Output = _t.module.base.gen_msg(_t.NAME)

--- Generate system monitor that call all functions in tMonitor[event]
--- @param(event): system event name, if begin with MESSAGE, call GenNewMsgMonitor additionally
function _t.GenNewMonitor(event)
  -- TODO: make sure there's only one call per event through RELOADING
  -- broken
  if not _t.tMonitor then
    return
  end

  if not _t.tMonitor[event] then
    _t.tMonitor[event] = {}
  end

  -- not first loading end
  if not _t.ui or not _t.ui.Monitors then
    return
  end

  -- already registered
  if _t.ui.Monitors[event] then
    return
  end

  -- redirect message to event register
  if event and event:find("^MESSAGE") then
    _t.GenNewMsgMonitor(event)
  end

  local monitors, monitor = _t.ui.Monitors, nil
  monitor = function(...)
    -- TODO: no need for check?
    if _t.ui and _t.ui.Monitors and _t.ui.Monitors[event] ~= monitor then
      if _t.ui.Monitors[event] == nil then
        _t.ui.Monitors[event] = monitor
      else
        _t.Output(_t.module.LEVEL.VERBOSE, "not mulitple monitor running default: %s, current: %s", tostring(_t.ui.Monitors[event]), tostring(monitor))
        return
      end
    end

    for i, v in pairs(_t.tMonitor[event] or {}) do
      if v[2] then
        local b, s = pcall(v[1], ...)
        v[3] = v[3] + 1
        if not b then
          FireUIEvent("CALL_LUA_ERROR", s)
          _t.Output(_t.module.LEVEL.WARNING, s)
          v[4] = v[4] + 1
          v[5] = s
        end
      end
    end
  end
  RegisterEvent(event, monitor)
  _t.ui.Monitors[event] = monitor
end

--- Add a monitoring function on event into tMonitor[event]
--- @param(event): the event name
--- @param(func): the monitor function
--- @param(tag): the index of function in tMonitor[event]
--- @remark: the tag should not be "all", if it is null, the func itself would be the tag.
function _t.Add(event, func, tag)
  tag = tag or func
  if not _t.tMonitor then
    return
  end
  if not _t.tMonitor[event] then
    _t.GenNewMonitor(event)
  end
  _t.tMonitor[event][tag] = { func, true, 0, 0 }
end

--- Remove a monitoring function on event
--- @param(event): the event name
--- @param(tag): the index of function
--- @remark: if the tag is null, return, if it is "all", remove all the monitor
function _t.Remove(event, tag)
  if _t.module.DEBUG then
    tag = tag or "test"
  end
  if not tag then
    return
  end
  if not _t.tMonitor or not _t.tMonitor[event] then
    return
  end
  if tag == "all" then
    _t.tMonitor[event] = nil
  end
  _t.tMonitor[event][tag] = nil
end

--- Remove
function _t.RemoveAll(tag)
  tag = tag or "test"
  if not _t.tMonitor then
    return
  end
  for i, v in pairs(_t.tMonitor) do
    _t.Remove(i, tag)
  end
end

function _t.Last(event, lasttime, func, tag)
  -- TODO: remove tag also remove delay?
  tag = tag or func
  _t.Add(event, func, tag)
  _t.Delay(lasttime,
    function() _t.Remove(event, tag) end,
    "Clouds_Delay_" .. tostring(tag) .. "_" .. GetLogicFrameCount())
end

function _t.LastEvery(everytime,lasttime,func,tag)
  tag = tag or func
  local n, k = lasttime/everytime, 0
  _t.Every(everytime,function(...)
    k = k + 1
    if n > k then
      -- TODO: error log
      local b, s= pcall(func, ...)
      if not b then
        FireUIEvent("CALL_LUA_ERROR", s)
      end
    else
      _t.Remove("CLOUDS_FRAME_BREATHE", tag)
    end
  end, tag)
end

function _t.Every(everytime, func, tag)
  local starttime=GetLogicFrameCount()
  if not func then
    -- TODO: do we need this?
    return
  end
  _t.Add("CLOUDS_FRAME_BREATHE", function(...)
    if (GetLogicFrameCount()-starttime)%everytime==0 then
      pcall(func, ...)
    end
  end, tag)
end

function _t.Delay(time, func, tag)
  time = time or 0
  if time < 0 then
    return
  end
  if not func then
    -- TODO: do we need this?
    return
  end
  tag = tag or GetLogicFrameCount()
  _t.tDelay[tag] = { func, GetLogicFrameCount() + time }
end

function _t.RemoveDelay(tag)
  -- TODO: test
  _t.tDelay[tag] = nil
end

Clouds_Base_Event = {}
function Clouds_Base_Event.OnFrameBreathe()
  FireUIEvent("CLOUDS_FRAME_BREATHE")
  local now = GetLogicFrameCount()
  for i, v in pairs(_t.tDelay) do
    if v[2] <= now then
      -- TODO: log error
      pcall(v[1])
      _t.tDelay[i] = nil
    end
  end
end

--- (Dprecated) Add monitor on opening a dialog when intract with NPC
function _t.AddSelect(npc, string, pattern, tag)
  if not _t.module.DEPRECATED then
    return
  end
  tag = tag or tostring(npc) .. "::" .. tostring(string) .. "<<" .. tostring(pattern)
  _t.Add("OPEN_WINDOW",function()
    if npc and arg3~=npc then
      local target=Clouds_API.GetPNDByID(arg3)
      if not target or target.szName~=npc then return end
    end
    if string and not arg1:find(string) then return end
    Clouds_API.WindowSelect(arg0, arg1, pattern)
  end, tag)
end

--- (Dprecated) Remove monitor on opening a dialog when intract with NPC
function _t.RemoveSelect(tag)
  if not _t.module.DEPRECATED then
    return
  end
  _t.Remove("OPEN_WINDOW", tag)
end

--- Create system message monitor that call all functions in tMonitor[event]
function _t.GenNewMsgMonitor(event)
  -- the system channel name
  channel = event:gsub("MESSAGE", "MSG", 1)
  if not _t.tMonitor or _t.tMonitor[event] then
    return
  end
  _t.tMonitor[event] = {}
  if monitors[event] ~= monitor then
    if monitors[event] == nil then
      monitors[event] = monitor
    else
      return
    end
  end

  RegisterMsgMonitor(function(message, font, rich, r, g, b)
    FireUIEvent(event, message, rich, font, {r, g, b})
  end, {channel})
end

-- TODO: once
RegisterEvent("LOADING_END", function()
  if _t.ui then
    return
  end
  local ui = Station.Lookup("Lowest/Clouds_Base_Event")
  if not ui then
    ui = Wnd.OpenWindow(_t.szIni, "Clouds_Base_Event")
  end

  _t.ui = ui
  _t.ui.Monitors = {}
  for i, v in pairs(_t.tMonitor) do
    _t.GenNewMonitor(i)
  end
  _t.Output(_t.module.LEVEL.VERBOSE, "LOADING_END")
end)


_t.UI = {}

function _t.UI.GetMenu(name)
  -- TODO: what is name for?
  if not _t.module.DEBUG then
    return
  end
  local menu = {}
  name = "tDelay"
  local submenu = {szOption = name}
  for i,v in pairs(_t.tDelay) do
    table.insert(submenu,{
      szOption=i,
      {szOption=tostring((v[2]-now)/16)},
      {szOption=tostring(v[1])},
    })
  end
  table.insert(menu,submenu)
  for name,t in pairs(_t.tMonitor) do
    submenu={szOption=name}
    for i,v in pairs(t or {}) do
      table.insert(submenu,{
        szOption=string.format("[%d]%s",v[4],tostring(i)),
        bCheck=true,
        bChecked=v[2],
        fnAction=function()
          v[2]=not v[2]
        end,
        {szOption=tostring(v[1])},
        {szOption=v[4].."/"..v[3]},
        v[5] and {szOption=v[5]:sub(1,50),bCheck=true,fnAction=function()_t.Output(v[5]) v[5]=nil end},
      })
    end
    table.insert(menu,submenu)
  end
  return menu
end
