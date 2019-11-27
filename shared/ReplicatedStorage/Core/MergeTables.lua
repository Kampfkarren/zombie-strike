return function(...)
	local merged = {}

	for _, list in pairs({ ... }) do
		if type(list) ~= "table" then
			error(("%s is not a table"):format(tostring(list)))
		end

		for key, value in pairs(list) do
			merged[key] = value
		end
	end

	return merged
end
