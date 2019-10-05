local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GiveOutfit = require(ServerScriptService.Shared.GiveOutfit)

local function playerAdded(player)
	local function characterAdded(character)
		GiveOutfit(player, character):andThen(function()
			if character:IsDescendantOf(game) then
				ReplicatedStorage.Remotes.SetDeadState:FireClient(player)
			end
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
