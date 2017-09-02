local RegisterEvent = RegisterEvent
local FireUIEvent = FireUIEvent
local GetLogicFrameCount = GetLogicFrameCount
local RegisterMsgMonitor = RegisterMsgMonitor
local Station, Wnd = Station, Wnd

local _t
_t = {
  NAME = "event",

  --- monitors[event][tag] = { func, enabled, called, errored }
  monitors = {},

  delaycalls = {},
  szIni="interface/Clouds/Base/event.ini",
}

_t.module = Clouds.Base
Clouds.Base.event = _t
Clouds.Base.base.gen_all_msg(_t)

--- Generate system monitor that call all functions in monitors[event]
--- @param(event): system event name, if begin with MESSAGE, call GenNewMsgMonitor additionally
function _t.GenNewMonitor(event)
  -- TODO: make sure there's only one call per event through RELOADING
  -- broken
  if not _t.monitors then
    return
  end

  if not _t.monitors[event] then
    _t.monitors[event] = {}
  end

  -- redirect message to event register
  if event and event:find("^MESSAGE") then
    _t.GenNewMsgMonitor(event)
  end

  RegisterEvent(event, function(...)
    for i, v in pairs(_t.monitors[event] or {}) do
      if v[2] then
        local b, s = pcall(v[1], ...)
        v[3] = v[3] + 1
        if not b and event ~= "CALL_LUA_ERROR" then
          FireUIEvent("CALL_LUA_ERROR", s)
          _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, "LUA_ERROR: " .. s)
          v[4] = v[4] + 1
          v[5] = s
        end
      end
    end
  end)
end

--- Add a monitoring function on event into monitors[event]
--- @param(event): the event name
--- @param(func): the monitor function
--- @param(tag): the index of function in monitors[event]
--- @remark: the tag should not be "all", if it is null, the func itself would be the tag.
function _t.Add(event, func, tag)
  tag = tag or func
  if not _t.monitors then
    return
  end
  if not _t.monitors[event] then
    _t.GenNewMonitor(event)
  end
  _t.monitors[event][tag] = { func, true, 0, 0 }
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
  if not _t.monitors or not _t.monitors[event] then
    return
  end
  if tag == "all" then
    _t.monitors[event] = nil
  end
  _t.monitors[event][tag] = nil
end

--- Remove
function _t.RemoveAll(tag)
  tag = tag or "test"
  if not _t.monitors then
    return
  end
  for i, v in pairs(_t.monitors) do
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
      func(...)
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
  _t.delaycalls[tag] = { func, GetLogicFrameCount() + time }
end

function _t.RemoveDelay(tag)
  -- TODO: test
  _t.delaycalls[tag] = nil
end

_G.Clouds_Base_Event = {}
function Clouds_Base_Event.OnFrameBreathe()
  FireUIEvent("CLOUDS_FRAME_BREATHE")
  local now = GetLogicFrameCount()
  for i, v in pairs(_t.delaycalls) do
    if v[2] <= now then
      -- TODO: log error
      pcall(v[1])
      _t.delaycalls[i] = nil
    end
  end
end

--- Create system message monitor that call all functions in monitors[event]
function _t.GenNewMsgMonitor(event)
  -- the system channel name
  local channel = event:gsub("MESSAGE", "MSG", 1)
  if not _t.monitors then
    return
  end
  if not _t.monitors[event] then
    _t.monitors[event] = {}
  end

  -- TODO: once
  RegisterMsgMonitor(function(message, font, rich, r, g, b)
    FireUIEvent(event, message, rich, font, {r, g, b})
  end, {channel})
end

local init = function()
  if _t.ui then
    return
  end
  local ui = Station.Lookup("Lowest/Clouds_Base_Event")
  if not ui then
    ui = Wnd.OpenWindow(_t.szIni, "Clouds_Base_Event")
  end
  _t.ui = ui
  _t.Output(_t.module.LEVEL.INFO, --[[tag]]0, "init successfully")
end

-- TODO: once
init()
-- RegisterEvent("LOADING_END", init)


_t.UI = {}

function _t.UI.GetMenu(name)
  -- TODO: what is name for?
  if not _t.module.DEBUG then
    return
  end
  local menu = {}
  name = "delaycalls"
  local now = GetLogicFrameCount()
  local submenu = {szOption = name}
  for i,v in pairs(_t.delaycalls) do
    table.insert(submenu,{
      szOption=i,
      {szOption=tostring((v[2]-now)/16)},
      {szOption=tostring(v[1])},
    })
  end
  table.insert(menu,submenu)
  for name,t in pairs(_t.monitors) do
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
        v[5] and {szOption=v[5]:sub(1,50),bCheck=true,fnAction=function()_t.Output(_t.module.LEVEL.INFO,  --[[tag]]0, v[5]) v[5]=nil end},
      })
    end
    table.insert(menu,submenu)
  end
  return menu
end
