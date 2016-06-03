local _ = Clouds_Base

_.event = {
  --- tMonitor[event][tag] = { func, enabled, called, errored }
  tMonitor = {},

  tDelay = {},
  szIni="interface/Clouds/Base/event.ini",
}

--- Generate system monitor that call all functions in tMonitor[event]
--- @param(event): system event name, if begin with MESSAGE, call GenNewMsgMonitor additionally
function _.event.GenNewMonitor(event)
  -- TODO: make sure there's only one call per event through RELOADING
  -- broken
  if not _.event.tMonitor then
    return
  end

  if not _.event.tMonitor[event] then
    _.event.tMonitor[event] = {}
  end

  -- not first loading end
  if not _.event.ui or not _.event.ui.Monitors then
    return
  end

  -- already registered
  if _.event.ui.Monitors[event] then
    return
  end

  -- redirect message to event register
  if event and event:find("^MESSAGE") then
    _.event.GenNewMsgMonitor(event)
  end

  local monitors, monitor = _.event.ui.Monitors, nil
  monitor = function(...)
    -- TODO: no need for check?
    if _.event.ui and _.event.ui.Monitors and _.event.ui.Monitors[event] ~= monitor then
      if _.event.ui.Monitors[event] == nil then
        _.event.ui.Monitors[event] = monitor
      else
        _.event.Output(_.LEVEL.VERBOSE, "not mulitple monitor running default: %s, current: %s", tostring(_.event.ui.Monitors[event]), tostring(monitor))
        return
      end
    end

    for i, v in pairs(_.event.tMonitor[event] or {}) do
      if v[2] then
        local b, s = pcall(v[1], ...)
        v[3] = v[3] + 1
        if not b then
          FireUIEvent("CALL_LUA_ERROR", s)
          _.event.Output(_.LEVEL.WARNING, s)
          v[4] = v[4] + 1
          v[5] = s
        end
      end
    end
  end
  RegisterEvent(event, monitor)
  _.event.ui.Monitors[event] = monitor
end

--- Add a monitoring function on event into tMonitor[event]
--- @param(event): the event name
--- @param(func): the monitor function
--- @param(tag): the index of function in tMonitor[event]
--- @remark: the tag should not be "all", if it is null, the func itself would be the tag.
function _.event.Add(event, func, tag)
  tag = tag or func
  if not _.event.tMonitor then
    return
  end
  if not _.event.tMonitor[event] then
    _.event.GenNewMonitor(event)
  end
  _.event.tMonitor[event][tag] = { func, true, 0, 0 }
end

--- Remove a monitoring function on event
--- @param(event): the event name
--- @param(tag): the index of function
--- @remark: if the tag is null, return, if it is "all", remove all the monitor
function _.event.Remove(event, tag)
  if _.DEBUG then
    tag = tag or "test"
  end
  if not tag then
    return
  end
  if not _.event.tMonitor or not _.event.tMonitor[event] then
    return
  end
  if tag == "all" then
    _.event.tMonitor[event] = nil
  end
  _.event.tMonitor[event][tag] = nil
end

--- Remove
function _.event.RemoveAll(tag)
  tag = tag or "test"
  if not _.event.tMonitor then
    return
  end
  for i, v in pairs(_.event.tMonitor) do
    _.event.Remove(i, tag)
  end
end

function _.event.Last(event, lasttime, func, tag)
  -- TODO: remove tag also remove delay?
  tag = tag or func
  _.event.Add(event, func, tag)
  _.event.Delay(lasttime,
    function() _.event.Remove(event, tag) end,
    "Clouds_Delay_" .. tostring(tag) .. "_" .. GetLogicFrameCount())
end

function _.event.LastEvery(everytime,lasttime,func,tag)
  tag = tag or func
  local n, k = lasttime/everytime, 0
  _.event.Every(everytime,function(...)
    k = k + 1
    if n > k then
      -- TODO: error log
      local b, s= pcall(func, ...)
      if not b then
        FireUIEvent("CALL_LUA_ERROR", s)
      end
    else
      _.event.Remove("CLOUDS_FRAME_BREATHE", tag)
    end
  end, tag)
end

function _.event.Every(everytime, func, tag)
  local starttime=GetLogicFrameCount()
  if not func then
    -- TODO: do we need this?
    return
  end
  _.event.Add("CLOUDS_FRAME_BREATHE", function(...)
    if (GetLogicFrameCount()-starttime)%everytime==0 then
      pcall(func, ...)
    end
  end, tag)
end

function _.event.Delay(time, func, tag)
  time = time or 0
  if time < 0 then
    return
  end
  if not func then
    -- TODO: do we need this?
    return
  end
  tag = tag or GetLogicFrameCount()
  _.event.tDelay[tag] = { func, GetLogicFrameCount() + time }
end

function _.event.RemoveDelay(tag)
  -- TODO: test
  _.event.tDelay[tag] = nil
end

Clouds_Base_Event = {}
function Clouds_Base_Event.OnFrameBreathe()
  FireUIEvent("CLOUDS_FRAME_BREATHE")
  local now = GetLogicFrameCount()
  for i, v in pairs(_.event.tDelay) do
    if v[2] <= now then
      -- TODO: log error
      pcall(v[1])
      _.event.tDelay[i] = nil
    end
  end
end

--- (Dprecated) Add monitor on opening a dialog when intract with NPC
function _.event.AddSelect(npc, string, pattern, tag)
  if not _.DEPRECATED then
    return
  end
  tag = tag or tostring(npc) .. "::" .. tostring(string) .. "<<" .. tostring(pattern)
  _.event.Add("OPEN_WINDOW",function()
    if npc and arg3~=npc then
      local target=Clouds_API.GetPNDByID(arg3)
      if not target or target.szName~=npc then return end
    end
    if string and not arg1:find(string) then return end
    Clouds_API.WindowSelect(arg0, arg1, pattern)
  end, tag)
end

--- (Dprecated) Remove monitor on opening a dialog when intract with NPC
function _.event.RemoveSelect(tag)
  if not _.DEPRECATED then
    return
  end
  _.event.Remove("OPEN_WINDOW", tag)
end

--- Create system message monitor that call all functions in tMonitor[event]
function _.event.GenNewMsgMonitor(event)
  -- the system channel name
  channel = event:gsub("MESSAGE", "MSG", 1)
  if not _.event.tMonitor or _.event.tMonitor[event] then
    return
  end
  _.event.tMonitor[event] = {}
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

_.event.Output = _.base.gen_msg("Clouds_Base_Event")

-- TODO: once
RegisterEvent("LOADING_END", function()
  if _.event.ui then
    return
  end
  local ui = Station.Lookup("Lowest/Clouds_Base_Event")
  if not ui then
    ui = Wnd.OpenWindow(_.event.szIni, "Clouds_Base_Event")
  end

  _.event.ui = ui
  _.event.ui.Monitors = {}
  for i, v in pairs(_.event.tMonitor) do
    _.event.GenNewMonitor(i)
  end
  _.event.Output(_.LEVEL.VERBOSE, "LOADING_END")
end)


_.event.UI = {}

function _.event.UI.GetMenu(name)
  -- TODO: what is name for?
  if not _.DEBUG then
    return
  end
  local menu = {}
  name = "tDelay"
  local submenu = {szOption = name}
  for i,v in pairs(_.event.tDelay) do
    table.insert(submenu,{
      szOption=i,
      {szOption=tostring((v[2]-now)/16)},
      {szOption=tostring(v[1])},
    })
  end
  table.insert(menu,submenu)
  for name,t in pairs(_.event.tMonitor) do
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
        v[5] and {szOption=v[5]:sub(1,50),bCheck=true,fnAction=function()_.event.Output(v[5]) v[5]=nil end},
      })
    end
    table.insert(menu,submenu)
  end
  return menu
end
