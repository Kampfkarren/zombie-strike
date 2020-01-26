local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local function possession(dataName, remote)
	Players.PlayerAdded:connect(function(player)
		local data = Data.GetPlayerData(player, dataName)
		remote:FireClient(player, data.Equipped, data.Owned)
	end)

	remote.OnServerEvent:connect(function(player, index)
		if type(index) ~= "number" then
			warn(remote .. ": index is not a number")
			return
		end

		local data, dataStore = Data.GetPlayerData(player, dataName)
		if table.find(data.Owned, index) == nil then
			warn(remote .. ": player equipping possession they don't own")
			return
		end

		local toEquip
		if data.Equipped == index then
			toEquip = nil
		else
			toEquip = index
		end

		data.Equipped = toEquip
		dataStore:Set(data)
		remote:FireClient(player, toEquip)
	end)
end

possession("Sprays", ReplicatedStorage.Remotes.UpdateSprays)
possession("Titles", ReplicatedStorage.Remotes.UpdateTitles)
possession("Fonts", ReplicatedStorage.Remotes.UpdateFonts)
