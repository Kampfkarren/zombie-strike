local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)

local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

return function(context, player)
	player = player or context.Executor

	local data, dataStore = Data.GetPlayerData(player, "Cosmetics")
	local newOwned = {}

	for index, cosmetic in pairs(Cosmetics.Cosmetics) do
		if cosmetic.Type ~= "LowTier" and cosmetic.Type ~= "HighTier" then
			table.insert(newOwned, index)
		end
	end

	data.Owned = newOwned

	dataStore:Set(data)

	UpdateCosmetics:FireClient(player, data.Owned, data.Equipped)
end
