return function(a1, b1, a2, b2, x)
	assert(typeof(a1) == "number", "a1 must be a number")
	assert(typeof(b1) == "number", "b1 must be a number")
	assert(typeof(a2) == "number", "a2 must be a number")
	assert(typeof(b2) == "number", "b2 must be a number")
	assert(typeof(x) == "number", "x must be a number")

	return ((x - a1) / (a2 - a1)) * (b2 - b1) + b1
end
