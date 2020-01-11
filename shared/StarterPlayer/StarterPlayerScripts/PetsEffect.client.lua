local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)

local PET_OFFSET = 3.5
local PET_SWAY_MAX = 1
local PET_SWAY_TIME = 1

local activePets = {}

local function updatePetPosition(pet, root, delta)
	pet.CFrame = root.CFrame
		+ root.CFrame.RightVector * PET_OFFSET
		+ Vector3.new(0, math.sin(delta / PET_SWAY_TIME) * PET_SWAY_MAX, 0)
end

local function playerAdded(player)
	local playerData = player:WaitForChild("PlayerData")
	local petValue = playerData:WaitForChild("Pet")

	local lastPet

	local function updatePet(petIndex)
		if lastPet then
			lastPet:Destroy()
			activePets[player] = nil
		end

		if petIndex == 0 then return end

		local pet = assert(PetsDictionary[petIndex], "pet not found")

		local model = pet.Model:Clone()
		model.Parent = Workspace

		lastPet = model
		activePets[player] = model

		local character = player.Character
		if character and character.PrimaryPart then
			updatePetPosition(model, character.PrimaryPart, 0)
		end
	end

	updatePet(petValue.Value)
	petValue.Changed:connect(updatePet)
end

local total = 0

RunService.Heartbeat:connect(function(delta)
	total = total + delta

	for player, pet in pairs(activePets) do
		local character = player.Character

		if character and character.PrimaryPart then
			updatePetPosition(pet, character.PrimaryPart, total)
		end
	end
end)

Players.PlayerAdded:connect(playerAdded)
for _, player in pairs(Players:GetPlayers()) do
	FastSpawn(function()
		playerAdded(player)
	end)
end
