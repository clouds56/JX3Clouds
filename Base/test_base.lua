local _G = _G
_G.Clouds_Base = { base = {gen_msg=function()end,gen_all_msg=function()end} }

_G.assert_equals = function(a, b)
  if a ~= b then
    print(string.format("assert failure: %s ~= %s", tostring(a), tostring(b)))
    assert(false)
  end
end
