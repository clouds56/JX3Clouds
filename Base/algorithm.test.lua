require "test_base"
require "algorithm"

assert_equals(type(xv), "table")
assert_equals(xv.frame.tostring(0), "0.000")
assert_equals(xv.frame.tostring(1), "0.063")
assert_equals(xv.frame.tostring(-4), "-0.250")
assert_equals(xv.frame.tostring(15), "0.938")
assert_equals(xv.frame.tostring(16), "1.000")
assert_equals(xv.frame.tostring(-23), "-1.438")
assert_equals(xv.frame.tostring(16*60+3), "1:00.188")
assert_equals(xv.frame.tostring(3-16*(60*5+23)), "-5:22.813")
assert_equals(xv.frame.tostring(-16*60*53+8), "-52:59.500")
assert_equals(xv.frame.tostring(7+16*(60*60*5+3)), "5:00:03.438")
assert_equals(xv.frame.tostring(-3345678), "-58:05:04.875")
assert_equals(xv.frame.tostring(12345678), "8d22:20:04.875")
assert_equals(xv.frame.tostring(-123456789), "-89d07:20:49.313")
