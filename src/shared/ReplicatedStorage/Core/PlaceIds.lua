local PlaceIds = {}

PlaceIds.Games = {
	-- Production
	[1298774291] = {
		Hub = 3759927663,
		Mission = 3803533582,
	},

	-- Development
	[1429320739] = {
		Hub = 4479247072,
		Mission = 4479261449,
	},
}

function PlaceIds.GetHubPlace()
	return assert(PlaceIds.Games[game.GameId]).Hub
end

function PlaceIds.GetMissionPlace()
	return assert(PlaceIds.Games[game.GameId]).Mission
end

return PlaceIds
