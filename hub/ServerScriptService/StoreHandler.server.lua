local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Data = require(ReplicatedStorage.Core.Data)

local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics

local function playerOwnsCosmetic(player, index)
	for _, owned in pairs(Data.GetPlayerData(player, "Cosmetics").Owned) do
		if owned == index then
			return true
		end
	end
end

Players.PlayerAdded:connect(function(player)
	local data = Data.GetPlayerData(player, "Cosmetics")
	UpdateCosmetics:FireClient(player, data.Owned, data.Equipped)
end)

UpdateCosmetics.OnServerEvent:connect(function(player, itemIndex)
	local data, dataStore = Data.GetPlayerData(player, "Cosmetics")

	if type(itemIndex) == "string" then
		if data.Equipped[itemIndex] then
			dataStore:Update(function(data)
				data.Equipped[itemIndex] = nil
				UpdateCosmetics:FireClient(player, nil, data.Equipped)
				return data
			end)
		end
	else
		if not playerOwnsCosmetic(player, itemIndex) then
			warn("player doesn't own cosmetic they're equipping")
			return
		end

		local cosmetic = assert(Cosmetics.Cosmetics[itemIndex], "equipping non-existent cosmetic!")
		if data.Equipped[cosmetic.Type] ~= itemIndex then
			dataStore:Update(function(data)
				data.Equipped[cosmetic.Type] = itemIndex
				UpdateCosmetics:FireClient(player, nil, data.Equipped)
				return data
			end)
		end
	end
end)
