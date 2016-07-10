local _t
_t = {
  NAME = "algorithm",

  to_string_default_mode = function()
    return {
      suffix="  ", -- indent string
      fun=false, -- show function as string or decoded hex
      oneline=false, -- show all table in oneline
      tab = false, -- expand table
      tabcard=true, -- show table length as comment
      table = nil, -- specific table handle function
    }
  end,
  to_string_get_mode = function(mode)
    local modeex = _t.to_string_default_mode()
    for i, v in pairs(mode or {}) do
      modeex[i] = v
    end
    return modeex
  end,

  table = {
    sconcat = function(t, sep, i, j)
      local s = ""
      local first = true
      sep = sep or ""
      --if i or j then _t.Output(_t.module.LEVEL.WARNING, "algorithm.table.sconcat do not support arg i(%s), j(%s)", tostring(i), tostring(j)) end
      if t[1] == nil then
        return s
      end
      for x, v in ipairs(t) do
        if not i or x >= i then
          if j and x > j then
            break
          end
          if not first then
            s = s .. sep .. tostring(v)
          else
            s = s .. tostring(v)
            first = false
          end
        end
      end
      return s
    end
  }
}

_t.module = Clouds_Base
Clouds_Base.algorithm = _t
_t.Output = _t.module.base.gen_msg(_t.NAME)

_t.object_to_string = function(o, mode, index)
  index = index or 0
  mode = _t.to_string_get_mode(mode)
  if type(o) == "string" then
    return _t.string_to_string(o, mode, index)
  elseif type(o) == "number" then
    return tostring(o)
  elseif type(o) == "boolean" then
    return tostring(o)
  elseif type(o) == "table" then
    if o.tostring then
      return o:tostring()
    end
    return _t.table_to_string(o, mode, index)
  elseif type(o) == "userdata" then
    return "'" .. tostring(o) .. "'"
  elseif type(o) == "function" then
    return _t.function_to_string(o, mode, index)
  elseif type(o) == "nil" then
    return "nil"
  else
    return "'" .. type(o)..":"..tostring(o) .. "''"
  end
  return "??"
end

_t.string_to_string = function(s, mode)
  return '"' .. s:gsub("\n", "\\n") .. '"'
end

_t.function_to_string = function(f, mode)
  mode = _t.to_string_get_mode(mode)
  if not f then
    return "function: nil"
  end
  if mode.fun then
    return "'" .. tostring(f) .. "'" .. "  --[[\n" .. _t.xxd(string.dump(f)) .. "]]"
  else
    return "'" .. tostring(f) .. "'"
  end
end

_t.table_to_string = function(t, mode, index, visited, path)
  index = index or 0
  visited = visited or {}
  path = path or "ROOT"
  mode = _t.to_string_get_mode(mode)
  if mode.table then
    return mode:table(t) or ""
  end
  if t.tostring then
    return t:tostring()
  end

  if mode.tab or (visited and visited[t]) then
    visited[t].referenced = true
    return tostring(t) .. " " .. ("--[=[ %s ]=]"):format(visited[t].path)
  end
  if visited then
    visited[t] = { path=path, referenced=false }
  end

  local s = "{"
  local empty = true
  local newline = not mode.oneline and '\n'..mode.suffix:rep(index+1) or " "
  for i = 1, #t do
    local v = t[i]
    empty = false
    local value
    if type(v) == "table" then
      value = _t.table_to_string(v, mode, index+1, visited, string.format("%s[%d]",path,i))
    else
      value = _t.object_to_string(v, mode, index+1)
    end
    s = s .. newline .. value .. ","
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
    elseif type(i)=="table" and i.tostring then
      key = ("[table: %s]"):format(i:tostring())
    else
      key = ("[%s]"):format(tostring(i))
    end
    if key then
      empty=false
      local value
      if type(v) == "table" then
        value = _t.table_to_string(v, mode, index+1, visited, string.format("%s[%s]",path,tostring(t)))
      else
        value = _t.object_to_string(v, mode, index+1)
      end
      s = s .. newline .. key .. " = " .. value .. ","
    end
  end
  if visited[t].referenced then
    -- TODO: visited later, the original one should show id
    s = s .. newline .. "--" .. (mode.oneline and "[[%s]]" or " %s"):format(tostring(t))
  end
  if empty then
    s = s .. '}'
  else
    s = s .. (not mode.oneline and '\n'..mode.suffix:rep(index) or "") .. "}"
  end
  return s
end

_t.xxd = function(a, unit, line)
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

table.sconcat = _t.table.sconcat
