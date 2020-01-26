-- Removes broken bundles given from the allcosmetics command
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)

return function(player)
	local cosmeticsStore = DataStore2("Cosmetics", player)
	local cosmetics = cosmeticsStore:Get()

	if cosmetics then
		local newOwned = {}

		for _, item in ipairs(cosmetics.Owned) do
			local itemType = Cosmetics.Cosmetics[item].Type
			if itemType ~= "LowTier" and itemType ~= "HighTier" then
				table.insert(newOwned, item)
			end
		end

		cosmetics.Owned = newOwned
		cosmeticsStore:Set(cosmetics):await()
	end
end
