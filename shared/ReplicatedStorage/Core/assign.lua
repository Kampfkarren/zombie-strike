return function(list, patch)
	local assigned = {}

	for key, value in pairs(patch) do
		assigned[key] = value
	end

	for key, value in pairs(list) do
		assigned[key] = value
	end

	return assigned
end
