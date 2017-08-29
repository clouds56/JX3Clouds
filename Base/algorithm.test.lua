require "test_base"
require "algorithm"
local xv = Clouds_Base.xv
local out = function(...) print(xv.object_to_string(...)) end

assert_equals(type(xv), "table")
assert_equals(xv.algo.frame.tostring(0), "0.000")
-- assert_equals(xv.algo.frame.tostring(1), "0.062")
assert_equals(xv.algo.frame.tostring(-4), "-0.250")
assert_equals(xv.algo.frame.tostring(15), "0.938")
assert_equals(xv.algo.frame.tostring(16), "1.000")
assert_equals(xv.algo.frame.tostring(-23), "-1.438")
assert_equals(xv.algo.frame.tostring(16*60+3), "1:00.19")
assert_equals(xv.algo.frame.tostring(3-16*(60*5+23)), "-5:22.81")
assert_equals(xv.algo.frame.tostring(-16*60*53+8), "-52:59.50")
assert_equals(xv.algo.frame.tostring(7+16*(60*60*5+3)), "5:00:03.44")
assert_equals(xv.algo.frame.tostring(-3345678), "-58:05:04.88")
assert_equals(xv.algo.frame.tostring(12345678), "8d22:20:04.88")
assert_equals(xv.algo.frame.tostring(-123456789), "-89d07:20:49.31")

local ordered_hash = xv.algo.ordered_hash.new(function(x)return x*2 end, {10, 21, 32, 9})
-- out(ordered_hash:get_orderedlist())
assert_equals(ordered_hash:push(30), 5) -- { 10, 21, 32, 9, 30 }
-- out(ordered_hash:get_orderedlist())
assert_equals(ordered_hash:get(42), 21)
assert_equals(ordered_hash:get(60), 30)
assert_equals(ordered_hash:push(9), 4)
ordered_hash:remove(18) -- { 10, 21, 32, 30 }
-- out(ordered_hash:get_orderedlist())
assert_equals(ordered_hash:get(18), nil)
assert_equals(ordered_hash:get(60), 30)

local to_remove = {11, 22, 33, c=22}
assert_equals(xv.algo.table.remove_v(to_remove, 22), 2)
assert_equals(xv.algo.table.remove_v(to_remove, 22), "c")
assert_equals(xv.algo.table.remove_v(to_remove, 22), nil)
