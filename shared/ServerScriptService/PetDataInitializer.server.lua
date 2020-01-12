local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local petValue = Instance.new("NumberValue")
	petValue.Name = "Pet"
	petValue.Parent = playerData

	local petRarityValue = Instance.new("NumberValue")
	petRarityValue.Name = "PetRarity"
	petRarityValue.Parent = playerData

	local function updatePets(data)
		petValue.Value = data[2] or 0
		petRarityValue.Value = data[3] or 0
	end

	local pets, petsStore = Data.GetPlayerData(player, "Pets")
	petsStore:OnUpdate(updatePets)
	updatePets(pets)
end)
