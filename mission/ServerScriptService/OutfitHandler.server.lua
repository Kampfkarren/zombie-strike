local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local GiveOutfit = require(ServerScriptService.Shared.GiveOutfit)

local function playerAdded(player)
	local function characterAdded(character)
		GiveOutfit(player, character)
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
