local stubs = {}
stubs.RegisterEvent = {
  item = function(event, func)
    local monitors = stubs.RegisterEvent.env.monitors
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
  end,
  env = {
    monitors = {},
  },
}

return stubs
