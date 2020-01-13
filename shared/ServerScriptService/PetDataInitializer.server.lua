local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")

	local petValue = Instance.new("NumberValue")
	petValue.Name = "Pet"
	petValue.Parent = playerData

	local petRarityValue = Instance.new("NumberValue")
	petRarityValue.Name = "PetRarity"
	petRarityValue.Parent = playerData

	local function updatePets()
		-- Delay so that inventory can be set
		RealDelay(0.01, function()
			local pet = Data.GetPlayerData(player, "Pet")
			petValue.Value = pet and pet.Model or 0
			petRarityValue.Value = pet and pet.Rarity or 0
		end)
	end

	local _, petsStore = Data.GetPlayerData(player, "EquippedPet")
	petsStore:OnUpdate(updatePets)
	updatePets()
end)
