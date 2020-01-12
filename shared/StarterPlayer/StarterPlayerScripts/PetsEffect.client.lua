local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Effects = require(ReplicatedStorage.RuddevModules.Effects)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
local WeakInstanceTable = require(ReplicatedStorage.Core.WeakInstanceTable)

local PET_OFFSET = 3.5
local PET_SWAY_MAX = 1
local PET_SWAY_TIME = 1

local activePets = WeakInstanceTable()

local function updatePetPosition(pet, root, delta)
	pet.CFrame = root.CFrame
		+ root.CFrame.RightVector * PET_OFFSET
		+ Vector3.new(0, math.sin(delta / PET_SWAY_TIME) * PET_SWAY_MAX, 0)
end

local function playerAdded(player)
	local playerData = player:WaitForChild("PlayerData")
	local petValue = playerData:WaitForChild("Pet")
	local petRarityValue = playerData:WaitForChild("PetRarity")

	local lastPet

	local function updatePet(petIndex)
		if lastPet then
			lastPet:Destroy()
			activePets[player] = nil
		end

		if petIndex == 0 then return end

		local character = player.Character
		if character and character.PrimaryPart then
			local pet = assert(PetsDictionary.Pets[petIndex], "pet not found")

			local model = pet.Model:Clone()
			model.Parent = character

			lastPet = model
			activePets[player] = {
				Model = model,
				Offset = math.random(),
				Rarity = petRarityValue.Value,
			}

			updatePetPosition(model, character.PrimaryPart, 0)
		end
	end

	updatePet(petValue.Value)
	petValue.Changed:connect(updatePet)
end

if not ReplicatedStorage.HubWorld.Value then
	local projectileTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	ReplicatedStorage.Remotes.PetFire.OnClientEvent:connect(function(player, target)
		local pet = activePets[player]
		if not pet then return end

		local projectile = ReplicatedStorage.Assets.PetProjectile:Clone()
		projectile.CFrame = CFrame.new(pet.Model.Position, target.PrimaryPart.Position)
			* CFrame.Angles(0, math.pi / 2, 0)
		projectile.Color = PetsDictionary.Rarities[pet.Rarity].Style.Color
		projectile.Parent = Workspace

		local tween = TweenService:Create(projectile, projectileTweenInfo, {
			Position = target.PrimaryPart.Position,
		})

		tween.Completed:connect(function()
			projectile:Destroy()
			Effects.Effect("Damage", target.PrimaryPart.Position, Vector3.new())
		end)

		tween:Play()
	end)
end

local total = 0

RunService.Heartbeat:connect(function(delta)
	total = total + delta

	for player, pet in pairs(activePets) do
		local character = player.Character

		if character and character.PrimaryPart then
			updatePetPosition(pet.Model, character.PrimaryPart, total + pet.Offset)
		end
	end
end)

Players.PlayerAdded:connect(playerAdded)
for _, player in pairs(Players:GetPlayers()) do
	FastSpawn(function()
		playerAdded(player)
	end)
end
