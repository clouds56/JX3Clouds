local _ = Clouds_Base

_.DEBUG = true
_.LEVEL_CURRENT = 1

_.debug = {
  to_string_default_mode = function()
    return {
      suffix="  ", -- indent string
      fun=false, -- show function as string or decoded hex
      oneline=false, -- show all table in oneline
      tabcard=true, -- show table length as comment
      table = nil, -- specific table handle function
    }
  end,
  to_string_get_mode = function(mode)
    local modeex = _.debug.to_string_default_mode()
    for i, v in pairs(mode or {}) do
      modeex[i] = v
    end
    return modeex
  end
}

_.debug.object_to_string = function(o, mode, index, visited)
  index = index or 0
  visited = visited or {}
  mode = _.debug.to_string_get_mode(mode)
  if type(o) == "string" then
    return _.debug.string_to_string(o, mode, index, visited)
  elseif type(o) == "number" then
    return tostring(o)
  elseif type(o) == "boolean" then
    return tostring(o)
  elseif type(o) == "table" then
    return _.debug.table_to_string(o, mode, index, visited)
  elseif type(o) == "userdata" then
    return "'" .. tostring(o) .. "'"
  elseif type(o) == "function" then
    return _.debug.function_to_string(o, mode, index, visited)
  elseif type(o) == "nil" then
    return "nil"
  else
    return "'" .. type(o)..":"..tostring(o) .. "''"
  end
  return "??"
end

_.debug.string_to_string = function(s, mode)
  return '"' .. s:gsub("\n", "\\n") .. '"'
end

_.debug.function_to_string = function(f, mode)
  mode = _.debug.to_string_get_mode(mode)
  if not f then
    return "function: nil"
  end
  if mode.fun then
    return "'" .. tostring(f) .. "'" .. "  --[[\n" .. _.debug.xxd(string.dump(f)) .. "]]"
  else
    return "'" .. tostring(f) .. "'"
  end
end

_.debug.table_to_string = function(t, mode, index, visited)
  index = index or 0
  visited = visited or {}
  mode = _.debug.to_string_get_mode(mode)
  if mode.table then
    return mode:table(t) or ""
  end
  if mode.tab or (visited and visited[t]) then
    visited[t]="p"
    return tostring(t)
  end
  if visited then
    visited[t] = true
  end

  local s = "{"
  local empty = true
  local newline = not mode.oneline and '\n'..mode.suffix:rep(index+1) or " "
  for i = 1, #t do
    local v = t[i]
    empty = false
    s = s .. newline .. _.debug.object_to_string(v, mode, index+1, visited) .. ","
  end

  if mode.tabcard and not empty then
    s=s..newline..(mode.oneline and "--[[%d]]" or "-- # : %d"):format(#t)
  end
  for i, v in pairs(t) do
    local key
    if type(i)=="number" then
      if i > #t then
        key = ("[%d]"):format(i)
      end
    elseif type(i)=="string" then
      key = i
    else
      key = ("[%s]"):format(tostring(i))
    end
    if key then
      empty=false
      s = s .. newline .. key .. " = " .. _.debug.object_to_string(v, mode, index+1, visited) .. ","
    end
  end
  if visited[t]=="p" then
    s = s .. newline .. "--" .. (mode.oneline and "[[%s]]" or " %s"):format(tostring(t))
  end
  if empty then
    s = s .. '}'
  else
    s = s .. (not mode.oneline and '\n'..mode.suffix:rep(index) or "") .. "}"
  end
  return s
end

_.debug.xxd = function(a, unit, line)
  -- %0do : address offset
  -- %0dl  : line number
  -- %0d.dx  : context with 1d for unit and 2d for repeats
  -- %da  :  ascii index
  --[[
  f=f or "%3l %08.4x"
  for i in f:gmatch("%%([%d.]*)([olxa])") do
  end
  ]]
  local s=""
  unit = unit or 4
  line = line or 4
  for k = 0, math.ceil(a:len()/unit/line)-1 do
    for i = k*line, (k+1)*line-1 do
      for j = i*unit+1, (i+1)*unit do
        local v = a:byte(j)
        if v then
          s = s .. (v and ("%02x"):format(v) or "  ")
        end
      end
      s = s .. ' '
    end
    s = s .. '----'
    s = s .. (a:sub(k*line*unit+1,(k+1)*line*unit):gsub("[^%w]","."))
    s = s .. '\n'
  end
  return s
end

if _.DEBUG then
  function _var2str(...)
    local t = {...}
    if #t == 1 then
      return _.debug.object_to_string(t[1])
    end
    return _.debug.object_to_string(t)
  end

  function _dumpstr(f)
    return _.debug.object_to_string(f, { fun=true })
  end

  function out(...)
    local s = _var2str(...)
    OutputMessage("MSG_SYS", s)
    print(s)
  end
end
