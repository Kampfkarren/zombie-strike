local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

local function crystalGun(level, rarity)
	return {
		Type = "Crystal",
		Level = level,
		Rarity = rarity,

		Bonus = 0,
		Upgrades = 0,
		Favorited = false,

		Model = rarity,
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}
end

return function(context, player)
	local player = player or context.Executor
	DataStore2("Inventory", player):Update(function(inventory)
		local level = DataStore2("Level", player):Get()

		table.insert(inventory, crystalGun(level, 1))
		table.insert(inventory, crystalGun(level, 2))
		table.insert(inventory, crystalGun(level, 3))
		table.insert(inventory, crystalGun(level, 4))
		table.insert(inventory, crystalGun(level, 5))

		return inventory
	end)
end
