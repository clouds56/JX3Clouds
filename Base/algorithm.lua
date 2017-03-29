local xv = {}
Clouds_Base.xv = xv

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
      --if i or j then _t.Output(_t.module.LEVEL.WARNING, --[[tag]]0, "algorithm.table.sconcat do not support arg i(%s), j(%s)", tostring(i), tostring(j)) end
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
    end,

    iter_subtables = function(tall)
      local idx, tmp = {}, {}
      for x, v in pairs(tall) do
        if type(v) == "table" then
          idx[x] = 0
          if #v > 0 then
            tmp[x] = v[1]
          end
        end
      end
      local iter = function(_tall, total)
        if not total then
          total = 0
          for _, i in pairs(idx) do total = total + i end
        end
        local tp, value
        for k, v in pairs(tmp) do
          if not tp or value.time > v.time then
            tp, value = k, v
          end
        end
        if not tp then return end
        idx[tp] = idx[tp]+1
        if #tall[tp] > idx[tp] then
          tmp[tp] = tall[tp][idx[tp]+1]
        else
          tmp[tp] = nil
        end
        return total+1, tp, value
      end
      return iter, tall, 0
    end,
  },

  frame = {
    tostring = function(self, width)
      local t = self
      width = width or -1
      if type(t) ~= "number" then
        return nil
      end
      if t >= 2^31-1 then
        return "never"
      end
      local minus = ""
      if t < 0 then
        minus = "-"
        t = -t
      end
      t = t/16
      if (width == -1 and t < 60) or width == 0 then
        return minus .. string.format("%.3f", t)
      end
      local milliseconds = string.format("%.2f", t%1):sub(3)
      local seconds = string.format("%02d.%s", math.floor(t%60), milliseconds)
      t = math.floor(t/60)
      if (width == -1 and t < 60) or width == 1 then
        return minus .. string.format("%d:%s", t, seconds)
      end
      local minutes = t % 60
      t = math.floor(t/60)
      if (width == -1 and t < 100) or width == 2 then
        return minus .. string.format("%d:%02d:%s", t, minutes, seconds)
      end
      local hours = t % 24
      t = math.floor(t/24)
      return minus .. string.format("%dd%02d:%02d:%s", t, hours, minutes, seconds)
    end,
  },

  string = {
    trim = function(s)
      return s:match("^%s*(.-)%s*$")
    end,
    split = function(s, delimeter)
      delimeter = delimeter or ","
      local t = {}
      for i in (s .. delimeter):gmatch("(.-)" .. delimeter) do
        table.insert(t, i)
      end
      return t
    end
  },

  timestamp = {
    tostring = function(self, format)
      format = format or "%yy-%MM-%ddT%HH:%mm:%ss"
      local date = TimeToDate(self)
      date.Hour, date.hour, date.designator = date.hour, (date.hour + 11) % 12 + 1, date.hour >= 12 and "P" or "A"
      format = format:gsub("%%yyyy", date.year):gsub("%%yy", ("%02d"):format(date.year%100))
      format = format:gsub("%%MMM", _t.timestamp.month_name[date.month])
      format = format:gsub("%%MM", ("%02d"):format(date.month)):gsub("%%M", date.month)
      format = format:gsub("%%dd", ("%02d"):format(date.day)):gsub("%%d", date.day)
      format = format:gsub("%%HH", ("%02d"):format(date.Hour)):gsub("%%H", date.Hour)
      format = format:gsub("%%hh", ("%02d"):format(date.hour)):gsub("%%h", date.hour)
      format = format:gsub("%%mm", ("%02d"):format(date.minute)):gsub("%%m", date.minute)
      format = format:gsub("%%ss", ("%02d"):format(date.second)):gsub("%%s", date.second)
      format = format:gsub("%%tt", date.designator .. "M"):gsub("%%t", date.designator)
      return format
    end,
    month_name = {
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    }
  },
}

_t.module = Clouds_Base
Clouds_Base.algorithm = _t
_t.module.base.gen_all_msg(_t)

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
    local s = _t.table_tostring_to_string(o)
    if s then
      return s
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

_t.table_tostring_to_string = function(t)
  if t.__tostring then
    local b, s = pcall(t.__tostring, t)
    if b and type(s) == "string" then
      return s
    else
      _t.Output_warn(--[[tag]]0, "error calling __tostring with %s, result %s, %s", tostring(t), tostring(b), tostring(s))
    end
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
  if t.__tostring then
    local s = _t.table_tostring_to_string(t)
    if s then
      return s
    end
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
  local tt = {}
  for i = 1, #t do
    local v = t[i]
    empty = false
    local value
    if type(v) == "table" then
      value = _t.table_to_string(v, mode, index+1, visited, string.format("%s[%d]",path,i))
    else
      value = _t.object_to_string(v, mode, index+1)
    end
    table.insert(tt, newline .. value .. ",")
  end
  s = s .. table.concat(tt)

  if mode.tabcard and not empty then
    s=s..newline..(mode.oneline and "--[[%d]]" or "-- # : %d"):format(#t)
  end
  for i, v in pairs(t) do
    local key
    if type(i)=="number" then
      if i > #t or i < 1 then
        key = ("[%d]"):format(i)
      end
    elseif type(i)=="string" then
      key = i
    elseif type(i)=="table" then
      local s = _t.table_tostring_to_string(i)
      key = s and ("[table: %s]"):format(s) or ("[%s]"):format(tostring(i))
    end
    if key then
      empty=false
      local value
      if type(v) == "table" then
        local keystring = tostring(i)
        if type(i)=='string' then
          keystring = string.format("'%s'", tostring(i))
        elseif (type(i)=='number' or type(i)=='boolean' or type(i)=='nil') then
        else
          keystring = string.format('"%s"', tostring(i))
        end
        value = _t.table_to_string(v, mode, index+1, visited, string.format("%s['%s']",path,keystring))
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
xv.object_to_string = _t.object_to_string
xv.algo = {
  timestamp = _t.timestamp,
  frame = _t.frame,
  table = _t.table
}

if _t.module.DEBUG then
  _G.xv = xv
end
