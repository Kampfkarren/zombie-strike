local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local Equipment = ReplicatedStorage.Equipment

local function range(max)
	local out = {}
	for index = 1, max do
		table.insert(out, index)
	end
	return out
end

return function(context, player)
	player = player or context.Executor

	DataStore2("Equipment", player):Set({
		HealthPack = range(#Equipment.HealthPack:GetChildren()),
		Grenade = range(#Equipment.Grenade:GetChildren()),
	})
end
