--[[
local Stub = {}
Stub.__index = Stub

function Stub.new(name, func, env)
  local stub = {}
  stub.name = name
  stub.env = { __this = env }
  setmetatable(stub.env, { __index = _G, __newindex = _G })
  if setfenv then setfenv(func, stub.env)
  else _ENV = stub.env end
  stub.func = function(...)
    __log(name, ...)
    func(...)
  end
  setmetatable(stub, Stub)
  return stub
end

function insert_stub(stubs, name, func, env)
  local stub = Stub.new(name, func, env)
  stubs[name] = stub.func
end
]]
local stubs = {}

local _RegisterEvent = function(env)
  local __name = "RegisterEvent"
  local __this = env
  return function(event, func)
    __log(__name, event, func)
    local monitors = __this.monitors
    if monitors[event] == nil then
      monitors[event] = {}
    end
    local exist = false
    for _, v in ipairs(monitors[event]) do
      if v == func then
        exist = true
        break
      end
    end
    if not exist then
      table.insert(monitors[event], func)
    end
  end
end

local _FireEvent = function(env)
  local __name = "FireEvent"
  local __this = env
  return function(event)
    __log(__name, event)
    local monitors = __this.monitors
    for _, func in ipairs(monitors[event] or {}) do
      __log("running", func)
      func()
    end
  end
end

local _EventEnv = { monitors = {}, }

stubs.RegisterEvent = _RegisterEvent(_EventEnv)
stubs.FireEvent = _FireEvent(_EventEnv)

return stubs
