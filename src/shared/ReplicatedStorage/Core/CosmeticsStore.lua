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
	["2019-12-31"] = catalog("The Dark God", "Su Tart", "Rockstar"),
	["2020-01-01"] = catalog("The Dark God", "Su Tart", "Rockstar"),
	["2020-01-02"] = catalog("Dark Age Apprentice", "Codebreaker", "Anime Fan"),
	["2020-01-03"] = catalog("Light Dominus: the God", "Ms. Friend", "New Kid"),
	["2020-01-04"] = catalog("Swanky", "Blue Dude", "Felipe"),
	["2020-01-05"] = catalog("Doombringer", "Oof", "Codebreaker"),
	["2020-01-06"] = catalog("The Dark God", "Little Ms. Rich", "Bunny"),
	["2020-01-07"] = catalog("The Professional", "New Kid", "White Belt"),
	["2020-01-07"] = catalog("The Dark God", "SinisterBot 5001", "Penguin"),
})
