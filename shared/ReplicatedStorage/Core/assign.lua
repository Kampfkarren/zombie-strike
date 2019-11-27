local None = require(script.Parent.None)

return function(list, patch)
	local assigned = {}

	for key, value in pairs(patch) do
		if value ~= None then
			assigned[key] = value
		end
	end

	for key, value in pairs(list) do
		if patch[key] ~= None then
			assigned[key] = value
		end
	end

	return assigned
end
