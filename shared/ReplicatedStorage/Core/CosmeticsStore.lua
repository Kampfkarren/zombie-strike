local function catalog(limited, bundle1, bundle2)
	return {
		HighTier = { limited },
		LowTier = { bundle1, bundle2 },
	}
end

local function cosmeticsStore(store)
	local newStore = {}

	for dateString, catalog in pairs(store) do
		local split = dateString:split("-")
		local date = os.date("!*t", os.time({
			year = split[1],
			month = split[2],
			day = split[3],
		}))

		newStore[date.year + date.yday] = catalog
	end

	return newStore
end

return cosmeticsStore({
	["2019-12-23"] = catalog("Santa", "Mrs. Claus", "Penguin"),
	["2019-12-24"] = catalog("Santa", "Mrs. Claus", "Penguin"),
	["2019-12-25"] = catalog("Santa", "Mrs. Claus", "Penguin"),
	["2019-12-26"] = catalog("Santa", "Mrs. Claus", "Penguin"),
})
