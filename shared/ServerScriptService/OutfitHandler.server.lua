local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Core.Data)
local Promise = require(ReplicatedStorage.Core.Promise)
local XP = require(ReplicatedStorage.Core.XP)

local function equip(player, character, equippable)
	return Data.GetPlayerDataAsync(player, equippable.Name)
		:andThen(function(equipped)
			local item = ReplicatedStorage.Items[equipped.Type .. equipped.Model]

			for _, thing in pairs(item:GetChildren()) do
				if thing:IsA("CharacterAppearance") or thing:IsA("Accessory") then
					thing:Clone().Parent = character
				end
			end

			return equippable.Health(equipped.Level, equipped.Rarity)
		end)
end

local Armor = {
	Name = "Armor",
	Health = ArmorScaling.ArmorHealth,
}

local Helmet = {
	Name = "Helmet",
	Health = ArmorScaling.HelmetHealth,
}

local function playerAdded(player)
	local function characterAdded(character)
		Promise.all({
			equip(player, character, Armor),
			equip(player, character, Helmet),
			Data.GetPlayerDataAsync(player, "Level"):andThen(XP.HealthForLevel)
		}):andThen(function(healths)
			local health = 0

			for _, add in pairs(healths) do
				health = health + add
			end

			character.Humanoid.MaxHealth = health
			character.Humanoid.Health = health
		end)
	end

	if player.Character then
		characterAdded(player.Character)
	end

	player.CharacterAdded:connect(characterAdded)
end

for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end

Players.PlayerAdded:connect(playerAdded)
