local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local function possession(dataName, remote, optimized)
	Players.PlayerAdded:connect(function(player)
		local data = Data.GetPlayerData(player, dataName)
		if optimized then
			data = {
				Owned = data[1],
				Equipped = data[2],
			}
		end

		remote:FireClient(player, data.Equipped, data.Owned)
	end)

	remote.OnServerEvent:connect(function(player, index)
		if type(index) ~= "number" then
			warn(remote .. ": index is not a number")
			return
		end

		local data, dataStore = Data.GetPlayerData(player, dataName)
		if table.find(optimized and data.Owned or data[1], index) == nil then
			warn(remote .. ": player equipping possession they don't own")
			return
		end

		local toEquip
		local key = optimized and "Equipped" or 2

		if data[key] == index then
			toEquip = nil
		else
			toEquip = index
		end

		data[key] = toEquip
		dataStore:Set(data)
		remote:FireClient(player, toEquip)
	end)
end

local function optimizedPossession(dataName, remote)
	possession(dataName, remote, true)
end

possession("Sprays", ReplicatedStorage.Remotes.UpdateSprays)
possession("Titles", ReplicatedStorage.Remotes.UpdateTitles)
possession("Fonts", ReplicatedStorage.Remotes.UpdateFonts)
optimizedPossession("Pets", ReplicatedStorage.Remotes.UpdatePets)
