local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GamePassDictionary = require(ReplicatedStorage.Core.GamePassDictionary)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local Nametag = require(ServerScriptService.Shared.Nametag)

local function makeVip(nametag)
	if not nametag.EnemyName.Text:match("[VIP]") then
		nametag.EnemyName.Text = "[VIP] " .. nametag.EnemyName.Text
		nametag.EnemyName.TextColor3 = Color3.new(1, 1, 0.5)
	end
end

local function maybeVip(player, nametag)
	GamePasses.PlayerOwnsPassAsync(player, GamePassDictionary.VIP):andThen(function(bought)
		if bought then
			makeVip(nametag)
		end
	end)
end

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")
	local level = playerData:WaitForChild("Level")

	local function characterAdded(character)
		local nametag = Nametag(character, level.Value)

		maybeVip(player, nametag)

		GamePasses.BoughtPassUpdated(player).Event:connect(function()
			maybeVip(player, nametag)
		end)

		character.Humanoid.HealthChanged:connect(function()
			maybeVip(player, Nametag(character, level.Value))
		end)

		level.Changed:connect(function()
			maybeVip(player, Nametag(character, level.Value))
		end)
	end

	if player.Character then
		characterAdded(player.Character)
	end

	player.CharacterAdded:connect(characterAdded)
end)
