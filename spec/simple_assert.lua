local function assert_eq(expected, got)
	if expected == got then
		return
	end
	assert(expected == got, "expected '" .. tostring(expected) .. "' but got '" .. tostring(got) .. "'")
end

return {
	assert_eq = assert_eq
}
