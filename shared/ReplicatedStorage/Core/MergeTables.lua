local function mergeTables(...)
	local args = { ... }
	local n = select("#", ...)
	local merged = {}

	for index = 1, n do
		local item = args[index]
		if item ~= nil then
			assert(type(item) == "table")
			for key, value in pairs(item) do
				if type(merged[key]) == "table" then
					merged[key] = mergeTables(merged[key], value)
				else
					merged[key] = value
				end
			end
		end
	end

	return merged
end

return mergeTables
